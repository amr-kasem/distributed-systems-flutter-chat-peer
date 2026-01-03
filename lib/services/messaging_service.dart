import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import '../models/message.dart' as models;
import '../interfaces.dart';

// SOLID: Single Responsibility - Handles message sending and receiving operations
// SOLID: Interface Segregation - Implements focused IMessageService interface
class MessagingService implements IMessageService {
  final IWebRTCService _webrtcService;
  final IMessageRepository _messageRepository;
  final String _userId;
  String _peerId;

  final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  Function(models.Message)? _messageReceivedCallback;
  Function(String messageId, models.MessageStatus status)?
  _statusUpdateCallback;

  // Retry configuration
  static const int _maxMessageRetries = 3;
  final Map<String, int> _retryCount = {};
  final Map<String, Timer> _retryTimers = {};

  MessagingService(
    this._webrtcService,
    this._messageRepository,
    this._userId,
    this._peerId,
  ) {
    _webrtcService.onMessage(_onWebRTCMessage);
  }

  @override
  void setCurrentPeer(String peerId) {
    _peerId = peerId;
    // Clear retry state when peer changes
    _cancelAllRetries();
  }

  @override
  Future<void> sendPendingMessages() async {
    if (_peerId.isEmpty) return;

    final pendingMessages = await _messageRepository.getPendingMessages(
      _userId,
      _peerId,
    );
    if (pendingMessages.isEmpty) return;

    _logger.i(
      'Messaging: Flushing ${pendingMessages.length} pending messages to $_peerId',
    );

    for (final message in pendingMessages) {
      await _sendWithRetry(message);
    }
  }

  @override
  Future<void> sendMessage(String content) async {
    // 1. Create message model
    final message = models.Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _userId,
      receiverId: _peerId,
      content: content,
      timestamp: DateTime.now(),
      status: models.MessageStatus.pending,
    );

    // 2. Save as pending
    await _messageRepository.saveMessage(_userId, _peerId, message);

    // 3. Emit to UI
    _messageReceivedCallback?.call(message);

    // 4. Send with retry logic
    await _sendWithRetry(message);
  }

  Future<void> _sendWithRetry(models.Message message) async {
    final messageId = message.id;

    // Check if already retrying
    if (_retryTimers.containsKey(messageId)) {
      return;
    }

    // Initialize retry count
    _retryCount[messageId] = _retryCount[messageId] ?? 0;

    if (_webrtcService.connectionState !=
        RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      _logger.d(
        'Messaging: Not connected, message $messageId will be sent when connected',
      );
      return;
    }

    try {
      await _webrtcService.sendMessage(message.content);

      // Update status to sent
      await _messageRepository.updateMessageStatus(
        _userId,
        _peerId,
        messageId,
        models.MessageStatus.sent,
      );

      // Emit update
      _messageReceivedCallback?.call(
        message.copyWith(status: models.MessageStatus.sent),
      );
      _statusUpdateCallback?.call(messageId, models.MessageStatus.sent);

      // Clear retry state
      _retryCount.remove(messageId);
      _retryTimers[messageId]?.cancel();
      _retryTimers.remove(messageId);

      _logger.d('Messaging: Message $messageId sent successfully');
    } catch (e) {
      _logger.e('Messaging: Failed to send message $messageId', error: e);
      await _handleSendFailure(message);
    }
  }

  Future<void> _handleSendFailure(models.Message message) async {
    final messageId = message.id;
    final attempts = (_retryCount[messageId] ?? 0) + 1;
    _retryCount[messageId] = attempts;

    if (attempts >= _maxMessageRetries) {
      _logger.e(
        'Messaging: Message $messageId failed after $attempts attempts',
      );

      // Mark as failed
      await _messageRepository.updateMessageStatus(
        _userId,
        _peerId,
        messageId,
        models.MessageStatus.failed,
      );

      _messageReceivedCallback?.call(
        message.copyWith(status: models.MessageStatus.failed),
      );
      _statusUpdateCallback?.call(messageId, models.MessageStatus.failed);

      // Clear retry state
      _retryCount.remove(messageId);
      _retryTimers.remove(messageId);
      return;
    }

    // Calculate backoff delay
    final delay = Duration(
      milliseconds: (1000 * attempts * attempts).clamp(1000, 15000),
    );

    _logger.i(
      'Messaging: Retrying message $messageId in ${delay.inSeconds}s (attempt $attempts)',
    );

    // Schedule retry
    _retryTimers[messageId]?.cancel();
    _retryTimers[messageId] = Timer(delay, () async {
      _retryTimers.remove(messageId);
      await _sendWithRetry(message);
    });
  }

  @override
  void onMessageReceived(Function(models.Message p1) callback) {
    _messageReceivedCallback = callback;
  }

  /// Optional callback for message status updates
  void onMessageStatusUpdate(
    Function(String messageId, models.MessageStatus status) callback,
  ) {
    _statusUpdateCallback = callback;
  }

  void _onWebRTCMessage(String content) {
    final message = models.Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _peerId,
      receiverId: _userId,
      content: content,
      timestamp: DateTime.now(),
      status: models.MessageStatus.delivered,
    );

    // Save to repository (fire and forget with error handling)
    _messageRepository.saveMessage(_userId, _peerId, message).catchError((e) {
      _logger.e('Messaging: Failed to save received message', error: e);
    });

    _messageReceivedCallback?.call(message);
  }

  void _cancelAllRetries() {
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();
    _retryCount.clear();
  }

  void dispose() {
    _cancelAllRetries();
  }
}
