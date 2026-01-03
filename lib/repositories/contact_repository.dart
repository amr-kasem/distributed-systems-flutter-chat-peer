import 'package:drift/drift.dart' show Value;
import '../database/database.dart' as db;
import '../interfaces.dart';

typedef Contact = db.Contact;

// SOLID: Single Responsibility - Only handles contact persistence
// SOLID: Interface Segregation - Implements focused IContactRepository interface
class ContactRepository implements IContactRepository {
  final db.AppDatabase _database;

  ContactRepository(this._database);

  @override
  Future<List<Contact>> getAll() async {
    return await _database.getAllContacts();
  }

  @override
  Future<Contact?> get(String id) async {
    return await _database.getContactById(id);
  }

  @override
  Future<bool> add(Contact contact) async {
    try {
      final existing = await get(contact.peerId);
      if (existing != null) {
        if (existing.status == 'deleted' ||
            existing.status == 'remotely_deleted') {
          await update(contact.peerId, contact);
          return true;
        }
        return false;
      }

      await _database.addContact(
        db.ContactsCompanion.insert(
          peerId: contact.peerId,
          name: contact.name,
          addedAt: contact.addedAt,
          status: Value(contact.status),
          autoAccept: Value(
            true,
          ), // Ensuring this is set, though service might override logic
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> update(String id, Contact contact) async {
    await _database.updateContact(
      db.ContactsCompanion(
        peerId: Value(id),
        name: Value(contact.name),
        status: Value(contact.status),
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    await _database.deleteContact(id);
  }

  @override
  Future<void> softDelete(String id) async {
    await _database.updateContact(
      db.ContactsCompanion(peerId: Value(id), status: Value('deleted')),
    );
  }
}
