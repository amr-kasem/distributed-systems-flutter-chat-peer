import '../models/signaling_message.dart';
import '../database/database.dart' as db;
import '../interfaces.dart';

typedef Contact = db.Contact;

// SOLID: Single Responsibility - Handles contact management operations
// SOLID: Interface Segregation - Implements focused IContactService interface
class ContactService implements IContactService {
  final ISignalingService _signalingService;
  final IContactRepository _contactRepository;

  Function(String from, String name)? _contactRequestCallback;
  Function(String from, bool accepted, String? name)? _contactResponseCallback;

  ContactService(this._signalingService, this._contactRepository);

  @override
  Future<bool> addContact(String peerId, String name) async {
    final contact = Contact(
      peerId: peerId,
      name: name,
      status: 'request_sent',
      addedAt: DateTime.now(),
      autoAccept: false,
    );

    return await _contactRepository.add(contact);
  }

  @override
  Future<void> acceptContact(String peerId, String name) async {
    await _contactRepository.update(
      peerId,
      Contact(
        peerId: peerId,
        name: name,
        status: 'accepted',
        addedAt: DateTime.now(),
        autoAccept: true,
      ),
    );

    await _signalingService.sendSignalingMessage(
      SignalingMessage.contactResponse(
        from: _signalingService.userId,
        to: peerId,
        accepted: true,
        name: _signalingService.userId, // Using userId as name fallback
      ),
      peerId,
    );
  }

  @override
  Future<void> declineContact(String peerId) async {
    await _contactRepository.softDelete(peerId);

    await _signalingService.sendSignalingMessage(
      SignalingMessage.contactResponse(
        from: _signalingService.userId,
        to: peerId,
        accepted: false,
        name: _signalingService.userId,
      ),
      peerId,
    );
  }

  @override
  Future<void> removeContact(String peerId) async {
    await _contactRepository.softDelete(peerId);
  }

  @override
  Future<void> sendContactRequest(String peerId, String name) async {
    final message = SignalingMessage.contactRequest(
      from: _signalingService.userId,
      to: peerId,
      name: name,
    );
    await _signalingService.sendSignalingMessage(message, peerId);
  }

  @override
  void onContactRequest(Function(String from, String name) callback) {
    _contactRequestCallback = callback;
  }

  @override
  void onContactResponse(
    Function(String from, bool accepted, String? name) callback,
  ) {
    _contactResponseCallback = callback;
  }
}
