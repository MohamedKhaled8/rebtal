# خطوات سريعة لتفعيل الإشعارات العائمة

## 1. نشر Cloud Functions (مطلوب مرة واحدة فقط)

```bash
# افتح Terminal في مجلد المشروع
cd "e:\Mt FlutterProject\rebtal"

# تسجيل الدخول إلى Firebase
firebase login

# الانتقال لمجلد Functions
cd functions

# تثبيت المكتبات
npm install

# العودة للمجلد الرئيسي
cd ..

# نشر Functions
firebase deploy --only functions
```

## 2. اختبار الإشعارات

بعد نشر Functions، الإشعارات ستعمل تلقائياً في الحالات التالية:

### ✅ إشعارات تلقائية عند:
- تغيير حالة الحجز (موافقة، رفض، تأكيد، إلغاء)
- حجز جديد للمالك
- أي إشعار يتم إرساله من التطبيق

### ✅ الإشعارات تظهر:
- في شريط الإشعارات
- مع صوت
- حتى لو كان التطبيق مغلقاً
- مع اهتزاز (Android)

## 3. التحقق من عمل Functions

```bash
# عرض سجلات Functions
firebase functions:log
```

أو من Firebase Console:
1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. اختر مشروعك
3. اذهب إلى Functions
4. راجع Logs

## 4. اختبار يدوي

يمكنك اختبار الإشعارات من Firebase Console:
1. اذهب إلى Cloud Messaging
2. اضغط "Send your first message"
3. أدخل العنوان والمحتوى
4. اختر التطبيق
5. أرسل

## ملاحظات مهمة

- ✅ الكود جاهز ومُعد بالكامل
- ✅ الإعدادات في AndroidManifest تمت إضافتها
- ✅ Cloud Functions جاهزة للنشر
- ⚠️ تحتاج فقط لنشر Functions مرة واحدة
- ⚠️ تأكد من تفعيل Billing في Firebase (مجاني حتى حد معين)

## استكشاف الأخطاء

### إذا لم تظهر الإشعارات:
1. تأكد من نشر Functions بنجاح
2. راجع Logs في Firebase Console
3. تأكد من منح التطبيق إذن الإشعارات
4. أعد تشغيل التطبيق بعد النشر

### للحصول على المساعدة:
راجع ملف `NOTIFICATIONS_SETUP.md` للتفاصيل الكاملة
