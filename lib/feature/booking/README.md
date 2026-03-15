# 📅 README - Booking Feature

## نظرة عامة
موديول الحجوزات - إدارة عمليات الحجز، التأكيد، الإلغاء، والمدفوعات.

## 📁 هيكل المجلد

```
lib/feature/booking/
├── data/
│   ├── booking_repository.dart     # Repository الحجوزات
│   └── models/
│       └── booking.dart            # نموذج الحجز
│
├── logic/
│   ├── booking_cubit.dart          # إدارة حالة الحجز الرئيسية
│   └── wizard_cubit/
│       ├── booking_wizard_cubit.dart   # معالج خطوات الحجز
│       └── booking_wizard_state.dart
│
├── models/
│   └── booking.dart                # نموذج بيانات الحجز (مكرر)
│
├── ui/
│   ├── booking_confirmation_page.dart  # تأكيد الحجز
│   ├── booking_details_page.dart       # تفاصيل الحجز
│   ├── booking_list_page.dart          # قائمة الحجوزات
│   ├── booking_wizard_screen.dart      # معالج الحجز
│   ├── cancellation_policy_page.dart   # سياسة الإلغاء
│   ├── create_booking_page.dart        # إنشاء حجز جديد
│   ├── rating_page.dart                # تقييم الحجز
│   ├── refund_request_page.dart        # طلب استرداد
│   └── transaction_history_page.dart   # سجل المعاملات
│
└── widgets/
    ├── booking_card.dart           # بطاقة الحجز
    ├── booking_date_picker.dart   # اختيار تاريخ الحجز
    ├── booking_price_summary.dart # ملخص الأسعار
    ├── booking_status_badge.dart  # شارة حالة الحجز
    └── booking_timeline.dart      # خط زمني للحجز
```

## 🎯 المكونات الرئيسية

### BookingModel
**الملف**: `lib/feature/booking/models/booking.dart`
- **الحقول**: 
  - id, chaletId, chaletName, ownerId, renterId
  - startDate, endDate, numberOfDays
  - totalPrice, depositAmount, remainingAmount
  - status (pending, confirmed, cancelled, completed)
  - paymentStatus, createdAt, updatedAt

### BookingCubit
**الملف**: `lib/feature/booking/logic/booking_cubit.dart`
- إدارة حالة الحجز
- إنشاء حجز جديد
- تحديث حالة الحجز
- جلب قائمة الحجوزات

### BookingWizardCubit
**الملف**: `lib/feature/booking/logic/wizard_cubit/booking_wizard_cubit.dart`
- خطوات معالج الحجز
- اختيار التواريخ
- إدخال بيانات الضيوف
- تأكيد الحجز

## 🔗 الـ Routes
- `Routes.bookingConfirmationPage` - `/bookingConfirmationPage`
- `Routes.cancellationPolicy` - `/cancellationPolicy`
- `Routes.refundRequest` - `/refundRequest`
- `Routes.ratingPage` - `/ratingPage`
- `Routes.transactionHistory` - `/transactionHistory`
- `Routes.paymentMethodSelection` - `/paymentMethodSelection`

## 📦 الاعتماديات
- `cloud_firestore` - تخزين الحجوزات
- `flutter_bloc` - إدارة الحالة
- `table_calendar` - اختيار التواريخ
- `intl` - تنسيق التواريخ والعملات

## 🔄 تدفق العمل
1. المستخدم يختار شاليه → ChaletDetailsScreen
2. اختيار التواريخ → BookingWizard
3. حساب السعر (عدد الأيام × السعر اليومي)
4. تأكيد الحجز → إنشاء Booking في Firestore
5. الدفع → PaymentModule
6. إشعار للمالك → NotificationsModule

## 🔗 الموديلات المرتبطة
- `feature/chalet` - اختيار الشاليه
- `feature/payment` - معالجة الدفع
- `feature/notifications` - إشعارات الحجز
- `feature/owner` - إدارة الحجوزات من قبل المالك
