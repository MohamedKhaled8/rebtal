# 🏖️ REBTAL - تطبيق حجز الشاليهات

## نظرة عامة على المشروع

REBTAL هو تطبيق Flutter لحجز الشاليهات يدعم ثلاثة أنواع من المستخدمين:
- **المستخدم العادي**: يستعرض ويحجز الشاليهات
- **المالك**: يضيف ويدير شاليهاته وحجوزاته
- **الأدمن**: يدير المستخدمين، الشاليهات، والمدفوعات

## 📁 هيكل المشروع

```
lib/
├── core/                          # ✅ [اقرأ README](core/README.md)
│   ├── Router/                    # التنقل والـ Routes
│   ├── app/                       # إعدادات التطبيق العامة
│   ├── models/                    # الموديلات المشتركة
│   └── utils/                     # الأدوات والخدمات
│
├── feature/                       # الميزات الرئيسية
│   ├── admin/                     # ✅ [اقرأ README](feature/admin/README.md) - لوحة تحكم الأدمن
│   ├── auth/                      # ✅ [اقرأ README](feature/auth/README.md) - تسجيل الدخول والتسجيل
│   ├── booking/                   # ✅ [اقرأ README](feature/booking/README.md) - الحجوزات
│   ├── chalet/                    # ✅ [اقرأ README](feature/chalet/README.md) - الشاليهات
│   ├── favorites/                 # ✅ [اقرأ README](feature/favorites/README.md) - المفضلات
│   ├── home/                      # ✅ [اقرأ README](feature/home/README.md) - الصفحة الرئيسية
│   ├── localization/              # ✅ [اقرأ README](feature/localization/README.md) - التعريب
│   ├── maps/                      # ✅ [اقرأ README](feature/maps/README.md) - الخرائط
│   ├── navigation/                # ✅ [اقرأ README](feature/navigation/README.md) - التنقل السفلي
│   ├── notifications/             # ✅ [اقرأ README](feature/notifications/README.md) - الإشعارات
│   ├── onboarding/                # ✅ [اقرأ README](feature/onboarding/README.md) - Onboarding
│   ├── owner/                     # ✅ [اقرأ README](feature/owner/README.md) - موديول المالك
│   ├── payment/                   # ✅ [اقرأ README](feature/payment/README.md) - المدفوعات
│   ├── profile/                   # ✅ [اقرأ README](feature/profile/README.md) - الملف الشخصي
│   ├── splash/                    # ✅ [اقرأ README](feature/splash/README.md) - شاشة البداية
│   └── welcome/                   # ✅ [اقرأ README](feature/welcome/README.md) - شاشة الترحيب
│
├── l10n/                          # ملفات الترجمة (.arb)
├── main.dart                      # نقطة الدخول
└── rebtal_app.dart                # التطبيق الرئيسي
```

## 🏗️ الهندسة المعمارية

### Clean Architecture + BLoC Pattern
```
┌─────────────────────────────────────────────────────┐
│                        UI                           │
│  (Screens → Widgets → Cubit/Bloc State Management) │
├─────────────────────────────────────────────────────┤
│                      Domain                         │
│  (Entities → UseCases → Repository Interfaces)     │
├─────────────────────────────────────────────────────┤
│                       Data                          │
│  (Models → Repository Implementation → DataSource) │
└─────────────────────────────────────────────────────┘
```

### الخدمات الخارجية
- **Firebase Auth** - المصادقة
- **Cloud Firestore** - قاعدة البيانات
- **Firebase Storage** - تخزين الصور
- **Firebase Cloud Messaging** - الإشعارات
- **Google Maps** - الخرائط

## 🗺️ Routes (التنقل)

### Routes الرئيسية (في `core/Router/routes.dart`):

| Route | Path | الوصف |
|-------|------|-------|
| `splashScreen` | `/splashScreen` | شاشة البداية |
| `welcomeScreen` | `/WelcomeScreen` | شاشة الترحيب |
| `onBardingScreen` | `/onBardingScreen` | Onboarding |
| `termsScreen` | `/termsScreen` | الشروط والأحكام |
| `loginScreen` | `/loginScreen` | تسجيل الدخول |
| `registerScreen` | `/registerScreen` | التسجيل |
| `emailVerification` | `/emailVerification` | التحقق من البريد |
| `homeScreen` | `/homeScreen` | الصفحة الرئيسية |
| `bottomNavigationBarScreen` | `/bottomNavigationBarScreen` | BottomNav |
| `ownerScreen` | `/ownerScreen` | إضافة شاليه (المالك) |
| `dashboardScreen` | `/dashboardScreen` | لوحة الأدمن |
| `profilePage` | `/profilePage` | الملف الشخصي |
| `notificationsPage` | `/notificationsPage` | الإشعارات |

