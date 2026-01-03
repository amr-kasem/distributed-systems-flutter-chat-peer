import 'dart:async';
import 'package:logger/logger.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../interfaces.dart';
import '../utils/retry_helper.dart';

// SOLID: Single Responsibility - Only handles WebRTC peer connections
// SOLID: Interface Segregation - Implements focused IWebRTCService interface
class WebRtcService implements IWebRTCService {
  final _logger = Logger();
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  Function(String)? _messageCallback;
  Function(dynamic)? _iceCandidateCallback;
  Function(dynamic)? _connectionStateCallback;
  final List<RTCIceCandidate> _pendingCandidates = [];

  // Stability improvements
  Timer? _connectionTimeoutTimer;
  int _iceRestartAttempts = 0;
  static const int _maxIceRestartAttempts = 3;
  static const Duration _connectionTimeout = Duration(seconds: 30);
  bool _isClosing = false;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
    'iceCandidatePoolSize': 10,
  };

  @override
  Future<dynamic> createOffer() async {
    _cancelConnectionTimeout();
    await _initializePeerConnection();

    // Create Data Channel for chat
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit()..ordered = true;
    _dataChannel = await _peerConnection!.createDataChannel(
      'chat',
      dataChannelDict,
    );
    _setupDataChannel(_dataChannel!);

    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _logger.i('WebRTC: Created Offer SDP:\n${offer.sdp}');

      _startConnectionTimeout();
      return {'type': 'offer', 'sdp': offer.sdp};
    } catch (e) {
      _logger.e('WebRTC: Failed to create offer', error: e);
      rethrow;
    }
  }

  @override
  Future<void> rollbackLocalDescription() async {
    if (_peerConnection == null) return;
    _logger.i('WebRTC: Rolling back local description');
    try {
      await _peerConnection!.setLocalDescription(
        RTCSessionDescription('', 'rollback'),
      );
    } catch (e) {
      _logger.e('WebRTC: Rollback failed', error: e);
      // If rollback fails, try to close and reinitialize
      await _resetConnection();
    }
  }

  @override
  Future<dynamic> createAnswer() async {
    // PeerConnection should already be initialized by setRemoteDescription
    if (_peerConnection == null) {
      await _initializePeerConnection();
    }

    try {
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _logger.i('WebRTC: Created Answer SDP:\n${answer.sdp}');

      return {'type': 'answer', 'sdp': answer.sdp};
    } catch (e) {
      _logger.e('WebRTC: Failed to create answer', error: e);
      rethrow;
    }
  }

  @override
  Future<void> setRemoteDescription(dynamic description) async {
    if (_peerConnection == null) {
      await _initializePeerConnection();
    }

    // Parse the description if it came from the signaling service
    String sdp = description['sdp'];
    String type = description['type'];
    _logger.i('WebRTC: Setting Remote Description ($type):\n$sdp');

    try {
      await _setRemoteDescriptionWithRetry(sdp, type);
    } catch (e) {
      _logger.e(
        'WebRTC: Failed to set remote description after retries',
        error: e,
      );
      rethrow;
    }

    // Drain the candidate buffer
    await _drainPendingCandidates();
  }

  Future<void> _setRemoteDescriptionWithRetry(String sdp, String type) async {
    final result = await RetryHelper.retry(
      () async {
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(sdp, type),
        );
        return true;
      },
      config: RetryConfig.webrtc,
      retryIf: (error) {
        final errorStr = error.toString();
        // Retry on SDP mismatch errors for offers
        return type == 'offer' &&
            (errorStr.contains('m-lines') ||
                errorStr.contains('Failed to set remote'));
      },
      onRetry: (attempt, error, delay) async {
        _logger.w(
          'WebRTC: Retrying setRemoteDescription (attempt $attempt): $error',
        );

        // Reset connection before retry
        final savedCandidates = List<RTCIceCandidate>.from(_pendingCandidates);
        await _resetConnection();
        _pendingCandidates.addAll(savedCandidates);
        await _initializePeerConnection();
      },
    );

    if (!result.success) {
      throw result.error ?? Exception('Failed to set remote description');
    }
  }

  Future<void> _drainPendingCandidates() async {
    for (var candidate in _pendingCandidates) {
      try {
        _logger.i(
          'WebRTC: Adding buffered ICE candidate: ${candidate.candidate}',
        );
        await _peerConnection!.addCandidate(candidate);
      } catch (e) {
        _logger.e('WebRTC: Failed to add buffered candidate', error: e);
      }
    }
    _pendingCandidates.clear();
  }

  @override
  Future<void> addIceCandidate(dynamic candidate) async {
    if (_peerConnection == null) return;

    final iceCandidate = RTCIceCandidate(
      candidate['candidate'],
      candidate['sdpMid'],
      candidate['sdpMLineIndex'],
    );

    try {
      final remoteDesc = await _peerConnection!.getRemoteDescription();
      if (remoteDesc == null) {
        _logger.i(
          'WebRTC: Buffering ICE candidate (remote description not set)',
        );
        _pendingCandidates.add(iceCandidate);
        return;
      }

      await _peerConnection!.addCandidate(iceCandidate);
    } catch (e) {
      _logger.e('WebRTC: Failed to add ICE candidate', error: e);
      // Buffer the candidate in case of error
      _pendingCandidates.add(iceCandidate);
    }
  }

  @override
  Future<void> sendMessage(String content) async {
    if (_dataChannel == null) {
      _logger.w('WebRTC: No data channel available');
      throw Exception('Data channel not available');
    }

    if (_dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      _logger.w(
        'WebRTC: Data channel is not open. State: ${_dataChannel!.state}',
      );
      throw Exception('Data channel not open');
    }

    try {
      await _dataChannel!.send(RTCDataChannelMessage(content));
    } catch (e) {
      _logger.e('WebRTC: Failed to send message', error: e);
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    if (_isClosing) return;
    _isClosing = true;

    _cancelConnectionTimeout();
    _iceRestartAttempts = 0;

    try {
      await _dataChannel?.close();
    } catch (e) {
      _logger.e('WebRTC: Error closing data channel', error: e);
    }

    try {
      await _peerConnection?.close();
    } catch (e) {
      _logger.e('WebRTC: Error closing peer connection', error: e);
    }

    _peerConnection = null;
    _dataChannel = null;
    _pendingCandidates.clear();
    _isClosing = false;
  }

  Future<void> _resetConnection() async {
    _cancelConnectionTimeout();
    await close();
  }

  /// Restart ICE to recover from connection failures
  Future<void> restartIce() async {
    if (_peerConnection == null) {
      _logger.w('WebRTC: Cannot restart ICE - no peer connection');
      return;
    }

    if (_iceRestartAttempts >= _maxIceRestartAttempts) {
      _logger.e('WebRTC: Max ICE restart attempts reached');
      _connectionStateCallback?.call('Failed');
      return;
    }

    _iceRestartAttempts++;
    _logger.i('WebRTC: Restarting ICE (attempt $_iceRestartAttempts)');

    try {
      await _peerConnection!.restartIce();
      _startConnectionTimeout();
    } catch (e) {
      _logger.e('WebRTC: ICE restart failed', error: e);
    }
  }

  @override
  dynamic get connectionState {
    return _peerConnection?.connectionState ??
        RTCPeerConnectionState.RTCPeerConnectionStateClosed;
  }

  @override
  dynamic get signalingState {
    return _peerConnection?.signalingState ??
        RTCSignalingState.RTCSignalingStateStable;
  }

  @override
  void onMessage(Function(String p1) callback) {
    _messageCallback = callback;
  }

  @override
  void onConnectionStateChange(Function(dynamic p1) callback) {
    _connectionStateCallback = callback;
  }

  @override
  void onIceCandidate(Function(dynamic p1) callback) {
    _iceCandidateCallback = callback;
  }

  void _startConnectionTimeout() {
    _cancelConnectionTimeout();
    _connectionTimeoutTimer = Timer(_connectionTimeout, () {
      _logger.w('WebRTC: Connection timeout');
      if (_peerConnection?.connectionState !=
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _connectionStateCallback?.call('Timeout');
        // Try ICE restart as recovery
        restartIce();
      }
    });
  }

  void _cancelConnectionTimeout() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
  }

  Future<void> _initializePeerConnection() async {
    if (_peerConnection != null) return;

    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (_iceCandidateCallback != null) {
        _iceCandidateCallback!({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      _logger.i('WebRTC Connection State: $state');
      _handleConnectionState(state);
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      _logger.i('WebRTC ICE Connection State: $state');
      _handleIceConnectionState(state);
    };

    _peerConnection!.onDataChannel = (RTCDataChannel channel) {
      _logger.i('WebRTC: Received Data Channel');
      _setupDataChannel(channel);
    };
  }

  void _handleConnectionState(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        _cancelConnectionTimeout();
        _iceRestartAttempts = 0;
        _connectionStateCallback?.call('Connected');
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        _connectionStateCallback?.call('Connecting');
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        _connectionStateCallback?.call('Disconnected');
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        _cancelConnectionTimeout();
        _connectionStateCallback?.call('Failed');
        // Attempt ICE restart on failure
        restartIce();
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
        _cancelConnectionTimeout();
        _connectionStateCallback?.call('Disconnected');
        break;
      default:
        _connectionStateCallback?.call('Connecting...');
    }
  }

  void _handleIceConnectionState(RTCIceConnectionState state) {
    switch (state) {
      case RTCIceConnectionState.RTCIceConnectionStateFailed:
        _logger.w('WebRTC: ICE connection failed, attempting restart');
        restartIce();
        break;
      case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        _logger.w('WebRTC: ICE disconnected, waiting for recovery...');
        // Give it some time to recover before restarting
        Future.delayed(const Duration(seconds: 5), () {
          if (_peerConnection?.iceConnectionState ==
              RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
            restartIce();
          }
        });
        break;
      default:
        break;
    }
  }

  void _setupDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;
    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      if (message.isBinary) {
        // Handle binary if needed, for now assuming text
        _logger.d('Ignored binary message');
        return;
      }
      if (_messageCallback != null) {
        _messageCallback!(message.text);
      }
    };

    _dataChannel!.onDataChannelState = (RTCDataChannelState state) {
      _logger.i('WebRTC Data Channel State: $state');
      if (state == RTCDataChannelState.RTCDataChannelClosed) {
        _connectionStateCallback?.call('Disconnected');
      }
    };
  }
}
