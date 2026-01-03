import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import '../models/message.dart' as models;
import '../models/signaling_message.dart';
import '../database/database.dart' as db;
import '../interfaces.dart';
import '../utils/retry_helper.dart';

typedef Contact = db.Contact;

// SOLID: Single Responsibility - Coordinates all chat services
// SOLID: Dependency Inversion - Depends on abstractions, not concretions
class ChatCoordinator implements IChatCoordinator {
  final ISignalingService _signalingService;
  final IWebRTCService _webrtcService;
  final IMessageRepository _messageRepository;
  final IContactRepository _contactRepository;
  final IConnectionManager _connectionManager;
  final IMessageService _messagingService;
  final IContactService _contactService;
  final String _userId;
  String? _currentPeerId;

  final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  final StreamController<models.Message> _messageController =
      StreamController<models.Message>.broadcast();
  final StreamController<String> _connectionStateController =
      StreamController<String>.broadcast();
  final StreamController<String> _contactRequestController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _contactResponseController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Operation timeouts
  static const Duration _operationTimeout = Duration(seconds: 30);

  ChatCoordinator(
    this._signalingService,
    this._webrtcService,
    this._messageRepository,
    this._contactRepository,
    this._connectionManager,
    this._messagingService,
    this._contactService,
    this._userId,
  );

  @override
  String get userId => _userId;

  /// Subscribe to errors for UI notification
  Stream<String> get errors => _errorController.stream;

  @override
  Future<bool> initialize() async {
    try {
      final connected = await RetryHelper.withTimeout(
        () => _signalingService.connect(),
        timeout: const Duration(seconds: 15),
        operationName: 'Signaling connect',
      );

      _setupSignalingHandlers();
      _setupWebRTCHandlers();
      _setupMessagingHandlers();
      _setupContactHandlers();

      return connected;
    } catch (e) {
      _logger.e('Coordinator: Initialization failed', error: e);
      _errorController.add('Initialization failed: $e');
      return false;
    }
  }

  @override
  Future<void> sendMessage(String content) async {
    try {
      await RetryHelper.withTimeout(
        () => _messagingService.sendMessage(content),
        timeout: _operationTimeout,
        operationName: 'Send message',
      );
    } catch (e) {
      _logger.e('Coordinator: Failed to send message', error: e);
      _errorController.add('Failed to send message: $e');
      rethrow;
    }
  }

  @override
  Future<void> selectContact(Contact contact) async {
    try {
      _currentPeerId = contact.peerId;
      _messagingService.setCurrentPeer(contact.peerId);

      await _connectionManager.setChatOpened(contact.peerId, true);

      // Load message history
      final messages = await _messageRepository.getMessages(
        _userId,
        contact.peerId,
      );
      for (final message in messages) {
        _messageController.add(message);
      }
    } catch (e) {
      _logger.e('Coordinator: Failed to select contact', error: e);
      _errorController.add('Failed to open chat: $e');
      rethrow;
    }
  }

  @override
  Future<bool> addContact(String peerId, String name) async {
    try {
      final contact = Contact(
        peerId: peerId,
        name: name,
        status: 'request_sent',
        addedAt: DateTime.now(),
        autoAccept: true,
      );

      final success = await _contactRepository.add(contact);
      if (success) {
        await _contactService.sendContactRequest(peerId, name);
      }
      return success;
    } catch (e) {
      _logger.e('Coordinator: Failed to add contact', error: e);
      _errorController.add('Failed to add contact: $e');
      return false;
    }
  }

  @override
  Future<void> acceptContact(String peerId, String name) async {
    try {
      await _contactService.acceptContact(peerId, name);
    } catch (e) {
      _logger.e('Coordinator: Failed to accept contact', error: e);
      _errorController.add('Failed to accept contact: $e');
      rethrow;
    }
  }

