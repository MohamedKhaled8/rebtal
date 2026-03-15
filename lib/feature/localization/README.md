# 🌐 README - Localization Feature

## نظرة عامة
موديول التعريب - تغيير لغة التطبيق بين العربية والإنجليزية.

## 📁 هيكل المجلد

```
lib/feature/localization/
├── logic/
│   ├── localization_cubit.dart    # إدارة حالة اللغة
│   └── localization_state.dart    # حالات اللغة
│
└── ui/
    └── language_selector.dart     # محدد اللغة
```

## 🎯 المكونات الرئيسية

### LocalizationCubit
**الملف**: `lib/feature/localization/logic/localization_cubit.dart`
- تغيير لغة التطبيق
- حفظ اللغة المختارة محلياً
- إشعار التطبيق بالتغيير

### LanguageSelector
**الملف**: `lib/feature/localization/ui/language_selector.dart`
- Dropdown/Dialog لاختيار اللغة
- عرض العلم + اسم اللغة
- التطبيق الفوري للتغيير

## 📦 الاعتماديات
- `shared_preferences` - حفظ اللغة المختارة
- `flutter_bloc` - إدارة الحالة
- `flutter_localizations` - دعم التعريب
- `intl` - تنسيق التواريخ والأرقام

## 🔄 تدفق العمل
1. المستخدم يختار اللغة من Profile → LanguageSettings
2. LocalizationCubit يغير اللغة
3. حفظ اللغة في SharedPreferences
4. تغيير Directionality (RTL/LTR)
5. إعادة بناء التطبيق باللغة الجديدة

## 🔗 الموديلات المرتبطة
- `core/app/cubit/app_cubit.dart` - يدير اللغة أيضاً
- `feature/profile` - إعدادات اللغة في الملف الشخصي
- `l10n/` - ملفات الترجمة (.arb)
