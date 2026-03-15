# 🏠 README - Home Feature

## نظرة عامة
موديول الصفحة الرئيسية - عرض الشاليهات والبحث والفلترة.

## 📁 هيكل المجلد

```
lib/feature/home/
├── data/
│   ├── home_repository.dart      # Repository للصفحة الرئيسية
│   └── remote_data_source.dart   # مصدر البيانات البعيد
│
├── domain/
│   ├── entities/
│   │   └── home_entity.dart      # كيانات الصفحة الرئيسية
│   ├── usecases/
│   │   ├── get_chalets_usecase.dart       # جلب الشاليهات
│   │   ├── search_chalets_usecase.dart    # البحث في الشاليهات
│   │   └── filter_chalets_usecase.dart    # فلترة الشاليهات
│   └── repository/
│       └── home_repository.dart  # واجهة الـ Repository
│
├── logic/
│   └── home_cubit.dart           # إدارة حالة الصفحة الرئيسية
│
├── ui/
│   └── home_screen.dart          # شاشة الصفحة الرئيسية
│
└── widget/
    ├── chalet_card.dart          # بطاقة الشاليه
    ├── chalet_list.dart          # قائمة الشاليهات
    ├── filter_bottom_sheet.dart  # Bottom sheet للفلترة
    ├── home_app_bar.dart         # AppBar مخصص للصفحة الرئيسية
    ├── home_search_bar.dart      # شريط البحث
    ├── location_selector.dart    # اختيار الموقع
    ├── price_range_slider.dart   # شريط نطاق السعر
    ├── rating_filter.dart        # فلتر التقييم
    └── ... (ويدجات أخرى)
```

## 🎯 المكونات الرئيسية

### HomeCubit
**الملف**: `lib/feature/home/logic/home_cubit.dart`
- إدارة حالة الصفحة الرئيسية
- جلب الشاليهات
- البحث والفلترة

### HomeScreen
**الملف**: `lib/feature/home/ui/home_screen.dart`
- الشاشة الرئيسية للتطبيق
- تعرض قائمة الشاليهات

### ChaletCard
**الملف**: `lib/feature/home/widget/chalet_card.dart`
- بطاقة عرض الشاليه مع الصورة والسعر والتقييم

## 🔗 الـ Routes
- `Routes.homeScreen` - `/homeScreen`
- `Routes.bottomNavigationBarScreen` - `/bottomNavigationBarScreen`

## 📦 الاعتماديات
- `cloud_firestore` - جلب بيانات الشاليهات
- `flutter_bloc` - إدارة الحالة
- `cached_network_image` - صور الشاليهات

## 🔄 تدفق العمل
1. جلب الشاليهات من Firestore → GetChaletsUseCase
2. عرض الشاليهات في ListView/GridView
3. البحث الفوري → SearchChaletsUseCase
4. الفلترة حسب: السعر، الموقع، التقييم، المميزات

## 🔗 الموديلات المرتبطة
- `feature/chalet/data/models/chalet_model.dart` - نموذج الشاليه
- `feature/favorites/logic/favorites_cubit.dart` - إدارة المفضلات
