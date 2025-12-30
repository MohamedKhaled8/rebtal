# إعداد الإشعارات العائمة (Push Notifications)

## نظرة عامة
تم تطوير نظام إشعارات شامل يعمل في جميع الحالات:
- ✅ عندما يكون التطبيق مفتوحاً (Foreground)
- ✅ عندما يكون التطبيق في الخلفية (Background)
- ✅ عندما يكون التطبيق مغلقاً تماماً (Terminated)
- ✅ مع صوت الإشعار
- ✅ في شريط الإشعارات

## المتطلبات

### 1. إعداد Firebase Cloud Messaging (FCM)

#### Android:
1. تأكد من وجود ملف `google-services.json` في مجلد `android/app/`
2. تحديث `android/app/build.gradle`:
```gradle
dependencies {
    // ... باقي المكتبات
    implementation 'com.google.firebase:firebase-messaging:23.3.1'
}
```

3. إضافة الأذونات في `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <!-- أذونات الإشعارات -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- ... -->
        
        <!-- FCM Service -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT"/>
            </intent-filter>
        </service>
        
        <!-- Default notification channel -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="rebtal_channel"/>
    </application>
</manifest>
```

#### iOS:
1. تأكد من وجود ملف `GoogleService-Info.plist` في مجلد `ios/Runner/`
2. تفعيل Push Notifications في Xcode:
   - افتح `ios/Runner.xcworkspace`
   - اختر Target > Runner
   - اذهب إلى Signing & Capabilities
   - اضغط + Capability
   - أضف "Push Notifications"
   - أضف "Background Modes" وفعّل "Remote notifications"

### 2. نشر Cloud Functions

```bash
# الانتقال لمجلد المشروع
cd e:\Mt FlutterProject\rebtal

# تسجيل الدخول إلى Firebase
firebase login

# تهيئة Functions (إذا لم يتم من قبل)
firebase init functions

# تثبيت المكتبات
cd functions
npm install

# نشر Functions
firebase deploy --only functions
```

### 3. التحقق من الإعدادات

#### في Firebase Console:
1. اذهب إلى Project Settings > Cloud Messaging
2. تأكد من تفعيل Firebase Cloud Messaging API (V1)
3. احفظ Server Key (سيتم استخدامه لاحقاً)

## كيفية العمل

### 1. عند إرسال إشعار من التطبيق:
```dart
await NotificationService().sendNotification(
  userId: 'user_id',
  title: 'عنوان الإشعار',
  body: 'محتوى الإشعار',
  type: NotificationType.booking,
  relatedId: 'booking_id',
);
```

### 2. ما يحدث تلقائياً:
1. ✅ يتم حفظ الإشعار في Firestore (`notifications` collection)
2. ✅ يتم عرض إشعار محلي فوري (Local Notification)
3. ✅ Cloud Function تلتقط الإشعار الجديد
4. ✅ يتم إرسال Push Notification عبر FCM لجميع أجهزة المستخدم
5. ✅ يظهر الإشعار في شريط الإشعارات مع الصوت

### 3. حالات الإشعارات التلقائية:

#### عند تغيير حالة الحجز:
- **Approved**: إشعار للمستخدم بقبول الحجز
- **Rejected**: إشعار للمستخدم برفض الحجز
- **Confirmed**: إشعار للمستخدم بتأكيد الدفع
- **Cancelled**: إشعار للمالك بإلغاء الحجز
- **Pending**: إشعار للمالك بحجز جديد

## اختبار الإشعارات

### 1. اختبار محلي:
```dart
// في أي مكان في التطبيق
await NotificationService().sendNotification(
  userId: 'your_user_id',
  title: 'اختبار الإشعار',
  body: 'هذا إشعار تجريبي',
  type: NotificationType.general,
);
```

### 2. اختبار من Firebase Console:
1. اذهب إلى Firebase Console > Cloud Messaging
2. اضغط "Send your first message"
3. أدخل العنوان والمحتوى
4. اختر التطبيق
5. أرسل الإشعار

### 3. التحقق من عمل Cloud Functions:
```bash
# عرض سجلات Functions
firebase functions:log

# أو من Firebase Console
# اذهب إلى Functions > Logs
```

## استكشاف الأخطاء

### الإشعارات لا تظهر في Android:
1. تأكد من منح التطبيق إذن الإشعارات
2. تحقق من `AndroidManifest.xml`
3. تأكد من تثبيت `google-services.json`

### الإشعارات لا تظهر في iOS:
1. تأكد من تفعيل Push Notifications في Xcode
2. تحقق من Apple Developer Console
3. تأكد من استخدام Development/Production certificates الصحيحة

### Cloud Functions لا تعمل:
1. تحقق من نشر Functions بنجاح
2. راجع Logs في Firebase Console
3. تأكد من تفعيل Billing في Firebase Project

## الملفات المهمة

- `lib/core/utils/services/notification_service.dart` - خدمة الإشعارات الرئيسية
- `lib/core/utils/services/local_notification_service.dart` - الإشعارات المحلية
- `functions/index.js` - Cloud Functions للإشعارات
- `android/app/src/main/AndroidManifest.xml` - إعدادات Android
- `ios/Runner/Info.plist` - إعدادات iOS

## ملاحظات مهمة

1. **الصوت**: يتم تشغيل صوت الإشعار الافتراضي للنظام
2. **الاهتزاز**: مفعّل تلقائياً على Android
3. **Badge**: يتم تحديث Badge على iOS
4. **Priority**: جميع الإشعارات ذات أولوية عالية (High Priority)
5. **TTL**: الإشعارات صالحة لمدة 24 ساعة

## الدعم

للمزيد من المعلومات:
- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
