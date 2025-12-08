# راهنمای تنظیم Keystore برای GitHub Actions

## مشکل قبلی
APK های release با debug key sign می‌شدند که باعث می‌شد نصب نشوند.

## راه حل
یک keystore برای release ایجاد شده و باید به GitHub Secrets اضافه شود.

## مراحل تنظیم

### 1. Keystore ایجاد شده
- **مسیر:** `android/app/upload-keystore.jks`
- **Alias:** `upload`
- **Password:** `irage2024`

### 2. اضافه کردن به GitHub Secrets

1. به repository خود در GitHub بروید
2. Settings > Secrets and variables > Actions
3. New repository secret را کلیک کنید
4. این 4 secret را اضافه کنید:

#### Secret 1: KEYSTORE_BASE64
- **Name:** `KEYSTORE_BASE64`
- **Value:** محتوای base64 شده keystore (از فایل `/tmp/keystore_base64.txt` کپی کنید)

#### Secret 2: KEYSTORE_PASSWORD
- **Name:** `KEYSTORE_PASSWORD`
- **Value:** `irage2024`

#### Secret 3: KEY_ALIAS
- **Name:** `KEY_ALIAS`
- **Value:** `upload`

#### Secret 4: KEY_PASSWORD
- **Name:** `KEY_PASSWORD`
- **Value:** `irage2024`

### 3. بررسی
بعد از اضافه کردن secrets، workflow بعدی به صورت خودکار از keystore استفاده می‌کند و APK ها به درستی sign می‌شوند.

## نکات مهم

⚠️ **هشدار امنیتی:**
- Keystore file (`upload-keystore.jks`) در `.gitignore` است و commit نمی‌شود
- فایل `key.properties` هم در `.gitignore` است
- **هرگز** keystore یا password ها را در repository commit نکنید
- اگر keystore را گم کردید، باید یک keystore جدید ایجاد کنید و version code را افزایش دهید

## تست محلی

برای تست build محلی:
```bash
flutter build apk --release
```

APK در `build/app/outputs/flutter-apk/app-release.apk` ایجاد می‌شود و با keystore sign شده است.

