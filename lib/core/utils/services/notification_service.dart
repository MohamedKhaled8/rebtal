import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/services/local_notification_service.dart';
import 'package:rebtal/core/utils/services/onesignal_service.dart';

import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/models/notification_model.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');

  // If the message is a data message (no notification payload) or we want to force show it
  if (message.notification == null && message.data.isNotEmpty) {
    final localNotificationService = LocalNotificationService();
    await localNotificationService.initialize();

    await localNotificationService.showNotification(
      id: message.hashCode,
      title: message.data['title'] ?? 'إشعار جديد',
      body: message.data['body'] ?? '',
      payload: message.data.toString(),
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission
      await requestPermission();

      // Initialize local notifications
      await _localNotificationService.initialize();

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token refreshed: $newToken');
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from a notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('Notification permission: ${settings.authorizationStatus}');
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      _localNotificationService.showNotification(
        id: message.hashCode,
        title: notification.title ?? 'إشعار جديد',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification tap
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    debugPrint('Data: ${message.data}');

    // TODO: Navigate to appropriate screen based on notification type
    final notificationType = message.data['type'];
    final relatedId = message.data['relatedId'];

    debugPrint('Type: $notificationType, Related ID: $relatedId');
  }

  /// Save FCM token to Firestore
  Future<void> saveFCMToken(String userId) async {
    if (_fcmToken == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(_fcmToken)
          .set({
            'token': _fcmToken,
            'platform': defaultTargetPlatform.name,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUsed': FieldValue.serverTimestamp(),
          });

      debugPrint('FCM token saved for user: $userId');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Delete FCM token from Firestore
  Future<void> deleteFCMToken(String userId) async {
    if (_fcmToken == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(_fcmToken)
          .delete();

      debugPrint('FCM token deleted for user: $userId');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  /// Send in-app notification (creates a document in Firestore)
  /// Also triggers a local notification for immediate display
  ///
  /// For translations, use titleKey and bodyKey with optional titleParams/bodyParams
  /// Example: titleKey: 'notifications.booking_approved', titleParams: {'chaletName': 'Villa'}
  Future<void> sendNotification({
    required String userId,
    String? title, // النص المباشر (للـ backward compatibility)
    String? body,
    String? titleKey, // مفتاح الترجمة (مفضل)
    String? bodyKey,
    Map<String, dynamic>? titleParams, // متغيرات الترجمة
    Map<String, dynamic>? bodyParams,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: '', // Will be set by Firestore
        userId: userId,
        title: title ?? '',
        body: body ?? '',
        titleKey: titleKey ?? '',
        bodyKey: bodyKey ?? '',
        titleParams: titleParams,
        bodyParams: bodyParams,
        type: type,
        relatedId: relatedId,
        data: data,
        isRead: false,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('notifications')
          .add(notification.toFirestore());

      // For local notification, try to get translated text if available
      // (in real app, you might want to translate here based on device locale)
      final displayTitle = title ?? titleKey ?? 'إشعار جديد';
      final displayBody = body ?? bodyKey ?? '';

      // Show local notification immediately for visual feedback
      await _localNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: displayTitle,
        body: displayBody,
        payload: relatedId,
      );

      // ✅ AUTOMATICALLY SEND PUSH VIA ONESIGNAL
      // This ensures EVERY notification sent in the app becomes a Push Notification
      await OneSignalService().sendNotification(
        title: displayTitle,
        body: displayBody,
        targetUserId: userId,
        data: {
          'type': type.name,
          'relatedId': relatedId,
          'titleKey': titleKey,
          'bodyKey': bodyKey,
          if (titleParams != null) 'titleParams': titleParams,
          if (bodyParams != null) 'bodyParams': bodyParams,
          if (data != null) ...data,
        },
      );

      debugPrint(
        'Notification sent to user: $userId (In-App + Local + OneSignal)',
      );
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  /// Send push notification to specific user via FCM tokens
  ///
  /// For translations, use titleKey and bodyKey with optional titleParams/bodyParams
  Future<void> sendPushNotification({
    required String userId,
    String? title,
    String? body,
    String? titleKey,
    String? bodyKey,
    Map<String, dynamic>? titleParams,
    Map<String, dynamic>? bodyParams,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      // First, save to Firestore for in-app display
      await sendNotification(
        userId: userId,
        title: title,
        body: body,
        titleKey: titleKey,
        bodyKey: bodyKey,
        titleParams: titleParams,
        bodyParams: bodyParams,
        type: type,
        relatedId: relatedId,
        data: data,
      );

      // Note: Actual FCM push requires a backend server to send messages
      // This would typically be done via Cloud Functions or your backend
      debugPrint('Push notification queued for user: $userId');
    } catch (e) {
      debugPrint('Error sending push notification: $e');
    }
  }
}
