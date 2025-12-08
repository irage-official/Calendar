# Keystore برای Release Build

این keystore برای امضای APK های release استفاده می‌شود.

## اطلاعات Keystore:
- **File**: `irage-release-key.jks`
- **Alias**: `irage`
- **Password**: `irage2024`
- **Validity**: 10000 days (~27 years)

## ⚠️ مهم:
- **هرگز** این فایل را در Git commit نکنید!
- این فایل در `.gitignore` قرار دارد
- از این keystore برای همه نسخه‌های APK (universal, arm64, arm, x86, x86_64) استفاده می‌شود

## استفاده:
برای build کردن APK با امضای release:
```bash
flutter build apk --release
```

یا برای build نسخه‌های جداگانه:
```bash
flutter build apk --release --split-per-abi
```

## Backup:
حتماً از این keystore یک backup بگیرید! اگر این فایل را از دست بدهید، نمی‌توانید APK های جدید را با همان امضا بسازید.

