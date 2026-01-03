import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import '../models/signaling_message.dart';
import '../interfaces.dart';
import '../utils/retry_helper.dart';

/// Connection states for the state machine
enum ConnectionManagerState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

// SOLID: Single Responsibility - Manages WebRTC connection lifecycle
// SOLID: Interface Segregation - Implements focused IConnectionManager interface
class ConnectionManager with ReconnectionMixin implements IConnectionManager {
  final ISignalingService _signalingService;
  final IWebRTCService _webrtcService;
  final String _userId;

  final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  String? _currentPeerId;
  bool _isChatOpen = false;
  Timer? _presenceTimer;
  Timer? _healthCheckTimer;

  ConnectionManagerState _state = ConnectionManagerState.disconnected;
  Function(String)? _connectionStateCallback;

  // Retry configuration
  int _connectionAttempt = 0;
  static const int _maxConnectionAttempts = 5;

  // Heartbeat configuration
  static const Duration _presenceInterval = Duration(seconds: 10);
  static const Duration _healthCheckInterval = Duration(seconds: 5);

  ConnectionManager(this._signalingService, this._webrtcService, this._userId);

  ConnectionManagerState get state => _state;

  @override
  Future<void> connectToPeer(String peerId) async {
    // Skip if already connected to this peer
    if (_currentPeerId == peerId &&
        _webrtcService.connectionState ==
            RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      _logger.i('WebRTC: Already connected to $peerId. Skipping initiation.');
      return;
    }

    // Skip if already connecting
    if (_state == ConnectionManagerState.connecting) {
      _logger.i('WebRTC: Already connecting. Skipping duplicate request.');
      return;
    }

    _currentPeerId = peerId;
    _setState(ConnectionManagerState.connecting);
    _connectionAttempt = 0;

    await _attemptConnection(peerId);
  }

  Future<void> _attemptConnection(String peerId) async {
    _connectionAttempt++;
    _logger.i(
      'WebRTC: Connection attempt $_connectionAttempt/$_maxConnectionAttempts to $peerId',
    );

    try {
      final offer = await RetryHelper.withTimeout(
        () => _webrtcService.createOffer(),
        timeout: const Duration(seconds: 10),
        operationName: 'Create offer',
      );

      final message = SignalingMessage.offer(
        from: _userId,
        to: peerId,
        sdp: offer,
      );

      await _signalingService.sendSignalingMessage(message, peerId);
      _logger.i('WebRTC: Sent offer to $peerId');
    } catch (e) {
      _logger.e('WebRTC: Failed to create/send offer', error: e);
      await _handleConnectionFailure(peerId, e);
    }
  }

  Future<void> _handleConnectionFailure(String peerId, Object error) async {
    if (_connectionAttempt < _maxConnectionAttempts) {
      _setState(ConnectionManagerState.reconnecting);

      // Calculate backoff delay
      final delay = Duration(
        milliseconds: (1000 * (_connectionAttempt * _connectionAttempt)).clamp(
          1000,
          30000,
        ),
      );

      _logger.i(
        'WebRTC: Retrying connection in ${delay.inSeconds}s (attempt $_connectionAttempt)',
      );

      await Future.delayed(delay);

      // Check if still should reconnect
      if (_isChatOpen && _currentPeerId == peerId) {
        await _attemptConnection(peerId);
      }
    } else {
      _logger.e('WebRTC: Max connection attempts reached');
      _setState(ConnectionManagerState.failed);
    }
  }

  @override
  Future<void> setChatOpened(String peerId, bool opened) async {
    _isChatOpen = opened;
    _currentPeerId = opened ? peerId : null;

    if (!opened) {
      _stopTimers();
      await _sendPresence(peerId, false);
      await _webrtcService.close();
      _setState(ConnectionManagerState.disconnected);
    } else {
      await connectToPeer(peerId);
      _startPresenceHeartbeat(peerId);
      _startHealthCheck();
    }
  }

  @override
  void onConnectionStateChange(Function(String p1) callback) {
    _connectionStateCallback = callback;

    _webrtcService.onConnectionStateChange((state) {
      _handleWebRTCStateChange(state);
    });
  }

