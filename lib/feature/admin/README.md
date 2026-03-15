# 👮 README - Admin Feature

## نظرة عامة
موديول الأدمن - لوحة تحكم المسؤول لإدارة المستخدمين، الشاليهات، الحجوزات، والمدفوعات.

## 📁 هيكل المجلد

```
lib/feature/admin/
├── logic/
│   ├── admin_cubit.dart            # إدارة حالة الأدمن
│   ├── admin_bookings_cubit.dart   # حجوزات الأدمن
│   ├── admin_chalets_cubit.dart    # شاليهات الأدمن
│   ├── admin_payments_cubit.dart   # مدفوعات الأدمن
│   └── admin_users_cubit.dart      # مستخدمين الأدمن
│
├── ui/
│   ├── dashboard.dart              # لوحة التحكم الرئيسية
│   ├── admin_bookings_page.dart    # إدارة الحجوزات
│   ├── admin_chalets_page.dart    # إدارة الشاليهات
│   ├── admin_payments_page.dart   # إدارة المدفوعات
│   ├── admin_users_page.dart      # إدارة المستخدمين
│   └── admin_reports_page.dart    # التقارير
│
└── widget/
    ├── admin_app_bar.dart          # AppBar مخصص للأدمن
    ├── admin_drawer.dart           # Drawer للأدمن
    ├── admin_stats_card.dart       # بطاقة إحصائيات
    ├── admin_user_card.dart        # بطاقة مستخدم
    ├── admin_chalet_card.dart      # بطاقة شاليه
    ├── admin_booking_card.dart     # بطاقة حجز
    ├── admin_payment_card.dart     # بطاقة دفع
    ├── status_badge.dart           # شارة الحالة
    ├── filter_bar.dart             # شريط الفلترة
    ├── search_field.dart           # حقل البحث
    ├── data_table.dart             # جدول البيانات
    ├── confirmation_dialog.dart    # حوار التأكيد
    ├── image_viewer_dialog.dart    # عارض الصور
    ├── user_detail_dialog.dart     # تفاصيل المستخدم
    ├── chalet_detail_dialog.dart   # تفاصيل الشاليه
    ├── booking_detail_dialog.dart  # تفاصيل الحجز
    ├── payment_verification_dialog.dart  # التحقق من الدفع
    ├── activity_log_widget.dart    # سجل النشاط
    └── export_button.dart          # زر التصدير
```

## 🎯 المكونات الرئيسية

### AdminDashboard
**الملف**: `lib/feature/admin/ui/dashboard.dart`
- لوحة التحكم الرئيسية للأدمن
- إحصائيات عامة (المستخدمين، الشاليهات، الحجوزات، المدفوعات)
- رسوم بيانية للأداء

### AdminCubit
**الملف**: `lib/feature/admin/logic/admin_cubit.dart`
- إدارة حالة لوحة التحكم
- جلب الإحصائيات
- إدارة المستخدمين والشاليهات

### AdminPaymentsCubit
**الملف**: `lib/feature/admin/logic/admin_payments_cubit.dart`
- عرض المدفوعات المعلقة
- التحقق من إثباتات الدفع
- تأكيد/رفض المدفوعات

## 🔗 الـ Routes
- `Routes.dashboardScreen` - `/dashboardScreen`
- `Routes.adminPayments` - `/adminPayments`

## 📦 الاعتماديات
- `cloud_firestore` - جلب البيانات
- `firebase_auth` - إدارة المستخدمين
- `flutter_bloc` - إدارة الحالة
- `fl_chart` - الرسوم البيانية (إن وجد)
- `syncfusion_flutter_datagrid` - جداول البيانات (إن وجد)

## 🔄 تدفق العمل (الأدمن)
1. تسجيل الدخول كأدمن
2. عرض لوحة التحكم مع الإحصائيات
3. إدارة المستخدمين (تفعيل/تعطيل)
4. مراجعة الشاليهات (الموافقة/الرفض)
5. التحقق من المدفوعات (تأكيد/رفض)
6. عرض تقارير الأداء

## 🔗 الموديلات المرتبطة
- `feature/auth` - تسجيل دخول الأدمن
- `feature/booking` - إدارة الحجوزات
- `feature/payment` - التحقق من المدفوعات
- `feature/chalet` - إدارة الشاليهات
- `feature/owner` - إدارة الملاك
