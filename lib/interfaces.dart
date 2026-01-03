import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'models/message.dart' as models;
import 'models/signaling_message.dart';
import 'database/database.dart' as db;

// SOLID Principles: Interface Segregation + Dependency Inversion
abstract class IMessageRepository {
  Future<void> saveMessage(
    String userId,
    String contactId,
    models.Message message,
  );
  Future<List<models.Message>> getMessages(String userId, String contactId);
  Future<void> updateMessageStatus(
    String userId,
    String contactId,
    String messageId,
    models.MessageStatus status,
  );
  Future<List<models.Message>> getPendingMessages(
    String userId,
    String contactId,
  );
}

abstract class IContactRepository {
  Future<List<db.Contact>> getAll();
  Future<db.Contact?> get(String id);
  Future<bool> add(db.Contact contact);
  Future<void> update(String id, db.Contact contact);
  Future<void> delete(String id);
  Future<void> softDelete(String id);
}

abstract class ISignalingService {
  Future<bool> connect();
  Future<void> disconnect();
  Future<void> sendSignalingMessage(SignalingMessage message, String targetId);
  void onSignalingMessage(Function(SignalingMessage) callback);
  String get userId;
}

abstract class IWebRTCService {
  Future<dynamic> createOffer();
  Future<dynamic> createAnswer();
  Future<void> rollbackLocalDescription();
  Future<void> setRemoteDescription(dynamic description);
  Future<void> addIceCandidate(dynamic candidate);
  Future<void> sendMessage(String content);
  Future<void> close();
  dynamic get connectionState;
  dynamic get signalingState;
  void onMessage(Function(String) callback);
  void onIceCandidate(Function(dynamic) callback);
  void onConnectionStateChange(Function(dynamic) callback);
}

abstract class IMessageService {
  Future<void> sendMessage(String content);
  void onMessageReceived(Function(models.Message) callback);
  void setCurrentPeer(String peerId);
  Future<void> sendPendingMessages();
}

abstract class IContactService {
  Future<bool> addContact(String peerId, String name);
  Future<void> acceptContact(String peerId, String name);
  Future<void> declineContact(String peerId);
  Future<void> removeContact(String peerId);
  Future<void> sendContactRequest(String peerId, String name);
  void onContactRequest(Function(String from, String name) callback);
  void onContactResponse(
    Function(String from, bool accepted, String? name) callback,
  );
}

abstract class IConnectionManager {
  Future<void> connectToPeer(String peerId);
  Future<void> setChatOpened(String peerId, bool opened);
  void onConnectionStateChange(Function(String) callback);
}

abstract class IChatCoordinator {
  Future<bool> initialize();
  Future<void> sendMessage(String content);
  Future<void> selectContact(db.Contact contact);
  Future<bool> addContact(String peerId, String name);
  Future<void> acceptContact(String peerId, String name);
  Future<void> declineContact(String peerId);
  Future<void> removeContact(String peerId);
  Future<void> dispose();
  void onMessageReceived(Function(models.Message) callback);
  void onConnectionStateChange(Function(String) callback);
  void onContactRequest(Function(String from, String name) callback);
  void onContactResponse(
    Function(String from, bool accepted, String? name) callback,
  );
  String get userId;
}
