# 🔔 README - Notifications Feature

## نظرة عامة
موديول الإشعارات - إدارة إشعارات التطبيق (محلية وعبر FCM).

## 📁 هيكل المجلد

```
lib/feature/notifications/
├── logic/
│   ├── notification_cubit.dart     # إدارة حالة الإشعارات
│   └── fcm_service.dart              # خدمة Firebase Cloud Messaging
│
├── ui/
│   ├── notifications_page.dart       # صفحة الإشعارات
│   └── notification_settings_page.dart  # إعدادات الإشعارات
│
└── widget/
    ├── notification_card.dart        # بطاقة الإشعار
    ├── notification_empty_state.dart  # حالة عدم وجود إشعارات
    └── notification_icon.dart        # أيقونة الإشعارات مع العداد
```

## 🎯 المكونات الرئيسية

### NotificationCubit
**الملف**: `lib/feature/notifications/logic/notification_cubit.dart`
- جلب الإشعارات من Firestore
- تحديد الإشعار كمقروء
- حذف الإشعارات
- الاشتراك في إشعارات FCM

### NotificationModel (في Core)
**الملف**: `lib/core/models/notification_model.dart`
- **الحقول**: id, userId, title, body, type, relatedId, data, isRead, createdAt
- **أنواع الإشعارات**: booking, payment, general, system

### NotificationsPage
**الملف**: `lib/feature/notifications/ui/notifications_page.dart`
- عرض قائمة الإشعارات
- تجميع الإشعارات حسب التاريخ
- تحديد الكل كمقروء

## 🔗 الـ Routes
- `Routes.notificationsPage` - `/notificationsPage`

## 📦 الاعتماديات
- `firebase_messaging` - FCM للإشعارات
- `cloud_firestore` - تخزين الإشعارات
- `flutter_local_notifications` - إشعارات محلية
- `flutter_bloc` - إدارة الحالة

## 🔄 أنواع الإشعارات
1. **booking**: عند حجز/إلغاء حجز
2. **payment**: عند تأكيد/رفض دفع
3. **general**: إشعارات عامة
4. **system**: تحديثات النظام

## 🔄 تدفق العمل
1. تسجيل جهاز المستخدم في FCM
2. استلام إشعار → حفظ في Firestore
3. عرض الإشعار محلياً
4. عند فتح التطبيق → جلب الإشعارات غير المقروءة

## 🔗 الموديلات المرتبطة
- `core/models/notification_model.dart` - نموذج الإشعار
- `feature/booking` - إشعارات الحجوزات
- `feature/payment` - إشعارات الدفع
