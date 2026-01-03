import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logger/logger.dart';
import '../models/signaling_message.dart';
import '../interfaces.dart';
import '../utils/retry_helper.dart';

// SOLID: Single Responsibility - Only handles MQTT signaling
// SOLID: Interface Segregation - Implements focused ISignalingService interface
class SignalingService with ReconnectionMixin implements ISignalingService {
  late MqttServerClient _client;
  final String _userId;
  final String _broker = 'broker.hivemq.com';
  final int _port = 1883;
  Function(SignalingMessage)? _signalingCallback;
  Function(String)? _connectionStateCallback;

  final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  // Offline message queue for reliability
  final List<_PendingSignalingMessage> _pendingMessages = [];
  static const int _maxQueueSize = 100;

  // Connection state
  bool _isConnected = false;
  bool _isManualDisconnect = false;
  StreamSubscription? _updatesSubscription;

  SignalingService(this._userId) {
    _initClient();
  }

  void _initClient() {
    _client = MqttServerClient.withPort(
      _broker,
      'flutter_client_$_userId',
      _port,
    );
    _client.keepAlivePeriod = 20;
    _client.autoReconnect = false; // We handle reconnection ourselves
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribeFail = _onSubscribeFail;
  }

  @override
  String get userId => _userId;

  bool get isConnected => _isConnected;

  /// Set callback for connection state changes
  void onConnectionStateChange(Function(String) callback) {
    _connectionStateCallback = callback;
  }