  void _handleWebRTCStateChange(dynamic state) {
    String stateStr;

    if (state is RTCPeerConnectionState) {
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _setState(ConnectionManagerState.connected);
          _connectionAttempt = 0; // Reset on successful connection
          stateStr = 'Connected';
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
          stateStr = 'Connecting';
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          stateStr = 'Disconnected';
          _handleDisconnection();
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          _setState(ConnectionManagerState.failed);
          stateStr = 'Failed';
          _handleConnectionFailedState();
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          _setState(ConnectionManagerState.disconnected);
          stateStr = 'Disconnected';
          break;
        default:
          stateStr = 'Connecting...';
      }
    } else {
      stateStr = state.toString();
    }

    _connectionStateCallback?.call(stateStr);
  }

  void _handleDisconnection() {
    if (_isChatOpen && _currentPeerId != null) {
      _logger.i('WebRTC: Disconnected, will attempt recovery');
      // Don't immediately reconnect - WebRTC might recover on its own
      // The health check will handle reconnection if needed
    }
  }

  void _handleConnectionFailedState() {
    if (_isChatOpen && _currentPeerId != null) {
      _logger.i('WebRTC: Connection failed, attempting reconnection');
      _triggerReconnection();
    }
  }

  void _triggerReconnection() {
    if (_state == ConnectionManagerState.reconnecting) return;
    if (_currentPeerId == null) return;

    _setState(ConnectionManagerState.reconnecting);
    _connectionStateCallback?.call('Reconnecting');

    reconnectWithBackoff(
      connectFn: () async {
        if (_currentPeerId == null || !_isChatOpen) return false;

        await _webrtcService.close();
        await connectToPeer(_currentPeerId!);

        // Wait a bit for connection to establish
        await Future.delayed(const Duration(seconds: 3));

        return _webrtcService.connectionState ==
            RTCPeerConnectionState.RTCPeerConnectionStateConnected;
      },
      config: RetryConfig.webrtc,
      onAttempt: (attempt, delay) {
        _logger.i('WebRTC: Reconnect attempt $attempt');
        _connectionStateCallback?.call('Reconnecting ($attempt)');
      },
      onSuccess: () {
        _logger.i('WebRTC: Reconnected successfully');
        _setState(ConnectionManagerState.connected);
        _connectionStateCallback?.call('Connected');
      },
      onGiveUp: (attempts) {
        _logger.e('WebRTC: Gave up reconnecting after $attempts attempts');
        _setState(ConnectionManagerState.failed);
        _connectionStateCallback?.call('Failed');
      },
    );
  }

  Future<void> _sendPresence(String peerId, bool isOpened) async {
    try {
      final message = SignalingMessage.chatPresence(
        from: _userId,
        to: peerId,
        isOpened: isOpened,
      );
      await _signalingService.sendSignalingMessage(message, peerId);
    } catch (e) {
      _logger.w('Presence send failed: $e');
      // Don't throw - presence is best effort
    }
  }

  void _startPresenceHeartbeat(String peerId) {
    _presenceTimer?.cancel();

    // Send initial presence
    _sendPresence(peerId, true);

    _presenceTimer = Timer.periodic(_presenceInterval, (_) async {
      if (_isChatOpen && _currentPeerId == peerId) {
        await _sendPresence(peerId, true);
      } else {
        _presenceTimer?.cancel();
      }
    });
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();

    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (_) {
      if (!_isChatOpen || _currentPeerId == null) {
        _healthCheckTimer?.cancel();
        return;
      }

      final connectionState = _webrtcService.connectionState;

      // Check if connection is stale
      if (connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        if (_state != ConnectionManagerState.reconnecting) {
          _logger.w('WebRTC: Health check detected disconnection');
          _triggerReconnection();
        }
      }
    });
  }

  void _stopTimers() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    cancelReconnection();
  }

  void _setState(ConnectionManagerState newState) {
    if (_state != newState) {
      _logger.i('ConnectionManager: State change $_state -> $newState');
      _state = newState;
    }
  }

  void dispose() {
    _stopTimers();
  }
}
