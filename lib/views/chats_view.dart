import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';

class ChatsView extends ConsumerWidget {
  const ChatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onBackground),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.extrabold, color: theme.colorScheme.onBackground),
        ),
        centerTitle: true,
      ),
      body: chatState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatState.activeChats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.forum_outlined, size: 64, color: theme.colorScheme.onBackground.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No active conversations yet',
                        style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.4)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: chatState.activeChats.length,
                  itemBuilder: (context, index) {
                    final chat = chatState.activeChats[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              chat.avatar,
                              style: TextStyle(
                                fontWeight: FontWeight.extrabold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          if (chat.online)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00D4A6), // Online Green
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.colorScheme.surface, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Text(
                            chat.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            chat.time,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onBackground.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat.lastMsg,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: chat.unread > 0 
                                          ? theme.colorScheme.onBackground 
                                          : theme.colorScheme.onBackground.withOpacity(0.5),
                                      fontWeight: chat.unread > 0 ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Re: ${chat.productTitle}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: theme.colorScheme.primary.withOpacity(0.6),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (chat.unread > 0)
                              CircleAvatar(
                                radius: 9,
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                  '${chat.unread}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                      onTap: () {
                        ref.read(chatProvider.notifier).listenToMessages(chat.id);
                        context.push('/chat-screen/${chat.id}');
                      },
                    );
                  },
                ),
    );
  }
}
