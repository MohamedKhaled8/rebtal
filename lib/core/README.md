# 📋 README - Core Module

## نظرة عامة
هذا الموديول يحتوي على العناصر الأساسية والمشتركة للتطبيق بأكمله.

## 📁 هيكل المجلد

```
lib/core/
├── Router/                 # نظام التنقل والتوجيه
│   ├── app_router.dart     # المسؤول عن إنشاء الـ Routes وتوفير Animations
│   ├── export_routes.dart  # تصدير الـ Routes
│   └── routes.dart         # تعريفات constants للـ Routes
│
├── app/                    # إعدادات التطبيق العامة
│   ├── cubit/              # AppCubit - يدير حالة التطبيق (اللغة، الثيم، الألوان)
│   └── extensions/         # Extensions مخصصة
│
├── models/                 # الموديلات الأساسية المشتركة
│   ├── notification_model.dart    # نموذج الإشعارات
│   └── notification_type.dart     # أنواع الإشعارات
│
└── utils/                  # أدوات وخدمات مساعدة
    ├── animations/         # Animations مشتركة
    ├── config/             # إعدادات التطبيق
    ├── constant/           # Constants (assets, colors, strings)
    ├── dependency/         # GetIt - Dependency Injection
    ├── error/              # معالجة الأخطاء (Failure, exceptions)
    ├── format/             # تنسيق البيانات
    ├── function/             # دوال مساعدة
    ├── helper/             # Helpers (snackbars, dialogs, etc.)
    ├── localization/       # التعريب واللغات
    ├── model/              # موديلات مساعدة (user_model)
    ├── services/           # خدمات خارجية (Firebase, etc.)
    ├── theme/              # الثيم والألوان
    ├── validators/         # التحقق من صحة البيانات
    └── widgets/            # ويدجات مشتركة reusable
```

## 🎯 المكونات الرئيسية

### Router (`app_router.dart`)
- **الملف**: `lib/core/Router/app_router.dart`
- **الوظيفة**: إدارة جميع routes في التطبيق مع animations
- **الطرق الرئيسية**:
  - `generateRoute()`: إنشاء routes مع animations
  - `_buildAnimatedRoute()`: إنشاء animations مخصصة (Fade + Slide + Scale)

### AppCubit (`lib/core/app/cubit/app_cubit.dart`)
- **الوظيفة**: إدارة حالة التطبيق العامة
- **الحالات**:
  - اللغة (Locale)
  - وضع الثيم (ThemeMode)
  - اللون الأساسي (Primary Color)

### NotificationModel (`lib/core/models/notification_model.dart`)
- **الحقول**: id, userId, title, body, type, relatedId, data, isRead, createdAt
- **الاستخدام**: نموذج بيانات الإشعارات في Firestore

## 🔧 الاستخدام

```dart
// التنقل
Navigator.pushNamed(context, Routes.homeScreen);

// AppCubit
context.read<AppCubit>().changeLocale(Locale('ar'));
context.read<AppCubit>().toggleTheme();

// Dependency Injection
final useCase = getIt<LoginUseCase>();
```

## 📦 الاعتماديات
- `flutter_bloc` - لإدارة الحالة
- `get_it` - للـ Dependency Injection
- `dartz` - للـ Functional Programming (Either)

## 🔗 الموديلات المرتبطة
- جميع الـ Features تستخدم الـ Core
