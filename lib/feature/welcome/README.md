# 👋 README - Welcome Feature

## نظرة عامة
موديول شاشة الترحيب - نقطة البداية للمستخدمين غير المسجلين.

## 📁 هيكل المجلد

```
lib/feature/welcome/
└── ui/
    └── welcome_screen.dart         # شاشة الترحيب
```

## 🎯 المكونات الرئيسية

### WelcomeScreen
**الملف**: `lib/feature/welcome/ui/welcome_screen.dart`
- عرض Logo وصورة/Animation ترحيبية
- زر "تسجيل الدخول"
- زر "إنشاء حساب"
- زر "الدخول كزائر" (اختياري)

## 🔗 الـ Routes
- `Routes.welcomeScreen` - `/WelcomeScreen`

## 📦 الاعتماديات
- `flutter_bloc` - إدارة الحالة (إن وجد)

## 🔄 تدفق العمل
1. بعد Onboarding → WelcomeScreen
2. الخيارات المتاحة:
   - تسجيل الدخول → LoginScreen
   - إنشاء حساب → RegisterScreen
   - الدخول كزائر → HomeScreen (بعض الميزات محدودة)

## 🔗 الموديلات المرتبطة
- `feature/onboarding` - يأتي منه المستخدم
- `feature/auth/login` - تسجيل الدخول
- `feature/auth/register` - إنشاء حساب
- `feature/home` - الدخول كزائر
