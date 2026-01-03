import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Messages table
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get senderId => text()();
  TextColumn get receiverId => text()();
  TextColumn get content => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
}

// Peers table
class Peers extends Table {
  TextColumn get id => text()();
  TextColumn get username => text()();
  DateTimeColumn get lastSeen => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('offline'))();

  @override
  Set<Column> get primaryKey => {id};
}

// Contacts table
class Contacts extends Table {
  TextColumn get peerId => text()();
  TextColumn get name => text()();
  DateTimeColumn get addedAt => dateTime()();
  BoolColumn get autoAccept => boolean().withDefault(const Constant(true))();
  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {peerId};
}

// Settings table for app configuration
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Messages, Peers, Contacts, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Development reset: just drop and recreate everything
      for (final table in allTables) {
        await m.drop(table);
        await m.create(table);
      }
    },
  );
  // --- Message Queries ---

  /// Gets chat history for a specific peer
  Future<List<Message>> getMessagesForPeer(String peerId, String myId) {
    return (select(messages)
          ..where(
            (t) =>
                (t.senderId.equals(peerId) & t.receiverId.equals(myId)) |
                (t.senderId.equals(myId) & t.receiverId.equals(peerId)),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
        .get();
  }

  Future<int> saveMessage(MessagesCompanion message) =>
      into(messages).insert(message);

  Future<void> updateMessageStatus(int id, String status) {
    return (update(messages)..where((t) => t.id.equals(id))).write(
      MessagesCompanion(status: Value(status)),
    );
  }

  Future<List<Message>> getPendingMessages(String receiverId) {
    return (select(messages)..where(
          (t) => t.receiverId.equals(receiverId) & t.status.equals('pending'),
        ))
        .get();
  }

  Future<int> deleteHistory(String peerId, String myId) {
    return (delete(messages)..where(
          (t) =>
              (t.senderId.equals(peerId) & t.receiverId.equals(myId)) |
              (t.senderId.equals(myId) & t.receiverId.equals(peerId)),
        ))
        .go();
  }

  // --- Contact Queries ---

  Future<List<Contact>> getAllContacts() => select(contacts).get();

  Future<Contact?> getContactById(String peerId) => (select(
    contacts,
  )..where((c) => c.peerId.equals(peerId))).getSingleOrNull();

  Future<bool> isContact(String peerId) async {
    final contact = await getContactById(peerId);
    return contact != null;
  }

  Future<int> addContact(ContactsCompanion contact) =>
      into(contacts).insert(contact);

  Future<int> updateContact(ContactsCompanion contact) {
    return (update(
      contacts,
    )..where((c) => c.peerId.equals(contact.peerId.value))).write(contact);
  }

  Future<int> deleteContact(String peerId) =>
      (delete(contacts)..where((c) => c.peerId.equals(peerId))).go();

  // --- Settings Queries ---

  Future<String?> getSetting(String key) async {
    final setting = await (select(
      settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return setting?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion(key: Value(key), value: Value(value)),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'chat_app_v4.sqlite'));
    return NativeDatabase(file);
  });
}
