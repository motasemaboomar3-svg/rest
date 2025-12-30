# customer_app

## GitHub Actions build

هذا المشروع جاهز للبناء تلقائياً على GitHub Actions:

- يَبني **Android APK (debug)** + **Flutter Web (release)**.
- بعد كل Push على الفرع `main` ستجد الملفات في:
  - تبويب **Actions** ➜ افتح آخر Run ➜ **Artifacts** ➜ `app-debug-apk` و `web-build`.

ملاحظة: إذا صار خطأ `gradlew is not executable` فحلّه موجود داخل الـ workflow (chmod).
