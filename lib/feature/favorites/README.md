# ⭐ README - Favorites Feature

## نظرة عامة
موديول المفضلات - إدارة قائمة الشاليهات المفضلة للمستخدم.

## 📁 هيكل المجلد

```
lib/feature/favorites/
├── logic/
│   ├── favorites_cubit.dart      # إدارة حالة المفضلات
│   └── favorites_state.dart      # حالات المفضلات
│
└── ui/
    └── favorites_page.dart       # صفحة المفضلات
```

## 🎯 المكونات الرئيسية

### FavoritesCubit
**الملف**: `lib/feature/favorites/logic/favorites_cubit.dart`
- إضافة/إزالة شاليه من المفضلات
- جلب قائمة المفضلات
- التحقق إذا كان الشاليه في المفضلات

### FavoritesState
**الملف**: `lib/feature/favorites/logic/favorites_state.dart`
- `FavoritesInitial` - الحالة الأولية
- `FavoritesLoading` - جاري التحميل
- `FavoritesLoaded` - تم تحميل المفضلات
- `FavoritesError` - خطأ في التحميل

### FavoritesPage
**الملف**: `lib/feature/favorites/ui/favorites_page.dart`
- عرض قائمة الشاليهات المفضلة
- إمكانية إزالة من المفضلات
- الانتقال إلى تفاصيل الشاليه

## 📦 الاعتماديات
- `cloud_firestore` - تخزين المفضلات
- `flutter_bloc` - إدارة الحالة
- `firebase_auth` - معرف المستخدم

## 🔄 تدفق العمل
1. المستخدم ينقر على أيقونة القلب في ChaletCard
2. التحقق من تسجيل الدخول
3. إضافة/إزالة من Firestore (collection: favorites)
4. تحديث الـ UI
5. عرض المفضلات في FavoritesPage

## 🔗 الموديلات المرتبطة
- `feature/chalet` - عرض بيانات الشاليهات المفضلة
- `feature/home` - أيقونة المفضلات في ChaletCard
- `feature/auth` - التحقق من تسجيل الدخول
