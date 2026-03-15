# 🔐 README - Auth Feature

## نظرة عامة
موديول المصادقة والتسجيل - يدير جميع عمليات تسجيل الدخول والخروج والتسجيل والتحقق من البريد الإلكتروني.

## 📁 هيكل المجلد

```
lib/feature/auth/
├── cubit/
│   └── auth_cubit.dart           # إدارة حالة المصادقة العامة
│
├── domain/
│   ├── entities/
│   │   └── user_entity.dart      # كيان المستخدم
│   └── usecases/
│       ├── login_usecase.dart         # تسجيل الدخول
│       ├── register_usecase.dart      # التسجيل
│       ├── resend_email_verification_usecase.dart  # إعادة إرسال التحقق
│       └── save_user_usecase.dart     # حفظ بيانات المستخدم
│
├── email_verification/
│   ├── ui/email_verification_screen.dart
│   └── logic/email_verification_cubit.dart
│
├── forgot_password/
│   └── ui/                        # شاشة استعادة كلمة المرور
│
├── login/
│   ├── ui/login_screen.dart
│   └── logic/login_cubit.dart
│
├── register/
│   ├── ui/resgister_screen.dart
│   ├── logic/register_cubit.dart
│   └── widget/                    # ويدجات خاصة بالتسجيل
│
├── repository/
│   ├── auth_repository.dart        # تنفيذ الـ Repository
│   └── base_auth_repository.dart   # الواجهة الأساسية
│
└── widget/
    └── auth_widgets.dart         # ويدجات مشتركة
```

## 🎯 المكونات الرئيسية

### LoginUseCase
**الملف**: `lib/feature/auth/domain/usecases/login_usecase.dart`
```dart
Future<Either<Failure, UserModel>> call({
  required String email,
  required String password,
})
```

### RegisterUseCase
**الملف**: `lib/feature/auth/domain/usecases/register_usecase.dart`
- إنشاء حساب جديد في Firebase Auth
- حفظ بيانات المستخدم في Firestore

### EmailVerificationCubit
**الملف**: `lib/feature/auth/email_verification/logic/email_verification_cubit.dart`
- التحقق من تأكيد البريد الإلكتروني
- إعادة إرسال رابط التحقق
- التحقق الدوري من حالة التحقق

## 🔗 الـ Routes
- `Routes.loginScreen` - `/loginScreen`
- `Routes.registerScreen` - `/registerScreen`
- `Routes.emailVerification` - `/emailVerification`

## 📦 الاعتماديات
- `firebase_auth` - مصادقة Firebase
- `cloud_firestore` - قاعدة البيانات
- `flutter_bloc` - إدارة الحالة
- `dartz` - Either<Failure, Success>

## 🔄 تدفق العمل
1. المستخدم يدخل البريد والباسورد → LoginUseCase
2. إذا كان البريد غير مؤكد → EmailVerificationScreen
3. التسجيل يحتاج إلى: الاسم، البريد، الباسورد، رقم الهاتف، نوع الحساب

## 🔗 الموديلات المرتبطة
- `core/utils/model/user_model.dart` - نموذج المستخدم
- `core/Router/app_router.dart` - التنقل بعد تسجيل الدخول
