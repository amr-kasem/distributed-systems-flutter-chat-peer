import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/message.dart' as models;
import '../interfaces.dart';

typedef MessageStatus = models.MessageStatus;

// SOLID: Single Responsibility - Only handles message persistence
// SOLID: Interface Segregation - Implements focused IMessageRepository interface
class MessageRepository implements IMessageRepository {
  final AppDatabase _database;

  MessageRepository(this._database);

  @override
  Future<void> saveMessage(String userId, String contactId, models.Message message) async {
    final messageEntry = MessagesCompanion.insert(
      senderId: message.senderId,
      receiverId: message.receiverId,
      content: message.content,
      timestamp: message.timestamp,
      status: Value(_messageStatusToString(message.status)),
    );
    await _database.saveMessage(messageEntry);
  }

  @override
  Future<List<models.Message>> getMessages(String userId, String contactId) async {
    final dbMessages = await _database.getMessagesForPeer(contactId, userId);
    return dbMessages.map((m) => models.Message(
      id: m.id.toString(),
      senderId: m.senderId,
      receiverId: m.receiverId,
      content: m.content,
      timestamp: m.timestamp,
      status: _stringToMessageStatus(m.status),
    )).toList();
  }

  @override
  Future<void> updateMessageStatus(String userId, String contactId, String messageId, models.MessageStatus status) async {
    final id = int.tryParse(messageId);
    if (id != null) {
      await _database.updateMessageStatus(id, _messageStatusToString(status));
    }
  }

  @override
  Future<List<models.Message>> getPendingMessages(String userId, String contactId) async {
    final pending = await _database.getPendingMessages(contactId);
    return pending.map((m) => models.Message(
      id: m.id.toString(),
      senderId: m.senderId,
      receiverId: m.receiverId,
      content: m.content,
      timestamp: m.timestamp,
      status: _stringToMessageStatus(m.status),
    )).toList();
  }

  String _messageStatusToString(models.MessageStatus status) {
    switch (status) {
      case models.MessageStatus.pending: return 'pending';
      case models.MessageStatus.sending: return 'sending';
      case models.MessageStatus.sent: return 'sent';
      case models.MessageStatus.delivered: return 'delivered';
      case models.MessageStatus.read: return 'read';
      case models.MessageStatus.failed: return 'failed';
    }
  }

  models.MessageStatus _stringToMessageStatus(String status) {
    switch (status) {
      case 'pending': return models.MessageStatus.pending;
      case 'sending': return models.MessageStatus.sending;
      case 'delivered': return models.MessageStatus.delivered;
      case 'read': return models.MessageStatus.read;
      case 'failed': return models.MessageStatus.failed;
      default: return models.MessageStatus.sent;
    }
  }
}