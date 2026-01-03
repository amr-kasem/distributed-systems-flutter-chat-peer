import 'package:flutter/material.dart';
import '../database/database.dart' as db;
import '../models/message.dart' as models;
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class ChatView extends StatefulWidget {
  final db.Contact? selectedContact;
  final List<models.Message> messages;
  final String userId;
  final String chatStatus;
  final Function(String) onSendMessage;
  final VoidCallback onBack;
  final Function(String) onAccept;
  final Function(String) onDecline;

  const ChatView({
    super.key,
    required this.selectedContact,
    required this.messages,
    required this.userId,
    required this.chatStatus,
    required this.onSendMessage,
    required this.onBack,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom(isInit: true);
  }

  @override
  void didUpdateWidget(ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom({bool isInit = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_scrollController.hasClients) {
        // Small delay to ensure layout size is updated
        await Future.delayed(const Duration(milliseconds: 100));
        if (_scrollController.hasClients) {
          final position = _scrollController.position.maxScrollExtent;
          if (isInit) {
            _scrollController.jumpTo(position);
          } else {
            _scrollController.animateTo(
              position,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      }
    });
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSendMessage(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedContact == null) {
      return _buildEmptyState();
    }

    final isAccepted = widget.selectedContact!.status == 'accepted';

    return Column(
      children: [
        _buildHeader(context),
        if (isAccepted) ...[
          Expanded(child: _buildMessagesList()),
          _buildComposer(),
        ] else
          Expanded(child: _buildAcceptanceBanner(context)),
      ],
    );
  }

  Widget _buildAcceptanceBanner(BuildContext context) {
    final contact = widget.selectedContact!;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (contact.status == 'pending') ...[
              const Text('👋', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'New Contact Request',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${contact.name} (${contact.peerId}) wants to chat with you.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMain),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => widget.onDecline(contact.peerId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => widget.onAccept(contact.peerId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Accept Request'),
                  ),
                ],
              ),
            ] else if (contact.status == 'request_sent') ...[
              const Text('⏳', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Request Sent',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Waiting for ${contact.name} to accept your request.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMain),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => widget.onDecline(
                  contact.peerId,
                ), // Cancel is same as decline/delete
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Cancel Request'),
              ),
            ] else if (contact.status == 'deleted') ...[
              const Text('📁', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Chat Preserved (Private)',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have removed this contact. History is preserved for you.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMain),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => widget.onAccept(
                  contact.peerId,
                ), // Re-add can re-use onAccept logic or similar
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Re-add Contact'),
              ),
            ] else if (contact.status == 'remotely_deleted') ...[
              const Text('🚫', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'User Disconnected',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${contact.name} has removed you from their contacts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMain),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => widget.onDecline(
                  contact.peerId,
                ), // Stop chat is same as delete
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Stop Chat (Hide)'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '💬',
              style: TextStyle(fontSize: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to P2P Chat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a conversation from the sidebar to start messaging.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final contact = widget.selectedContact!;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width <= 768)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            ),
          CircleAvatar(
            backgroundColor: const Color(0xFFF0F2F5),
            child: Text(
              contact.name[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.selectedContact?.status == 'accepted'
                      ? widget.chatStatus
                      : _getStatusText(widget.selectedContact?.status),
                  style: TextStyle(
                    color:
                        widget.selectedContact?.status == 'accepted' &&
                            widget.chatStatus == 'Connected'
                        ? AppColors.online
                        : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'Incoming Request';
      case 'request_sent':
        return 'Request Sent';
      case 'deleted':
        return 'Preserved';
      case 'remotely_deleted':
        return 'Disconnected';
      default:
        return status ?? '';
    }
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final msg = widget.messages[index];
        final isMe = msg.senderId == widget.userId;
        return _buildMessageBubble(msg, isMe);
      },
    );
  }

  Widget _buildMessageBubble(models.Message msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.msgSent : AppColors.msgReceived,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 1),
              blurRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.content,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textMain,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(msg.timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(msg.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(models.MessageStatus status) {
    IconData icon;
    Color color = Colors.white70;

    switch (status) {
      case models.MessageStatus.pending:
        icon = Icons.access_time;
        break;
      case models.MessageStatus.sending:
        icon = Icons.hourglass_empty;
        break;
      case models.MessageStatus.sent:
        icon = Icons.check;
        break;
      case models.MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white;
        break;
      case models.MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blueAccent;
        break;
      case models.MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.redAccent;
        break;
    }

    return Icon(icon, size: 12, color: color);
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.send, color: Colors.white),
              ),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}
