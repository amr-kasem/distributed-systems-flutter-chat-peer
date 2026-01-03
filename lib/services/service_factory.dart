import 'dart:math';
import '../database/database.dart';
import '../repositories/message_repository.dart';
import '../repositories/contact_repository.dart';
import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';
import '../services/connection_manager.dart';
import '../services/messaging_service.dart';
import '../services/contact_service.dart';
import '../services/chat_coordinator.dart';
import '../interfaces.dart';

String generateId() {
  final random = Random();
  final letters = List.generate(
    3,
    (_) => String.fromCharCode(65 + random.nextInt(26)),
  ).join();
  final digits = List.generate(3, (_) => random.nextInt(10)).join();
  return '$letters-$digits';
}

// SOLID: Dependency Inversion - Factory creates and wires dependencies
class ServiceFactory {
  static Future<IChatCoordinator> createChatCoordinator({
    String? userId,
    AppDatabase? database,
  }) async {
    // Create database if not injected
    final dbInstance = database ?? AppDatabase();

    String actualUserId;
    if (userId != null) {
      actualUserId = userId;
    } else {
      final savedId = await dbInstance.getSetting('user_id');
      if (savedId != null) {
        actualUserId = savedId;
      } else {
        actualUserId = generateId();
        await dbInstance.setSetting('user_id', actualUserId);
      }
    }

    // Create repositories
    final messageRepository = MessageRepository(dbInstance);
    final contactRepository = ContactRepository(dbInstance);

    // Create low-level services
    final signalingService = SignalingService(actualUserId);
    final webrtcService = WebRtcService();

    // Create domain services
    final connectionManager = ConnectionManager(
      signalingService,
      webrtcService,
      actualUserId,
    );
    final messagingService = MessagingService(
      webrtcService,
      messageRepository,
      actualUserId,
      '',
    );
    final contactService = ContactService(signalingService, contactRepository);

    // Create coordinator
    return ChatCoordinator(
      signalingService,
      webrtcService,
      messageRepository,
      contactRepository,
      connectionManager,
      messagingService,
      contactService,
      actualUserId,
    );
  }
}