### Routes المدفوعات:
| Route | Path | الوصف |
|-------|------|-------|
| `bookingConfirmationPage` | `/bookingConfirmationPage` | تأكيد الحجز |
| `paymentMethodSelection` | `/paymentMethodSelection` | اختيار طريقة الدفع |
| `adminPayments` | `/adminPayments` | إدارة المدفوعات |
| `cancellationPolicy` | `/cancellationPolicy` | سياسة الإلغاء |
| `refundRequest` | `/refundRequest` | طلب استرداد |
| `ratingPage` | `/ratingPage` | تقييم الحجز |
| `transactionHistory` | `/transactionHistory` | سجل المعاملات |

## 🎯 الموديلات الرئيسية

### UserModel (`core/utils/model/user_model.dart`)
```dart
- id, name, email, phone, photoUrl
- role (user/owner/admin)
- isEmailVerified, createdAt
```

### ChaletModel (`feature/chalet/data/models/chalet_model.dart`)
```dart
- id, name, description, location (lat, lng, address)
- price, images, amenities, rating
- ownerId, status (active/pending/inactive)
```

### BookingModel (`feature/booking/models/booking.dart`)
```dart
- id, chaletId, chaletName, ownerId, renterId
- startDate, endDate, numberOfDays, totalPrice
- depositAmount, remainingAmount
- status (pending/confirmed/cancelled/completed)
- paymentStatus (pending/paid/refunded)
```

### NotificationModel (`core/models/notification_model.dart`)
```dart
- id, userId, title, body, type
- relatedId, data, isRead, createdAt
```

## 🔄 تدفقات العمل الرئيسية

### 1. تسجيل مستخدم جديد
```
Splash → Onboarding → Welcome → Register → EmailVerification → Home
```

### 2. حجز شاليه
```
Home → ChaletDetails → BookingWizard → PaymentMethod → PaymentProof → BookingConfirmation
```

### 3. إضافة شاليه (المالك)
```
OwnerDashboard → AddChalet (Form + Images + Location) → OwnerChaletsList
```

### 4. تأكيد الدفع (الأدمن)
```
AdminDashboard → AdminPayments → ReviewProof → Approve/Reject → Notifications
```

## 🛠️ الاعتماديات الرئيسية

```yaml
dependencies:
  # Firebase
  firebase_core: ^2.x
  firebase_auth: ^4.x
  cloud_firestore: ^4.x
  firebase_storage: ^11.x
  firebase_messaging: ^14.x
  
  # State Management
  flutter_bloc: ^8.x
  
  # Dependency Injection
  get_it: ^7.x
  
  # Functional Programming
  dartz: ^0.10.x
  
  # Maps
  google_maps_flutter: ^2.x
  geolocator: ^10.x
  
  # UI
  cached_network_image: ^3.x
  table_calendar: ^3.x
  
  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.x
```

## 🚀 كيفية الاستخدام

### عند العمل على ميزة معينة:

1. **اقرأ README الخاص بالموديول** أولاً:
   - `lib/feature/X/README.md`

2. **افهم البنية**:
   - UI (Screens & Widgets)
   - Logic (Cubit/Bloc)
   - Domain (UseCases & Entities)
   - Data (Models & Repositories)

3. **الـ Routes المستخدمة** موجودة في:
   - `lib/core/Router/routes.dart`
   - `lib/core/Router/app_router.dart`

4. **الموديلات المرتبطة** مذكورة في كل README

## 📚 ملفات التوثيق الأخرى في المشروع

- `ARCHITECTURE.md` - التوثيق المعماري التفصيلي
- `MIGRATION_GUIDE.md` - دليل الترحيل
- `UI_MIGRATION_GUIDE.md` - دليل ترحيل UI
- `NOTIFICATIONS_SETUP.md` - إعداد الإشعارات
- `CONSTRUCTOR_INJECTION.md` - حقن المعاملات

## 📝 ملاحظات مهمة للمطورين

1. ** dependency injection** عبر `get_it` في `core/utils/dependency/get_it.dart`

2. **الـ UseCases** تستخدم `Either<Failure, Success>` من `dartz`

3. **الحالات** تدار عبر `Cubit` مع `BlocProvider` في `AppRouter`

4. **الصور** تحفظ في `Firebase Storage` والـ URL في `Firestore`

5. **اللغة** تتغير عبر `AppCubit` وتؤثر على `Directionality`

6. **الإشعارات** تصل عبر FCM وتحفظ في Firestore

---

**آخر تحديث**: 15 مارس 2026
**الإصدار**: Flutter 3.x
