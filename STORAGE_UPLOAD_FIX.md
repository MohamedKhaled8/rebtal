# حل مشكلة رفع الصور - Storage Upload Fix

## المشكلة
خطأ `object-not-found` عند محاولة رفع الصور إلى Firebase Storage.

## الأسباب المحتملة
1. **App Check غير مفعل بشكل صحيح** - المشكلة الأكثر شيوعاً
2. **قواعد Firebase Storage تمنع الرفع**
3. **Debug Token غير مفعل في Firebase Console**

## الحلول المطبقة

### 1. تحسين معالجة App Check
- إضافة محاولة لتحديث App Check token قبل كل محاولة رفع
- زيادة وقت الانتظار بين المحاولات للسماح لـ App Check بالعمل
- إضافة معلومات تفصيلية في الـ logs

### 2. تحسين معالجة الأخطاء
- معالجة خاصة لخطأ `object-not-found`
- زيادة عدد المحاولات إلى 20 محاولة
- زيادة timeout إلى 10 دقائق للملفات الكبيرة

### 3. طرق رفع متعددة
- `putFile` مع metadata
- `putFile` بدون metadata
- `putData` كبديل نهائي

## خطوات إصلاح App Check

### للـ Android:
1. افتح Firebase Console
2. اذهب إلى **App Check**
3. اختر تطبيق Android الخاص بك
4. في قسم **Debug tokens**، أضف Debug Token
5. للحصول على Debug Token:
   ```bash
   adb logcat | grep "FirebaseAppCheck"
   ```
   أو ابحث في الـ logs عن:
   ```
   FirebaseAppCheck: Enter this debug token into the allow list in the Firebase Console
   ```

### للـ iOS:
1. افتح Firebase Console
2. اذهب إلى **App Check**
3. اختر تطبيق iOS الخاص بك
4. في قسم **Debug tokens**، أضف Debug Token
5. للحصول على Debug Token، ابحث في الـ logs عن:
   ```
   FirebaseAppCheck: Enter this debug token into the allow list in the Firebase Console
   ```

## قواعد Firebase Storage الموصى بها

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload images
    match /chalets/{chaletId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.resource.size < 50 * 1024 * 1024; // 50MB max
    }
  }
}
```

## ملاحظات مهمة

1. **في وضع التطوير**: استخدم `AndroidProvider.debug` و `AppleProvider.debug`
2. **في الإنتاج**: استخدم `AndroidProvider.playIntegrity` و `AppleProvider.appAttest`
3. **Debug Token**: يجب إضافته في Firebase Console قبل أن يعمل App Check في وضع التطوير

## التحقق من الحل

بعد تطبيق الحلول:
1. تحقق من الـ logs - يجب أن ترى:
   ```
   ✅ App Check token available
   📤 Uploading image (attempt 1/20): ...
   ```
2. إذا استمرت المشكلة، تحقق من:
   - Debug Token مفعل في Firebase Console
   - قواعد Firebase Storage تسمح بالرفع
   - الاتصال بالإنترنت مستقر

## معلومات إضافية

- عدد المحاولات: 20 محاولة
- Timeout: 10 دقائق للملفات الكبيرة
- حجم الملف: لا يوجد حد (يتم التحكم به من قواعد Firebase Storage)

