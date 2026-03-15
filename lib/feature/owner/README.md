# 👔 README - Owner Feature

## نظرة عامة
موديول المالك - إدارة شاليهات المالك، الحجوزات، الإلغاءات، والتحويلات المالية.

## 📁 هيكل المجلد

```
lib/feature/owner/
├── data/
│   ├── owner_repository.dart     # Repository المالك
│   ├── owner_booking_repository.dart  # Repository حجوزات المالك
│   └── owner_payment_repository.dart    # Repository مدفوعات المالك
│
├── domain/
│   ├── entities/
│   │   ├── owner_entity.dart     # كيان المالك
│   │   ├── owner_booking_entity.dart  # كيان حجز المالك
│   │   └── owner_chalet_entity.dart   # كيان شاليه المالك
│   ├── repository/
│   │   └── base_owner_repository.dart  # واجهة Repository المالك
│   └── usecases/
│       ├── get_owner_chalets_usecase.dart      # جلب شاليهات المالك
│       ├── add_chalet_usecase.dart             # إضافة شاليه
│       ├── update_chalet_usecase.dart          # تحديث شاليه
│       └── get_owner_bookings_usecase.dart     # جلب حجوزات المالك
│
├── logic/
│   ├── owner_cubit.dart          # إدارة حالة المالك
│   ├── owner_chalets_cubit.dart  # شاليهات المالك
│   ├── owner_bookings_cubit.dart # حجوزات المالك
│   └── owner_payments_cubit.dart # مدفوعات المالك
│
├── ui/
│   ├── owner_chalet_Add_screen.dart       # إضافة شاليه جديد
│   ├── owner_bookings_page.dart           # حجوزات المالك
│   ├── owner_cancellations_page.dart      # إلغاءات المالك
│   ├── owner_dashboard_page.dart          # لوحة تحكم المالك
│   ├── owner_chalets_list.dart            # قائمة شاليهات المالك
│   ├── owner_payments_page.dart           # مدفوعات المالك
│   └── booking_transfers_page.dart        # تحويلات الحجوزات
│
├── utils/
│   └── owner_utils.dart          # أدوات مساعدة للمالك
│
└── widget/
    ├── add_chalet_widgets.dart       # ويدجات إضافة الشاليه
    ├── booking_card_widgets.dart     # بطاقات الحجز
    ├── enhanced_dropdown_widgets.dart  # Dropdowns متقدمة
    ├── owner_chalets_list.dart         # قائمة الشاليهات
    ├── owner_stats_card.dart         # بطاقة إحصائيات
    └── ... (ويدجات أخرى)
```

## 🎯 المكونات الرئيسية

### OwnerCubit
**الملف**: `lib/feature/owner/logic/owner_cubit.dart`
- إدارة حالة المالك العامة
- إضافة/تحديث/حذف الشاليهات
- إدارة الحجوزات

### GetOwnerChaletsUseCase
**الملف**: `lib/feature/owner/domain/usecases/get_owner_chalets_usecase.dart`
```dart
Future<Either<Failure, List<dynamic>>> call(String ownerId)
Stream<List<dynamic>> stream(String ownerId)
```

### OwnerBookingsCubit
**الملف**: `lib/feature/owner/logic/owner_bookings_cubit.dart`
- عرض حجوزات شاليهات المالك
- قبول/رفض الحجوزات
- عرض تفاصيل كل حجز

### AddChaletWidgets
**الملف**: `lib/feature/owner/widget/add_chalet_widgets.dart`
- نماذج إدخال بيانات الشاليه
- رفع الصور
- تحديد الموقع على الخريطة
- تحديد الأسعار والمميزات

## 🔗 الـ Routes
- `Routes.ownerScreen` - `/ownerScreen`
- `Routes.approvedRequestsPage` - `/approvedRequestsPage`

## 📦 الاعتماديات
- `cloud_firestore` - تخزين بيانات الشاليهات والحجوزات
- `firebase_storage` - تخزين صور الشاليهات
- `google_maps_flutter` - تحديد موقع الشاليه
- `image_picker` - اختيار صور
- `flutter_bloc` - إدارة الحالة

## 🔄 تدفق العمل (المالك)
1. المالك يسجل الدخول
2. يضيف شاليه جديد → OwnerChaletAddScreen
3. يدخل: الاسم، الوصف، الموقع، الأسعار، الصور، المميزات
4. عند حجز شاليه → إشعار للمالك
5. المالك يقبل/يرفض الحجز
6. بعد إكمال الحجز → استلام المبلغ

## 🔗 الموديلات المرتبطة
- `feature/chalet` - بيانات الشاليهات
- `feature/booking` - إدارة الحجوزات
- `feature/payment` - المدفوعات والتحويلات
- `feature/notifications` - إشعارات الحجوزات
