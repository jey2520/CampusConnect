import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userUid;
  final String title;
  final String body;
  final String type;
  final String referenceId;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userUid,
    required this.title,
    required this.body,
    required this.type,
    required this.referenceId,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      userUid: map['userUid'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'system',
      referenceId: map['referenceId'] ?? '',
      read: map['read'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'title': title,
      'body': body,
      'type': type,
      'referenceId': referenceId,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
