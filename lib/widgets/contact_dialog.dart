import 'package:flutter/material.dart';
import '../database/database.dart';
import '../theme/app_theme.dart';

class ContactDialog extends StatefulWidget {
  final Contact? initialContact;
  final Function(String peerId, String name) onSave;

  const ContactDialog({super.key, this.initialContact, required this.onSave});

  @override
  State<ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<ContactDialog> {
  late TextEditingController _idController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(
      text: widget.initialContact?.peerId ?? '',
    );
    _nameController = TextEditingController(
      text: widget.initialContact?.name ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialContact != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Contact' : 'Add New Contact',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isEditing
                  ? 'Update the display name for this contact.'
                  : "Enter your friend's unique ID to start a direct P2P connection.",
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildInput(
              label: 'PEER ID',
              controller: _idController,
              hint: 'e.g., ABC-123',
              enabled: !isEditing,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            _buildInput(
              label: 'DISPLAY NAME',
              controller: _nameController,
              hint: "Friend's Name",
              autofocus: true,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_idController.text.isNotEmpty &&
                        _nameController.text.isNotEmpty) {
                      widget.onSave(
                        _idController.text.trim(),
                        _nameController.text.trim(),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(isEditing ? 'Save Changes' : 'Add Friend'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    bool autofocus = false,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled
                ? const Color(0xFFF8F9FA)
                : const Color(0xFFE4E6EB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
