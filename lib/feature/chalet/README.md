# 🏡 README - Chalet Feature

## نظرة عامة
موديول الشاليهات - إدارة بيانات الشاليهات، العرض، والبحث.

## 📁 هيكل المجلد

```
lib/feature/chalet/
├── data/
│   ├── models/
│   │   └── chalet_model.dart     # نموذج بيانات الشاليه
│   └── repositories/
│       └── chalet_repository.dart  # تنفيذ Repository الشاليهات
│
├── domain/
│   ├── entities/
│   │   ├── chalet_entity.dart    # كيان الشاليه
│   │   ├── chalet_image_entity.dart  # كيان صورة الشاليه
│   │   ├── review_entity.dart    # كيان التقييم
│   │   └── pricing_entity.dart   # كيان التسعير
│   ├── repositories/
│   │   └── chalet_repository.dart  # واجهة Repository الشاليهات
│   └── usecases/
│       ├── get_chalet_booked_dates_usecase.dart    # جلب التواريخ المحجوزة
│       ├── toggle_booking_availability_usecase.dart  # تبديل التوفر
│       └── update_chalet_status_usecase.dart       # تحديث حالة الشاليه
│
├── function/
│   └── chalet_functions.dart     # دوال مساعدة للشاليهات
│
├── logic/
│   ├── chalet_cubit.dart         # إدارة حالة الشاليه
│   ├── chalet_details_cubit.dart # تفاصيل الشاليه
│   ├── chalet_filter_cubit.dart  # فلترة الشاليهات
│   ├── chalet_list_cubit.dart    # قائمة الشاليهات
│   ├── chalet_map_cubit.dart     # خريطة الشاليهات
│   ├── chalet_pricing_cubit.dart # تسعير الشاليه
│   ├── chalet_review_cubit.dart  # تقييمات الشاليه
│   ├── chalet_search_cubit.dart  # البحث في الشاليهات
│   ├── chalet_upload_cubit.dart  # رفع صور الشاليه
│   └── chalet_wizard_cubit.dart  # معالج إضافة الشاليه
│
├── ui/
│   ├── chalet_details_screen.dart    # شاشة تفاصيل الشاليه
│   ├── chalet_list_screen.dart       # قائمة الشاليهات
│   ├── chalet_map_screen.dart        # خريطة الشاليهات
│   └── chalet_search_screen.dart     # شاشة البحث
│
└── widget/
    ├── chalet_amenities.dart         # مميزات الشاليه
    ├── chalet_calendar.dart          # تقويم حجز الشاليه
    ├── chalet_description.dart       # وصف الشاليه
    ├── chalet_gallery.dart           # معرض صور الشاليه
    ├── chalet_location_map.dart      # خريطة موقع الشاليه
    ├── chalet_pricing_card.dart      # بطاقة التسعير
    ├── chalet_rating_bar.dart        # شريط التقييم
    ├── chalet_reviews_list.dart      # قائمة التقييمات
    └── ... (ويدجات أخرى)
```

## 🎯 المكونات الرئيسية

### ChaletModel
**الملف**: `lib/feature/chalet/data/models/chalet_model.dart`
- **الحقول**: id, name, description, location, price, images, amenities, rating, ownerId, etc.
- **التحويل**: fromJson, toJson, fromFirestore, toFirestore

### ChaletDetailsCubit
**الملف**: `lib/feature/chalet/logic/chalet_details_cubit.dart`
- عرض تفاصيل الشاليه
- جلب التقييمات
- التحقق من التواريخ المتاحة

### GetChaletBookedDatesUseCase
**الملف**: `lib/feature/chalet/domain/usecases/get_chalet_booked_dates_usecase.dart`
- جلب التواريخ المحجوزة للشاليه
- منع الحجز في التواريخ المحجوزة

## 🔗 الـ Routes
- (يتم التنقل عبر `homeScreen` أو `ownerScreen`)

## 📦 الاعتماديات
- `cloud_firestore` - تخزين بيانات الشاليهات
- `firebase_storage` - تخزين صور الشاليهات
- `google_maps_flutter` - عرض موقع الشاليه
- `table_calendar` - تقويم الحجز
- `flutter_bloc` - إدارة الحالة

## 🔄 تدفق العمل
1. جلب بيانات الشاليه من Firestore
2. عرض التفاصيل (صور، وصف، سعر، موقع)
3. التحقق من التواريخ المتاحة
4. الانتقال إلى Booking للحجز

## 🔗 الموديلات المرتبطة
- `feature/booking` - الحجوزات
- `feature/owner` - إدارة الشاليهات (للمالكين)
- `feature/favorites` - المفضلات
