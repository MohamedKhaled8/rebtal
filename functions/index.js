const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Send FCM notification when a new notification document is created
 * This ensures notifications appear even when the app is closed
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

            // Get user's FCM tokens
            const tokensSnapshot = await admin.firestore()
                .collection('users')
                .doc(userId)
                .collection('fcmTokens')
                .get();

            if (tokensSnapshot.empty) {
                console.log('No FCM tokens found for user:', userId);
                return null;
            }

            // Prepare notification payload
            const payload = {
                notification: {
                    title: notification.title || 'إشعار جديد',
                    body: notification.body || '',
                    sound: 'default',
                    badge: '1',
                },
                data: {
                    type: notification.type || 'general',
                    relatedId: notification.relatedId || '',
                    notificationId: context.params.notificationId,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                },
            };

            // Send to all user's devices
            const tokens = tokensSnapshot.docs.map(doc => doc.data().token);

            const response = await admin.messaging().sendToDevice(tokens, payload, {
                priority: 'high',
                timeToLive: 60 * 60 * 24, // 24 hours
            });

            console.log('Successfully sent notification to', tokens.length, 'devices');
            console.log('Response:', response);

            // Clean up invalid tokens
            const tokensToRemove = [];
            response.results.forEach((result, index) => {
                const error = result.error;
                if (error) {
                    console.error('Failure sending notification to', tokens[index], error);
                    // Remove invalid tokens
                    if (error.code === 'messaging/invalid-registration-token' ||
                        error.code === 'messaging/registration-token-not-registered') {
                        tokensToRemove.push(
                            tokensSnapshot.docs[index].ref.delete()
                        );
                    }
                }
            });

            await Promise.all(tokensToRemove);

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
