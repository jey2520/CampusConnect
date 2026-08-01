import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';
import '../models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  NotificationState({
    required this.notifications,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final FirebaseFirestore _firestore;
  final String? _currentUid;

  NotificationNotifier(this._firestore, this._currentUid)
      : super(NotificationState(notifications: [])) {
    if (_currentUid != null) {
      listenToNotifications();
    }
  }

  void listenToNotifications() {
    if (_currentUid == null) return;
    _firestore
        .collection('notifications')
        .where('userUid', isEqualTo: _currentUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final notifs = snapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data(), doc.id);
      }).toList();
      state = state.copyWith(notifications: notifs);
    });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({'read': true});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearAll() async {
    if (_currentUid == null) return;
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userUid', isEqualTo: _currentUid)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authState = ref.watch(authProvider);
  final uid = authState.userModel?.uid;
  return NotificationNotifier(firestore, uid);
});