  @override
  Future<void> declineContact(String peerId) async {
    try {
      await _contactService.declineContact(peerId);
    } catch (e) {
      _logger.e('Coordinator: Failed to decline contact', error: e);
      _errorController.add('Failed to decline contact: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeContact(String peerId) async {
    try {
      await _contactService.removeContact(peerId);
    } catch (e) {
      _logger.e('Coordinator: Failed to remove contact', error: e);
      _errorController.add('Failed to remove contact: $e');
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _signalingService.disconnect();
      await _webrtcService.close();
    } catch (e) {
      _logger.e('Coordinator: Error during dispose', error: e);
    } finally {
      _messageController.close();
      _connectionStateController.close();
      _contactRequestController.close();
      _contactResponseController.close();
      _errorController.close();
    }
  }

  @override
  void onMessageReceived(Function(models.Message p1) callback) {
    _messageController.stream.listen(callback);
  }

  @override
  void onConnectionStateChange(Function(String p1) callback) {
    _connectionStateController.stream.listen(callback);
  }

  @override
  void onContactRequest(Function(String from, String name) callback) {
    _contactRequestController.stream.listen((data) {
      // Parse data and call callback
      final parts = data.split('|');
      if (parts.length >= 2) {
        callback(parts[0], parts[1]);
      }
    });
  }

  @override
  void onContactResponse(
    Function(String from, bool accepted, String? name) callback,
  ) {
    _contactResponseController.stream.listen((data) {
      callback(data['from'], data['accepted'], data['name']);
    });
  }

  /// Subscribe to error events
  void onError(Function(String error) callback) {
    _errorController.stream.listen(callback);
  }

  void _setupSignalingHandlers() {
    _signalingService.onSignalingMessage((message) {
      _handleSignalingMessageSafe(message);
    });
  }

  void _setupWebRTCHandlers() {
    _webrtcService.onIceCandidate((candidate) {
      _safeAsync(() async {
        if (_currentPeerId != null) {
          final message = SignalingMessage.iceCandidate(
            from: _userId,
            to: _currentPeerId!,
            candidate: candidate,
          );
          await _signalingService.sendSignalingMessage(
            message,
            _currentPeerId!,
          );
        }
      });
    });

    _connectionManager.onConnectionStateChange((state) {
      _connectionStateController.add(state);
      if (state == 'Connected') {
        _safeAsync(() => _messagingService.sendPendingMessages());
      }
    });
  }

  void _setupMessagingHandlers() {
    _messagingService.onMessageReceived((message) {
      _messageController.add(message);
    });
  }

  void _setupContactHandlers() {
    _contactService.onContactRequest((from, name) {
      _contactRequestController.add('$from|$name');
    });

    _contactService.onContactResponse((from, accepted, name) {
      _contactResponseController.add({
        'from': from,
        'accepted': accepted,
        'name': name,
      });
    });
  }

  /// Wrapper for async handlers with error boundary
  void _safeAsync(Future<void> Function() operation) {
    operation().catchError((e) {
      _logger.e('Coordinator: Async operation failed', error: e);
      _errorController.add('Operation failed: $e');
    });
  }

  void _handleSignalingMessageSafe(SignalingMessage message) {
    try {
      message.when(
        offer: (from, to, sdp) => _safeAsync(() => _handleOffer(message)),
        answer: (from, to, sdp) => _safeAsync(() => _handleAnswer(message)),
        iceCandidate: (from, to, candidate) =>
            _safeAsync(() => _handleIceCandidate(message)),
        contactRequest: (from, to, name) =>
            _contactRequestController.add('$from|$name'),
        contactResponse: (from, to, accepted, name) =>
            _contactResponseController.add({
              'from': from,
              'accepted': accepted,
              'name': name,
            }),
        chatPresence: (from, to, isOpened) {
          if (isOpened) {
            _safeAsync(() => _connectionManager.connectToPeer(from));
          }
        },
        contactDeleted: (from, to) => null,
      );
    } catch (e) {
      _logger.e('Coordinator: Failed to handle signaling message', error: e);
      _errorController.add('Signaling error: $e');
    }
  }

  Future<void> _handleOffer(SignalingMessage message) async {
    await message.maybeWhen(
      offer: (from, to, sdp) async {
        // Polite Peer Pattern: Handle Glare
        final signalingState = _webrtcService.signalingState;

        if (signalingState ==
            RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
          final isImpolite = _userId.compareTo(from) > 0;

          if (isImpolite) {
            _logger.i(
              'WebRTC: Glare detected. I am Impolite ($userId > $from). Ignoring their offer.',
            );
            return;
          } else {
            _logger.i(
              'WebRTC: Glare detected. I am Polite ($userId < $from). Accepting their offer.',
            );
            await _webrtcService.rollbackLocalDescription();
          }
        }

        _currentPeerId = from;
        _messagingService.setCurrentPeer(from);

        try {
          await _webrtcService.setRemoteDescription(sdp);

          final answer = await _webrtcService.createAnswer();
          final answerMsg = SignalingMessage.answer(
            from: _userId,
            to: from,
            sdp: answer,
          );
          await _signalingService.sendSignalingMessage(answerMsg, from);
        } catch (e) {
          _logger.e('Coordinator: Failed to handle offer', error: e);
          _errorController.add('Failed to process offer: $e');
        }
      },
      orElse: () async {},
    );
  }

  Future<void> _handleAnswer(SignalingMessage message) async {
    await message.maybeWhen(
      answer: (from, to, sdp) async {
        try {
          await _webrtcService.setRemoteDescription(sdp);
        } catch (e) {
          _logger.e('Coordinator: Failed to handle answer', error: e);
          _errorController.add('Failed to process answer: $e');
        }
      },
      orElse: () async {},
    );
  }

  Future<void> _handleIceCandidate(SignalingMessage message) async {
    await message.maybeWhen(
      iceCandidate: (from, to, candidate) async {
        try {
          await _webrtcService.addIceCandidate(candidate);
        } catch (e) {
          _logger.e('Coordinator: Failed to add ICE candidate', error: e);
          // Don't emit error for ICE candidates as they're often transient
        }
      },
      orElse: () async {},
    );
  }
}
