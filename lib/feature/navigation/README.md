# 🧭 README - Navigation Feature

## نظرة عامة
موديول التنقل - Bottom Navigation Bar للتنقل بين الصفحات الرئيسية.

## 📁 هيكل المجلد

```
lib/feature/navigation/
└── ui/
    ├── bottom_navigation_screen.dart   # شاشة التنقل السفلي
    └── main_layout.dart                # التخطيط الرئيسي
```

## 🎯 المكونات الرئيسية

### BottomNavigationScreen
**الملف**: `lib/feature/navigation/ui/bottom_navigation_screen.dart`
- BottomNavigationBar مع 4-5 tabs
- إدارة حالة التنقل
- حفظ index المحدد

### MainLayout
**الملف**: `lib/feature/navigation/ui/main_layout.dart`
- التخطيط الرئيسي للتطبيق
- يحتوي على BottomNav + PageView
- Smooth transitions بين الصفحات

## 📦 الاعتماديات
- `flutter_bloc` - إدارة حالة التنقل
- `persistent_bottom_nav_bar_v2` - BottomNavBar متقدم (إن وجد)

## 🔄 تدفق العمل
1. تسجيل الدخول → Splash → Home
2. عرض BottomNavigationBar مع:
   - Home (الصفحة الرئيسية)
   - Favorites (المفضلات)
   - Bookings (حجوزاتي)
   - Profile (الملف الشخصي)
3. النقر على tab → تغيير الصفحة
4. حفظ حالة كل صفحة

## 🔗 الموديلات المرتبطة
- `feature/home` - Tab الرئيسية
- `feature/favorites` - Tab المفضلات
- `feature/booking` - Tab الحجوزات
- `feature/profile` - Tab الملف الشخصي
