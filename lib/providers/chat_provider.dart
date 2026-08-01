import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';
import '../models/chat_model.dart';

class ChatState {
  final List<ChatModel> activeChats;
  final List<MessageModel> currentMessages;
  final bool isLoading;
  final String? error;

  ChatState({
    required this.activeChats,
    required this.currentMessages,
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatModel>? activeChats,
    List<MessageModel>? currentMessages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      activeChats: activeChats ?? this.activeChats,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final FirebaseFirestore _firestore;
  final String? _currentUid;

  ChatNotifier(this._firestore, this._currentUid)
      : super(ChatState(activeChats: [], currentMessages: [])) {
    if (_currentUid != null) {
      fetchChats();
      setUserOnlineStatus(true);
    }
  }

  void fetchChats() {
    if (_currentUid == null) return;
    _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUid)
        .snapshots()
        .listen((snapshot) {
      final chatList = snapshot.docs.map((doc) {
        return ChatModel.fromMap(doc.data(), doc.id);
      }).toList();
      state = state.copyWith(activeChats: chatList);
    });
  }

  void listenToMessages(String chatId) {
    state = state.copyWith(isLoading: true);
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: false)
        .snapshots()
        .listen((snapshot) {
      final messagesList = snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data(), doc.id);
      }).toList();
      
      state = state.copyWith(currentMessages: messagesList, isLoading: false);
      markMessagesAsRead(chatId);
    });
  }

  Future<String> getOrCreateChatRoom({
    required String otherUid,
    required String otherName,
    required String otherAvatar,
    required String productTitle,
  }) async {
    if (_currentUid == null) return '';
    
    // Sort UIDs to ensure distinct ID for distinct pair of users
    final sortedUids = [_currentUid!, otherUid]..sort();
    final chatId = '${sortedUids[0]}_${sortedUids[1]}';

    final doc = await _firestore.collection('chats').doc(chatId).get();
    if (!doc.exists) {
      final newChat = ChatModel(
        id: chatId,
        name: otherName,
        avatar: otherAvatar,
        online: false,
        lastMsg: 'Chat started.',
        time: 'Just Now',
        unread: 0,
        productTitle: productTitle,
        participants: [_currentUid!, otherUid],
      );
      await _firestore.collection('chats').doc(chatId).set(newChat.toMap());
    }
    return chatId;
  }

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
    String attachmentUrl = '',
    String attachmentType = 'none',
  }) async {
    if (_currentUid == null) return;

    final msgId = _firestore.collection('chats').doc(chatId).collection('messages').doc().id;
    final message = MessageModel(
      id: msgId,
      senderId: _currentUid!,
      receiverId: receiverId,
      text: text,
      time: DateTime.now(),
      isRead: false,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
    );

    // Save message nested
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(msgId)
        .set(message.toMap());

    // Update parent chat doc
    await _firestore.collection('chats').doc(chatId).update({
      'lastMsg': text.isNotEmpty ? text : '[Media]',
      'time': 'Just Now',
      'unread': FieldValue.increment(1),
    });

    // Also trigger system notification logic
    await _firestore.collection('notifications').add({
      'userUid': receiverId,
      'title': 'New Message',
      'body': text.isNotEmpty ? text : 'Sent a file.',
      'type': 'chat',
      'referenceId': chatId,
      'read': false,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> markMessagesAsRead(String chatId) async {
    if (_currentUid == null) return;
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: _currentUid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Reset parent counter
      await _firestore.collection('chats').doc(chatId).update({'unread': 0});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    if (_currentUid == null) return;
    await _firestore.collection('chats').doc(chatId).update({
      'typing.$_currentUid': isTyping,
    });
  }

  Future<void> setUserOnlineStatus(bool online) async {
    if (_currentUid == null) return;
    await _firestore.collection('users').doc(_currentUid).update({
      'online': online,
    });
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authState = ref.watch(authProvider);
  final uid = authState.userModel?.uid;
  return ChatNotifier(firestore, uid);
});
