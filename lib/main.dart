import 'dart:async';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'database/database.dart' as db;
import 'models/message.dart' as models;
import 'services/service_factory.dart';
import 'theme/app_theme.dart';
import 'widgets/sidebar.dart';
import 'widgets/chat_view.dart';
import 'widgets/contact_dialog.dart';
import 'interfaces.dart';

typedef Contact = db.Contact;

void main() {
  runApp(const P2PChatApp());
}

class P2PChatApp extends StatelessWidget {
  const P2PChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P2P Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late db.AppDatabase _database;
  IChatCoordinator? _coordinator;

  String _userId = '...';
  List<Contact> _contacts = [];
  List<models.Message> _messages = [];
  Contact? _selectedContact;
  String _chatStatus = 'Initializing...';
  bool _isSidebarHidden = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _database = db.AppDatabase();

      // SOLID: Dependency Inversion - Factory creates and wires all dependencies
      _coordinator = await ServiceFactory.createChatCoordinator(
        database: _database,
      );

      final initialized = await _coordinator!.initialize();

      _userId = _coordinator!.userId;

      // Set up event handlers
      _coordinator!.onMessageReceived((msg) {
        if (mounted) {
          setState(() {
            final index = _messages.indexWhere((m) => m.id == msg.id);
            if (index != -1) {
              // Create new list with updated message
              _messages = List.from(_messages)..[index] = msg;
            } else {
              // Create new list with new message
              _messages = List.from(_messages)..add(msg);
            }
          });
        }
      });

      _coordinator!.onConnectionStateChange((state) {
        if (mounted) setState(() => _chatStatus = state);
      });

      _coordinator!.onContactRequest((from, name) {
        _handleIncomingContactRequest(from, name);
      });

      _coordinator!.onContactResponse((from, accepted, name) {
        _handleContactResponse(from, accepted, name);
      });

      await _loadContacts();
      if (mounted) {
        setState(() {
          _chatStatus = initialized
              ? 'Ready (MQTT connected)'
              : 'Ready (MQTT offline - demo mode)';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _chatStatus = 'Initialization Error: $e');
    }
  }

  Future<void> _loadContacts() async {
    final contacts = await _database.getAllContacts();
    if (mounted) setState(() => _contacts = contacts);
  }

  void _onSelectContact(Contact contact) async {
    setState(() {
      _selectedContact = contact;
      _messages = [];
      _chatStatus = 'Connecting...';
      if (MediaQuery.of(context).size.width <= 768) _isSidebarHidden = true;
    });

    try {
      await _coordinator?.selectContact(contact);
    } catch (e) {
      if (mounted) {
        setState(() => _chatStatus = 'Connection Error: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
      }
    }
  }

  void _onSendMessage(String content) {
    if (_selectedContact != null && _coordinator != null) {
      _coordinator!.sendMessage(content);
    }
  }

  void _onAddContact() {
    showDialog(
      context: context,
      builder: (_) => ContactDialog(
        onSave: (id, name) async {
          final success = await _coordinator?.addContact(id, name) ?? false;

          if (success) {
            _loadContacts();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Contact added and request sent to $id')),
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contact already exists')),
            );
          }
        },
      ),
    );
  }

  void _handleIncomingContactRequest(String from, String requesterName) async {
    final existing = await _database.getContactById(from);
    if (existing != null) {
      if (existing.status == 'deleted' ||
          existing.status == 'remotely_deleted') {
        await _database.updateContact(
          db.ContactsCompanion(
            peerId: Value(from),
            status: Value('pending'),
            name: Value(requesterName),
          ),
        );
        _loadContacts();
      }
      return;
    }

    await _database.addContact(
      db.ContactsCompanion.insert(
        peerId: from,
        name: requesterName,
        addedAt: DateTime.now(),
        status: Value('pending'),
      ),
    );
    _loadContacts();
  }

  void _handleContactResponse(
    String from,
    bool accepted,
    String? responderName,
  ) async {
    if (!mounted) return;
    if (!accepted) {
      // If we sent a request and they rejected, we mark as deleted to keep history
      await _database.updateContact(
        db.ContactsCompanion(peerId: Value(from), status: Value('deleted')),
      );
      _loadContacts();
      if (_selectedContact?.peerId == from) {
        final updatedContact = await _database.getContactById(from);
        setState(() => _selectedContact = updatedContact);
      }
    } else {
      await _database.updateContact(
        db.ContactsCompanion(peerId: Value(from), status: Value('accepted')),
      );
      _loadContacts();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          accepted
              ? 'User $from accepted your contact request!'
              : 'User $from rejected your contact request.',
        ),
        backgroundColor: accepted ? AppColors.online : Colors.redAccent,
      ),
    );
  }

  void _onEditContact(Contact contact) {
    showDialog(
      context: context,
      builder: (_) => ContactDialog(
        initialContact: contact,
        onSave: (id, name) async {
          await _database.updateContact(
            db.ContactsCompanion(peerId: Value(id), name: Value(name)),
          );
          if (_selectedContact?.peerId == id) {
            setState(
              () => _selectedContact = _selectedContact!.copyWith(name: name),
            );
          }
          _loadContacts();
        },
      ),
    );
  }

  void _onRemoveContact(String peerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Contact'),
        content: const Text('Are you sure you want to remove this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && _coordinator != null) {
      await _coordinator!.removeContact(peerId);
      if (_selectedContact?.peerId == peerId) {
        final updatedContact = await _database.getContactById(peerId);
        setState(() => _selectedContact = updatedContact);
      }
      _loadContacts();
    }
  }

  void _onAcceptContact(String peerId) async {
    final contact = await _database.getContactById(peerId);
    if (contact == null || _coordinator == null) return;

    showDialog(
      context: context,
      builder: (ctx) => ContactDialog(
        initialContact: contact,
        onSave: (id, name) async {
          await _coordinator!.acceptContact(id, name);
          _loadContacts();
          if (_selectedContact?.peerId == id) {
            final updatedContact = await _database.getContactById(id);
            if (!mounted) return;
            setState(() => _selectedContact = updatedContact);
          }
        },
      ),
    );
  }

  void _onDeclineContact(String peerId) async {
    if (_coordinator == null) return;

    await _coordinator!.declineContact(peerId);
    if (_selectedContact?.peerId == peerId) {
      final updatedContact = await _database.getContactById(peerId);
      setState(() => _selectedContact = updatedContact);
    }
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 768;
          final showSidebar = isWide || !_isSidebarHidden;
          final showChat = isWide || _isSidebarHidden;

          return Row(
            children: [
              if (showSidebar)
                SizedBox(
                  width: isWide ? 360 : constraints.maxWidth,
                  child: SidebarWidget(
                    userId: _userId,
                    contacts: _contacts,
                    selectedContact: _selectedContact,
                    onSelectContact: _onSelectContact,
                    onAddContact: _onAddContact,
                    onEditContact: _onEditContact,
                    onRemoveContact: _onRemoveContact,
                  ),
                ),
              if (showChat)
                Expanded(
                  child: ChatView(
                    selectedContact: _selectedContact,
                    messages: _messages,
                    userId: _userId,
                    chatStatus: _chatStatus,
                    onSendMessage: _onSendMessage,
                    onBack: () {
                      if (_selectedContact != null && _coordinator != null) {
                        _coordinator!.selectContact(
                          _selectedContact!,
                        ); // This will close the chat
                      }
                      setState(() => _isSidebarHidden = false);
                    },
                    onAccept: _onAcceptContact,
                    onDecline: _onDeclineContact,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _coordinator?.dispose();
    _database.close();
    super.dispose();
  }
}