  @override
  Future<bool> connect() async {
    _isManualDisconnect = false;

    try {
      _logger.i('MQTT: Connecting to $_broker:$_port...');
      _connectionStateCallback?.call('Connecting');

      await RetryHelper.withTimeout(
        () => _client.connect(),
        timeout: const Duration(seconds: 10),
        operationName: 'MQTT connect',
      );

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        _isConnected = true;
        _logger.i('MQTT: Connected successfully');

        final topic = 'p2p-chat/signaling/$_userId';

        // Subscribe with retry
        final subscribeResult = await RetryHelper.retry(
          () async {
            _client.subscribe(topic, MqttQos.atLeastOnce);
            return true;
          },
          config: const RetryConfig(
            maxAttempts: 3,
            initialDelay: Duration(milliseconds: 500),
          ),
        );

        if (!subscribeResult.success) {
          _logger.e('MQTT: Failed to subscribe after retries');
          return false;
        }

        // Cancel previous subscription if any
        _updatesSubscription?.cancel();
        _updatesSubscription = _client.updates?.listen(_onMessage);

        _logger.i('MQTT: Subscribed to $topic');
        _connectionStateCallback?.call('Connected');

        // Flush pending messages
        await _flushPendingMessages();

        resetReconnection();
        return true;
      } else {
        _logger.w(
          'MQTT: Connection failed, status: ${_client.connectionStatus?.state}',
        );
        _connectionStateCallback?.call('Disconnected');
      }
    } on TimeoutException catch (e) {
      _logger.e('MQTT: Connection timeout', error: e);
      _connectionStateCallback?.call('Timeout');
    } catch (e) {
      _logger.e('MQTT: Connection failed', error: e);
      _connectionStateCallback?.call('Error');
    }
    return false;
  }

  @override
  Future<void> disconnect() async {
    _isManualDisconnect = true;
    cancelReconnection();
    _updatesSubscription?.cancel();
    _client.disconnect();
    _isConnected = false;
    _connectionStateCallback?.call('Disconnected');
  }

  @override
  Future<void> sendSignalingMessage(
    SignalingMessage message,
    String targetId,
  ) async {
    if (!_isConnected ||
        _client.connectionStatus?.state != MqttConnectionState.connected) {
      // Queue message for later delivery
      _queueMessage(message, targetId);
      _logger.w('MQTT: Not connected, message queued for $targetId');

      // Trigger reconnection if not already in progress
      if (!isReconnecting && !_isManualDisconnect) {
        _startReconnection();
      }
      return;
    }

    try {
      await _sendMessage(message, targetId);
    } catch (e) {
      _logger.e('MQTT: Failed to send message', error: e);
      _queueMessage(message, targetId);

      // Check if disconnected and trigger reconnection
      if (!_isConnected && !isReconnecting && !_isManualDisconnect) {
        _startReconnection();
      }
      rethrow;
    }
  }

  Future<void> _sendMessage(SignalingMessage message, String targetId) async {
    final topic = 'p2p-chat/signaling/$targetId';
    final payload = jsonEncode(message.toJson());
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    _logger.d('MQTT: Sent ${message.runtimeType} to $targetId');
  }

  @override
  void onSignalingMessage(Function(SignalingMessage p1) callback) {
    _signalingCallback = callback;
  }

  void _onConnected() {
    _logger.i('MQTT: Connected callback');
    _isConnected = true;
    _connectionStateCallback?.call('Connected');
  }

  void _onDisconnected() {
    _logger.w('MQTT: Disconnected callback');
    _isConnected = false;
    _connectionStateCallback?.call('Disconnected');

    // Auto-reconnect if not manually disconnected
    if (!_isManualDisconnect && !isReconnecting) {
      _startReconnection();
    }
  }

  void _onSubscribeFail(String topic) {
    _logger.e('MQTT: Failed to subscribe to $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    for (final msg in event) {
      final message = msg.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        message.payload.message,
      );

      try {
        final data = jsonDecode(payload);
        final signalingMessage = SignalingMessage.fromJson(data);
        _signalingCallback?.call(signalingMessage);
      } catch (e) {
        _logger.e('MQTT: Failed to parse signaling message', error: e);
      }
    }
  }

  void _queueMessage(SignalingMessage message, String targetId) {
    // Remove oldest messages if queue is full
    while (_pendingMessages.length >= _maxQueueSize) {
      _pendingMessages.removeAt(0);
      _logger.w('MQTT: Queue full, dropping oldest message');
    }

    _pendingMessages.add(
      _PendingSignalingMessage(
        message: message,
        targetId: targetId,
        queuedAt: DateTime.now(),
      ),
    );
    _logger.d('MQTT: Message queued (${_pendingMessages.length} pending)');
  }

  Future<void> _flushPendingMessages() async {
    if (_pendingMessages.isEmpty) return;

    _logger.i('MQTT: Flushing ${_pendingMessages.length} pending messages');

    // Copy and clear queue to avoid modification during iteration
    final toSend = List<_PendingSignalingMessage>.from(_pendingMessages);
    _pendingMessages.clear();

    for (final pending in toSend) {
      // Skip messages older than 5 minutes
      if (DateTime.now().difference(pending.queuedAt) >
          const Duration(minutes: 5)) {
        _logger.w('MQTT: Dropping stale message to ${pending.targetId}');
        continue;
      }

      try {
        await _sendMessage(pending.message, pending.targetId);
      } catch (e) {
        // Re-queue failed messages
        _pendingMessages.add(pending);
        _logger.e('MQTT: Failed to flush message, re-queued', error: e);
      }
    }
  }

  void _startReconnection() {
    _connectionStateCallback?.call('Reconnecting');

    reconnectWithBackoff(
      connectFn: () async {
        // Need to reinitialize client after disconnect
        _initClient();
        return await connect();
      },
      config: RetryConfig.mqtt,
      onAttempt: (attempt, delay) {
        _logger.i(
          'MQTT: Reconnection attempt $attempt, next in ${delay.inSeconds}s',
        );
        _connectionStateCallback?.call('Reconnecting ($attempt)');
      },
      onSuccess: () {
        _logger.i('MQTT: Reconnected successfully');
        _connectionStateCallback?.call('Connected');
      },
      onGiveUp: (attempts) {
        _logger.e('MQTT: Gave up reconnecting after $attempts attempts');
        _connectionStateCallback?.call('Failed');
      },
    );
  }

  /// Get pending message count (for debugging/UI)
  int get pendingMessageCount => _pendingMessages.length;
}

class _PendingSignalingMessage {
  final SignalingMessage message;
  final String targetId;
  final DateTime queuedAt;

  _PendingSignalingMessage({
    required this.message,
    required this.targetId,
    required this.queuedAt,
  });
}
