import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database.dart';
import '../theme/app_theme.dart';

class SidebarWidget extends StatelessWidget {
  final String userId;
  final List<Contact> contacts;
  final Contact? selectedContact;
  final Function(Contact) onSelectContact;
  final VoidCallback onAddContact;
  final Function(Contact) onEditContact;
  final Function(String) onRemoveContact;

  const SidebarWidget({
    super.key,
    required this.userId,
    required this.contacts,
    required this.selectedContact,
    required this.onSelectContact,
    required this.onAddContact,
    required this.onEditContact,
    required this.onRemoveContact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: contacts.where((c) => c.status != 'deleted').isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: contacts
                        .where((c) => c.status != 'deleted')
                        .length,
                    separatorBuilder: (_, index) =>
                        const Divider(height: 1, color: Color(0xFFF8F9FA)),
                    itemBuilder: (context, index) {
                      final filteredContacts = contacts
                          .where((c) => c.status != 'deleted')
                          .toList();
                      final contact = filteredContacts[index];
                      final isActive =
                          selectedContact?.peerId == contact.peerId;
                      return _buildContactItem(context, contact, isActive);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  userId.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY ID',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          userId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: userId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ID copied to clipboard'),
                              ),
                            );
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAddContact,
            icon: const Icon(Icons.add),
            label: const Text('Add New Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    Contact contact,
    bool isActive,
  ) {
    return InkWell(
      onTap: () => onSelectContact(contact),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE7F3FF) : Colors.transparent,
          border: isActive
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 4),
                )
              : null,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFE4E6EB),
                  child: Text(
                    contact.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.online,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (contact.status == 'pending') ...[
                        const SizedBox(width: 8),
                        _buildBadge('PENDING', Colors.orange),
                      ] else if (contact.status == 'request_sent') ...[
                        const SizedBox(width: 8),
                        _buildBadge('SENT', Colors.blue),
                      ] else if (contact.status == 'remotely_deleted') ...[
                        const SizedBox(width: 8),
                        _buildBadge('DISCONNECTED', Colors.red),
                      ],
                    ],
                  ),
                  Text(
                    contact.peerId,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEditContact(contact);
                } else if (value == 'remove') {
                  onRemoveContact(contact.peerId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'remove', child: Text('Remove')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No contacts yet.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a friend to start chatting',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
