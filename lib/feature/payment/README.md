# 💳 README - Payment Feature

## نظرة عامة
موديول المدفوعات - معالجة الدفعات، طرق الدفع، والإيصالات.

## 📁 هيكل المجلد

```
lib/feature/payment/
├── models/
│   └── payment_model.dart        # نموذج بيانات الدفع
│
└── ui/
    ├── new_payment_method_page.dart    # اختيار طريقة الدفع
    ├── payment_confirmation_page.dart  # تأكيد الدفع
    ├── payment_instructions_page.dart # تعليمات الدفع
    ├── payment_proof_upload_page.dart # رفع إثبات الدفع
    ├── payment_receipt_page.dart      # إيصال الدفع
    ├── payment_status_page.dart       # حالة الدفع
    └── payment_success_page.dart      # نجاح الدفع
```

## 🎯 المكونات الرئيسية

### PaymentModel
**الملف**: `lib/feature/payment/models/payment_model.dart`
- **الحقول**:
  - id, bookingId, userId, ownerId
  - amount, paymentMethod, status
  - proofImageUrl, transactionId
  - createdAt, updatedAt

### NewPaymentMethodPage
**الملف**: `lib/feature/payment/ui/new_payment_method_page.dart`
- اختيار طريقة الدفع (فودافون كاش، انستا باي، كاش)
- حساب الدفعة المقدمة والمتبقية
- التوجيه لتعليمات الدفع

### PaymentProofUploadPage
**الملف**: `lib/feature/payment/ui/payment_proof_upload_page.dart`
- رفع صورة إثبات التحويل
- عرض رقم التحويل
- تأكيد استلام الدفع

## 🔗 الـ Routes
- `Routes.paymentMethodSelection` - `/paymentMethodSelection`
- `Routes.paymentInstructions` - `/paymentInstructions`
- `Routes.paymentProofUpload` - `/paymentProofUpload`
- `Routes.adminPayments` - `/adminPayments`

## 📦 الاعتماديات
- `cloud_firestore` - تخزين بيانات الدفع
- `firebase_storage` - تخزين إثباتات الدفع
- `image_picker` - اختيار صور
- `flutter_bloc` - إدارة الحالة

## 🔄 تدفق العمل
1. المستخدم يختار طريقة دفع → NewPaymentMethodPage
2. عرض تعليمات الدفع (رقم التحويل)
3. المستخدم يحول المبلغ
4. رفع صورة الإثبات → PaymentProofUploadPage
5. الـ Admin يتحقق من الدفع
6. تأكيد الحجز وإشعار للمالك

## 🔗 الموديلات المرتبطة
- `feature/booking` - الحجز المرتبط بالدفع
- `feature/admin` - إدارة المدفوعات من قبل الأدمن
- `feature/owner` - استلام المدفوعات
