# راهنمای آماده‌سازی iOS Build برای انتشار در App Store

## 🔧 مرحله 1: رفع مشکل iOS SDK

### مشکل فعلی:
`xcode-select` به Command Line Tools اشاره می‌کند، نه به Xcode کامل.

### راه حل:
این دستور را در ترمینال اجرا کنید (نیاز به پسورد دارد):

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### بررسی:
پس از اجرا، این دستورات را اجرا کنید:

```bash
# بررسی نسخه Xcode
xcodebuild -version

# بررسی SDK
xcrun --show-sdk-path --sdk iphonesimulator

# بررسی Flutter
flutter doctor
```

---

## 📱 مرحله 2: تنظیمات اولیه Xcode

### 1. باز کردن Xcode و پذیرش لایسنس:
```bash
# باز کردن Xcode (یک بار)
open /Applications/Xcode.app

# یا پذیرش لایسنس از ترمینال
sudo xcodebuild -license accept
```

### 2. نصب Command Line Tools از Xcode:
- Xcode را باز کنید
- Settings (یا Preferences) > Locations
- Command Line Tools را انتخاب کنید

---

## 🏗️ مرحله 3: تنظیمات پروژه iOS

### 1. بررسی Podfile:
Podfile در مسیر `ios/Podfile` باید حداقل iOS 13.0 را پشتیبانی کند (فعلاً تنظیم شده است).

### 2. نصب CocoaPods dependencies:
```bash
cd ios
pod install
cd ..
```

### 3. بررسی Info.plist:
اطمینان حاصل کنید که `ios/Runner/Info.plist` شامل تمام مجوزهای لازم است:
- Camera (اگر استفاده می‌کنید)
- Photo Library (اگر استفاده می‌کنید)
- Location (اگر استفاده می‌کنید)
- و غیره...

---

## 🎯 مرحله 4: تنظیمات App Store Connect

### 1. ایجاد App ID در Apple Developer:
- به [developer.apple.com](https://developer.apple.com) بروید
- Certificates, Identifiers & Profiles > Identifiers
- App ID جدید ایجاد کنید (مثلاً: `com.yourcompany.iranianheritagecalendar`)

### 2. تنظیم Bundle Identifier:
**⚠️ مهم**: Bundle Identifier فعلی `com.example.iranianHeritageCalendar` است و باید تغییر کند.

**روش 1: از طریق Xcode (پیشنهادی)**
```bash
open ios/Runner.xcworkspace
```
- Runner > Signing & Capabilities
- Bundle Identifier را به App ID شما تغییر دهید (مثلاً: `com.yourcompany.irage`)

**روش 2: از طریق فایل project.pbxproj**
در `ios/Runner.xcodeproj/project.pbxproj`:
- جستجو کنید: `PRODUCT_BUNDLE_IDENTIFIER = com.example.iranianHeritageCalendar;`
- همه موارد را به Bundle ID جدید تغییر دهید

### 3. ایجاد Provisioning Profile:
- در Apple Developer Portal
- Certificates, Identifiers & Profiles > Profiles
- App Store Distribution profile ایجاد کنید

---

## 📦 مرحله 5: Build برای App Store

### 1. Archive در Xcode:
```bash
# باز کردن پروژه در Xcode
open ios/Runner.xcworkspace

# سپس در Xcode:
# Product > Scheme > Runner
# Product > Destination > Any iOS Device
# Product > Archive
```

### 2. یا از طریق Flutter CLI:
```bash
# Build برای iOS (Release)
flutter build ipa

# یا برای Simulator (تست)
flutter build ios --simulator
```

### 3. آپلود به App Store Connect:
- از Xcode: Window > Organizer > Archives > Distribute App
- یا از طریق `altool`:
```bash
xcrun altool --upload-app --type ios --file build/ios/ipa/your_app.ipa --apiKey YOUR_API_KEY --apiIssuer YOUR_ISSUER_ID
```

---

## ✅ چک‌لیست قبل از انتشار

### تنظیمات اولیه:
- [ ] `xcode-select` به Xcode کامل اشاره می‌کند (`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`)
- [ ] Xcode لایسنس پذیرفته شده است (`sudo xcodebuild -license accept`)
- [ ] CocoaPods dependencies نصب شده‌اند (`cd ios && pod install`)
- [ ] `flutter doctor` بدون خطا اجرا می‌شود

### تنظیمات پروژه:
- [ ] Bundle Identifier از `com.example.iranianHeritageCalendar` تغییر کرده است
- [ ] App ID در Apple Developer ایجاد شده است (مطابق با Bundle ID جدید)
- [ ] Provisioning Profile برای App Store ایجاد شده است
- [ ] App Icon و Launch Screen تنظیم شده‌اند
- [ ] Version و Build Number در `pubspec.yaml` به‌روزرسانی شده‌اند

### تست:
- [ ] تست روی Simulator انجام شده است (`flutter run -d ios`)
- [ ] تست روی دستگاه واقعی انجام شده است
- [ ] تمام قابلیت‌ها (Share, URL Launcher) تست شده‌اند

### App Store Connect:
- [ ] اپلیکیشن در App Store Connect ایجاد شده است
- [ ] Screenshots و Metadata آماده شده‌اند
- [ ] Privacy Policy URL تنظیم شده است (در صورت نیاز)

---

## 🚀 دستورات سریع

```bash
# بررسی وضعیت
flutter doctor

# Clean و rebuild
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Build برای تست
flutter build ios --simulator

# Build برای انتشار
flutter build ipa
```

---

## 📝 نکات مهم

1. **Version Number**: در `pubspec.yaml` باید version را به‌روز کنید:
   ```yaml
   version: 1.0.0+1  # version+buildNumber
   ```

2. **Minimum iOS Version**: در `ios/Podfile` حداقل iOS 13.0 تنظیم شده است (مناسب است)

3. **Signing**: در Xcode > Runner > Signing & Capabilities باید:
   - Team را انتخاب کنید
   - Automatically manage signing را فعال کنید
   - یا Provisioning Profile را دستی تنظیم کنید

4. **App Store Connect**: قبل از آپلود، اپلیکیشن را در App Store Connect ایجاد کنید

---

## 🆘 عیب‌یابی

### اگر `pod install` خطا داد:
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
```

### اگر Build خطا داد:
```bash
flutter clean
flutter pub get
cd ios
pod deintegrate
pod install
cd ..
flutter build ios
```

### اگر Simulator SDK پیدا نشد:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
xcodebuild -runFirstLaunch
```

---

## 📚 منابع

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

