import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String name;
  final String avatar;
  final bool online;
  final String lastMsg;
  final String time;
  final int unread;
  final String productTitle;
  final List<String> participants;

  ChatModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.online,
    required this.lastMsg,
    required this.time,
    required this.unread,
    required this.productTitle,
    required this.participants,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatModel(
      id: docId,
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      online: map['online'] ?? false,
      lastMsg: map['lastMsg'] ?? '',
      time: map['time'] ?? '',
      unread: map['unread'] ?? 0,
      productTitle: map['productTitle'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatar': avatar,
      'online': online,
      'lastMsg': lastMsg,
      'time': time,
      'unread': unread,
      'productTitle': productTitle,
      'participants': participants,
    };
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime time;
  final bool isRead;
  final String attachmentUrl;
  final String attachmentType;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.time,
    required this.isRead,
    required this.attachmentUrl,
    required this.attachmentType,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      time: (map['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      attachmentUrl: map['attachmentUrl'] ?? '',
      attachmentType: map['attachmentType'] ?? 'none',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'time': Timestamp.fromDate(time),
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
    };
  }
}
