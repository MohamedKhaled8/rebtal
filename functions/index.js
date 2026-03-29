const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

function getOneSignalConfig() {
    const cfg = functions.config().onesignal || {};
    return {
        appId: (cfg.app_id || '').trim(),
        restApiKey: (cfg.rest_api_key || '').trim(),
    };
}

async function sendViaOneSignal({ userId, title, body, data = {} }) {
    const { appId, restApiKey } = getOneSignalConfig();
    if (!appId || !restApiKey) {
        console.log('OneSignal config is missing, skipping OneSignal send.');
        return { sent: false, reason: 'missing_config' };
    }

    const response = await fetch('https://onesignal.com/api/v1/notifications', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=utf-8',
            Authorization: `Basic ${restApiKey}`,
        },
        body: JSON.stringify({
            app_id: appId,
            headings: { en: title, ar: title },
            contents: { en: body, ar: body },
            include_aliases: {
                external_id: [userId],
            },
            target_channel: 'push',
            data,
            android_channel_id: 'rebtal_channel',
            priority: 10,
            android_visibility: 1,
        }),
    });

    const text = await response.text();
    if (!response.ok) {
        throw new Error(`OneSignal HTTP ${response.status}: ${text}`);
    }

    console.log('OneSignal notification sent successfully:', text);
    return { sent: true };
}

async function sendViaFcmFallback({ userId, title, body, data = {}, notificationId }) {
    // Fallback for resilience while transitioning to OneSignal-only delivery.
    const tokensSnapshot = await admin.firestore()
        .collection('users')
        .doc(userId)
        .collection('fcmTokens')
        .get();

    if (tokensSnapshot.empty) {
        console.log('No FCM tokens found for user:', userId);
        return null;
    }

    const payload = {
        notification: {
            title: title || 'إشعار جديد',
            body: body || '',
            sound: 'default',
            badge: '1',
        },
        data: {
            ...data,
            notificationId: notificationId || '',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
    };

    const tokens = tokensSnapshot.docs.map(doc => doc.data().token).filter(Boolean);
    if (!tokens.length) return null;

    const response = await admin.messaging().sendToDevice(tokens, payload, {
        priority: 'high',
        timeToLive: 60 * 60 * 24, // 24 hours
    });

    const tokensToRemove = [];
    response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
            console.error('Failure sending FCM fallback to', tokens[index], error);
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
                tokensToRemove.push(tokensSnapshot.docs[index].ref.delete());
            }
        }
    });

    await Promise.all(tokensToRemove);
    console.log('FCM fallback sent to', tokens.length, 'devices');
    return response;
}

/**
 * Send push notification when a new notification document is created.
 * Primary: OneSignal by external_id (userId).
 * Fallback: FCM tokens if OneSignal config is missing or request fails.
 */
exports.sendNotificationOnCreate = functions.firestore
    .document('notifications/{notificationId}')
    .onCreate(async (snap, context) => {
        try {
            const notification = snap.data();
            const userId = notification.userId;

            if (!userId) {
                console.log('No userId found in notification');
                return null;
            }
            const title = notification.title || 'إشعار جديد';
            const body = notification.body || '';
            const data = {
                type: notification.type || 'general',
                relatedId: notification.relatedId || '',
            };

            try {
                await sendViaOneSignal({
                    userId,
                    title,
                    body,
                    data,
                });
            } catch (oneSignalError) {
                console.error('OneSignal send failed, trying FCM fallback:', oneSignalError);
                await sendViaFcmFallback({
                    userId,
                    title,
                    body,
                    data,
                    notificationId: context.params.notificationId,
                });
            }
            return null;
        } catch (error) {
            console.error('Error sending notification:', error);
            return null;
        }
    });

/**
 * Send notification when booking status changes
 */
exports.onBookingStatusChange = functions.firestore
    .document('bookings/{bookingId}')
    .onUpdate(async (change, context) => {
        try {
            const before = change.before.data();
            const after = change.after.data();

            // Check if status changed
            if (before.status === after.status) {
                return null;
            }

            const bookingId = context.params.bookingId;
            const status = after.status;
            const userId = after.userId;
            const ownerId = after.ownerId;
            const chaletName = after.chaletName || 'الشاليه';

            let title = '';
            let body = '';
            let targetUserId = '';

            // Determine notification based on status
            switch (status) {
                case 'approved':
                    title = 'تمت الموافقة على حجزك ✅';
                    body = `تم قبول حجزك في ${chaletName}. يمكنك الآن إتمام الدفع.`;
                    targetUserId = userId;
                    break;

                case 'rejected':
                    title = 'تم رفض الحجز ❌';
                    body = `عذراً، تم رفض حجزك في ${chaletName}.`;
                    targetUserId = userId;
                    break;

                case 'confirmed':
                    title = 'تم تأكيد الحجز 🎉';
                    body = `تم تأكيد حجزك في ${chaletName}. نتمنى لك إقامة سعيدة!`;
                    targetUserId = userId;
                    break;

                case 'cancelled':
                    title = 'تم إلغاء الحجز';
                    body = `تم إلغاء الحجز في ${chaletName}`;
                    targetUserId = ownerId; // Notify owner
                    break;

                case 'pending':
                    title = 'حجز جديد 📋';
                    body = `لديك حجز جديد في ${chaletName}`;
                    targetUserId = ownerId;
                    break;

                default:
                    return null;
            }

            if (!targetUserId) {
                return null;
            }

            // Create notification document (which will trigger sendNotificationOnCreate)
            await admin.firestore().collection('notifications').add({
                userId: targetUserId,
                title: title,
                body: body,
                type: 'booking',
                relatedId: bookingId,
                isRead: false,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            return null;
        } catch (error) {
            console.error('Error in onBookingStatusChange:', error);
            return null;
        }
    });
