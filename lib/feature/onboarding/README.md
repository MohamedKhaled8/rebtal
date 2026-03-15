# 🚀 README - Onboarding Feature

## نظرة عامة
موديول Onboarding - شاشات التعريف بالتطبيق للمستخدمين الجدد.

## 📁 هيكل المجلد

```
lib/feature/onboarding/
├── data/
│   ├── onboarding_repository.dart   # Repository لبيانات Onboarding
│   ├── terms_repository.dart        # Repository للشروط والأحكام
│   └── local_data_source.dart       # مصدر البيانات المحلي
│
├── logic/
│   ├── cubit/
│   │   ├── onboarding_cubit.dart    # إدارة حالة Onboarding
│   │   └── terms_cubit.dart         # إدارة حالة الشروط
│   └── onboarding_state.dart        # حالات Onboarding
│
├── ui/
│   ├── onboarding_screen.dart       # شاشة Onboarding
│   └── terms_screen.dart            # شاشة الشروط والأحكام
│
└── widget/
    ├── onboarding_page.dart         # صفحة واحدة من Onboarding
    ├── onboarding_indicator.dart    # مؤشر التقدم
    ├── skip_button.dart             # زر التخطي
    └── next_button.dart             # زر التالي
```

## 🎯 المكونات الرئيسية

### OnboardingCubit
**الملف**: `lib/feature/onboarding/logic/cubit/onboarding_cubit.dart`
- إدارة حالة Onboarding
- التنقل بين الصفحات
- تحديد إذا كان Onboarding مكتمل

### TermsCubit
**الملف**: `lib/feature/onboarding/logic/cubit/terms_cubit.dart`
- قبول/رفض الشروط والأحكام
- حفظ حالة القبول محلياً

### OnboardingScreen
**الملف**: `lib/feature/onboarding/ui/onboarding_screen.dart`
- صفحات متعددة مع Swipe
- عرض مميزات التطبيق
- زر "ابدأ الآن" في الصفحة الأخيرة

### TermsScreen
**الملف**: `lib/feature/onboarding/ui/terms_screen.dart`
- عرض الشروط والأحكام
- checkbox للموافقة
- زر المتابعة

## 🔗 الـ Routes
- `Routes.onBardingScreen` - `/onBardingScreen`
- `Routes.termsScreen` - `/termsScreen`

## 📦 الاعتماديات
- `shared_preferences` - حفظ حالة Onboarding
- `flutter_bloc` - إدارة الحالة
- `smooth_page_indicator` - مؤشر الصفحات

## 🔄 تدفق العمل
1. فتح التطبيق لأول مرة → OnboardingScreen
2. عرض 3-4 صفحات تعريفية
3. آخر صفحة → زر "ابدأ الآن"
4. الانتقال إلى TermsScreen
5. الموافقة على الشروط → حفظ في SharedPreferences
6. الانتقال إلى WelcomeScreen

## 🔗 الموديلات المرتبطة
- `feature/welcome` - بعد اكتمال Onboarding
- `feature/auth` - التسجيل/تسجيل الدخول
