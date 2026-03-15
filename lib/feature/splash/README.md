# 🌊 README - Splash Feature

## نظرة عامة
موديول شاشة البداية - فحص المصادقة والتنقل إلى الصفحة المناسبة.

## 📁 هيكل المجلد

```
lib/feature/splash/
└── ui/
    └── splash_screen.dart          # شاشة البداية
```

## 🎯 المكونات الرئيسية

### SplashScreen
**الملف**: `lib/feature/splash/ui/splash_screen.dart`
- عرض Logo و Animation
- فحص حالة المستخدم:
  - هل قام بإكمال Onboarding؟
  - هل مسجل الدخول؟
  - نوع المستخدم (عادي/مالك/أدمن)؟
- التنقل التلقائي بعد 2-3 ثواني

## 🔗 الـ Routes
- `Routes.splashScreen` - `/splashScreen` (الـ initial route)

## 📦 الاعتماديات
- `firebase_auth` - فحص حالة المصادقة
- `shared_preferences` - فحص Onboarding
- `cloud_firestore` - جلب نوع المستخدم

## 🔄 تدفق العمل
1. عرض Animation للـ Logo
2. فحص SharedPreferences (Onboarding مكتمل؟)
   - لا → OnboardingScreen
3. فحص FirebaseAuth (مسجل دخول؟)
   - لا → WelcomeScreen
4. جلب بيانات المستخدم من Firestore
5. تحديد نوع المستخدم:
   - عادي → HomeScreen
   - مالك → OwnerDashboard
   - أدمن → AdminDashboard

## 🔗 الموديلات المرتبطة
- `feature/onboarding` - إذا لم يكمل Onboarding
- `feature/welcome` - إذا لم يسجل دخول
- `feature/home` - المستخدم العادي
- `feature/owner` - المالك
- `feature/admin` - الأدمن
