# راهنمای تنظیم آیکون اپلیکیشن

## مشکل حل شده ✅

- ✅ بک‌گراند سفید حذف شد
- ✅ لوگو کل فضای آیکون را پر می‌کند
- ✅ از آیکون‌های معمولی (غیر adaptive) استفاده می‌شود

## نحوه استفاده

### تولید آیکون‌ها

برای تولید آیکون‌ها، این دستور را اجرا کنید:

```bash
flutter pub run flutter_launcher_icons && ./remove_adaptive_icon.sh
```

یا به صورت جداگانه:

```bash
flutter pub run flutter_launcher_icons
./remove_adaptive_icon.sh
```

### نکات مهم

1. **فایل لوگو باید بک‌گراند شفاف داشته باشد**
   - اگر `logo_2.png` بک‌گراند سفید دارد، باید آن را حذف کنید
   - می‌توانید از ابزارهای آنلاین مانند [remove.bg](https://www.remove.bg) استفاده کنید
   - یا از SVG استفاده کنید که معمولاً بک‌گراند شفاف دارد

2. **لوگو باید کل فضای آیکون را پر کند**
   - لوگو باید در اندازه 1024x1024 یا بزرگتر باشد
   - لوگو باید حدود 80-90% از فضای آیکون را پر کند

3. **بعد از تغییر لوگو**
   - دستور تولید آیکون را دوباره اجرا کنید
   - اپلیکیشن را دوباره build کنید

## ساخت اپلیکیشن

بعد از تولید آیکون‌ها:

```bash
# برای Android
flutter build apk

# برای iOS
flutter build ios

# برای Web
flutter build web
```

## بررسی آیکون‌ها

- **Android**: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- **iOS**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Web**: `web/icons/`

## مشکل هنوز حل نشده؟

اگر هنوز بک‌گراند سفید می‌بینید:

1. بررسی کنید که فایل `logo_2.png` بک‌گراند شفاف دارد
2. فایل adaptive icon را بررسی کنید: `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
   - اگر وجود دارد، آن را حذف کنید
3. اپلیکیشن را دوباره build کنید

