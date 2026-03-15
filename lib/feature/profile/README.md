# 👤 README - Profile Feature

## نظرة عامة
موديول الملف الشخصي - إدارة بيانات المستخدم الشخصية والإعدادات.

## 📁 هيكل المجلد

```
lib/feature/profile/
├── ui/
│   ├── profile_page.dart           # الصفحة الرئيسية للملف الشخصي
│   ├── account_settings_page.dart  # إعدادات الحساب
│   ├── edit_profile_page.dart      # تعديل الملف الشخصي
│   ├── favorites_page.dart         # المفضلات
│   ├── help_support_page.dart      # المساعدة والدعم
│   ├── language_settings_page.dart # إعدادات اللغة
│   ├── privacy_settings_page.dart  # إعدادات الخصوصية
│   └── security_settings_page.dart # إعدادات الأمان
│
├── utils/
│   └── profile_utils.dart          # أدوات مساعدة للملف الشخصي
│
└── widget/
    ├── profile_content.dart        # محتوى الملف الشخصي الرئيسي
    ├── profile_header.dart         # رأس الصفحة (الصورة والاسم)
    ├── profile_menu_item.dart      # عنصر قائمة الملف الشخصي
    ├── profile_option_tile.dart    # بلاط خيار الملف الشخصي
    ├── profile_section.dart        # قسم في الملف الشخصي
    └── profile_stat_card.dart      # بطاقة إحصائية
```

## 🎯 المكونات الرئيسية

### ProfilePage
**الملف**: `lib/feature/profile/ui/profile_page.dart`
- الصفحة الرئيسية للملف الشخصي
- تعرض معلومات المستخدم والإعدادات

### ProfileContent
**الملف**: `lib/feature/profile/widget/profile_content.dart`
- المحتوى الرئيسي للملف الشخصي
- يحتوي على الأقسام المختلفة

### ProfileHeader
**الملف**: `lib/feature/profile/widget/profile_header.dart`
- رأس الصفحة مع صورة المستخدم والاسم
- الإحصائيات (الحجوزات، التقييمات، إلخ)

## 🔗 الـ Routes
- `Routes.profilePage` - `/profilePage`

## 📦 الاعتماديات
- `flutter_bloc` - إدارة الحالة
- `firebase_auth` - بيانات المستخدم
- `cloud_firestore` - تحديث البيانات

## 🔄 تدفق العمل
1. عرض بيانات المستخدم من Firebase Auth/Firestore
2. تعديل البيانات → حفظ في Firestore
3. تغيير الإعدادات (اللغة، الثيم) → AppCubit

## 🔗 الموديلات المرتبطة
- `core/app/cubit/app_cubit.dart` - إعدادات اللغة والثيم
- `feature/auth/domain/entities/user_entity.dart` - بيانات المستخدم
