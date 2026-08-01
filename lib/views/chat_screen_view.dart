import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_model.dart';

class ChatScreenView extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreenView({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends ConsumerState<ChatScreenView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).listenToMessages(widget.chatId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatState = ref.read(chatProvider);
    final authState = ref.read(authProvider);
    
    final chat = chatState.activeChats.firstWhere((c) => c.id == widget.chatId);
    final receiverId = chat.participants.firstWhere((p) => p != authState.userModel?.uid);

    _messageController.clear();
    
    await ref.read(chatProvider.notifier).sendMessage(
          chatId: widget.chatId,
          receiverId: receiverId,
          text: text,
        );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    final chat = chatState.activeChats.firstWhere(
      (c) => c.id == widget.chatId,
      orElse: () => ChatModel(
        id: '',
        name: 'Chat',
        avatar: '?',
        online: false,
        lastMsg: '',
        time: '',
        unread: 0,
        productTitle: 'Listing',
        participants: [],
      ),
    );

    if (chat.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
        body: const Center(child: Text('Chat thread not found.')),
      );
    }

    final myUid = authState.userModel?.uid ?? '';

    // Scroll to bottom on updates
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                chat.avatar,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.extrabold, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Re: ${chat.productTitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: chatState.currentMessages.length,
              itemBuilder: (context, index) {
                final msg = chatState.currentMessages[index];
                final isMe = msg.senderId == myUid;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? theme.colorScheme.primary : theme.colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: isMe ? Colors.white : theme.colorScheme.onBackground,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.colorScheme.onBackground.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
