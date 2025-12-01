import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/models/notification_model.dart';
import 'package:rebtal/feature/notifications/logic/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load notifications for a specific user
  Future<void> loadNotifications(String userId) async {
    try {
      emit(const NotificationLoading());

      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final notifications = querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      final unreadCount = notifications
          .where((notification) => !notification.isRead)
          .length;

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }

  /// Listen to notifications in real-time
  void listenToNotifications(String userId) {
    _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
          (snapshot) {
            final notifications = snapshot.docs
                .map((doc) => NotificationModel.fromFirestore(doc))
                .toList();

            final unreadCount = notifications
                .where((notification) => !notification.isRead)
                .length;

            emit(
              NotificationLoaded(
                notifications: notifications,
                unreadCount: unreadCount,
              ),
            );
          },
          onError: (error) {
            emit(
              NotificationError('Failed to listen to notifications: $error'),
            );
          },
        );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });

      // Update local state
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        final unreadCount = updatedNotifications
            .where((notification) => !notification.isRead)
            .length;

        emit(
          NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: unreadCount,
          ),
        );
      }
    } catch (e) {
      emit(NotificationError('Failed to mark as read: $e'));
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Update local state
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();

        emit(
          NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: 0,
          ),
        );
      }
    } catch (e) {
      emit(NotificationError('Failed to mark all as read: $e'));
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();

      // Update local state
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications
            .where((n) => n.id != notificationId)
            .toList();

        final unreadCount = updatedNotifications
            .where((notification) => !notification.isRead)
            .length;

        emit(
          NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: unreadCount,
          ),
        );
      }
    } catch (e) {
      emit(NotificationError('Failed to delete notification: $e'));
    }
  }

  /// Clear all notifications
  Future<void> clearAll(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      emit(const NotificationLoaded(notifications: [], unreadCount: 0));
    } catch (e) {
      emit(NotificationError('Failed to clear all notifications: $e'));
    }
  }
}
