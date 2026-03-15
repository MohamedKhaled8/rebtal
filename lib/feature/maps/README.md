# 🗺️ README - Maps Feature

## نظرة عامة
موديول الخرائط - عرض مواقع الشاليهات على الخريطة وتحديد المواقع.

## 📁 هيكل المجلد

```
lib/feature/maps/
├── logic/
│   └── (empty)                   # يستخدم ChaletMapCubit من ChaletFeature
│
└── ui/
    ├── map_screen.dart           # شاشة الخريطة
    ├── chalet_map_view.dart      # عرض شاليه على الخريطة
    └── location_picker.dart      # اختيار موقع على الخريطة
```

## 🎯 المكونات الرئيسية

### MapScreen
**الملف**: `lib/feature/maps/ui/map_screen.dart`
- عرض جميع الشاليهات على الخريطة
- فلترة الشاليهات حسب المنطقة
- الانتقال إلى تفاصيل الشاليه عند النقر على marker

### ChaletMapView
**الملف**: `lib/feature/maps/ui/chalet_map_view.dart`
- عرض موقع شاليه واحد على الخريطة
- عرض معلومات الشاليه في info window

### LocationPicker
**الملف**: `lib/feature/maps/ui/location_picker.dart`
- اختيار موقع الشاليه عند الإضافة
- الحصول على إحداثيات GPS
- تأكيد الموقع المختار

## 📦 الاعتماديات
- `google_maps_flutter` - خرائطة Google
- `geolocator` - تحديد الموقع الحالي
- `geocoding` - تحويل العنوان إلى إحداثيات
- `flutter_bloc` - إدارة الحالة

## 🔄 تدفق العمل
1. عرض الشاليهات على الخريطة → MapScreen
2. النقر على marker → عرض تفاصيل الشاليه
3. عند إضافة شاليه → LocationPicker لتحديد الموقع
4. تحويل العنوان إلى إحداثيات → Geocoding
5. حفظ الإحداثيات في Firestore

## 🔗 الموديلات المرتبطة
- `feature/chalet` - بيانات مواقع الشاليهات
- `feature/owner` - تحديد موقع الشاليه عند الإضافة
- `feature/home` - الانتقال من قائمة الشاليهات إلى الخريطة
