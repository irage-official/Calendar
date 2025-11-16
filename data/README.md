# Update Files

این فایل‌ها برای سیستم آپدیت اپ استفاده می‌شوند.

## فایل‌ها

### 1. `events-metadata.json`
این فایل برای چک کردن آپدیت events استفاده می‌شود.

**هر بار که `events.json` را تغییر می‌دهید:**
- `version` را افزایش دهید (مثلاً از `1.0.0` به `1.0.1`)
- `updated_at` را به تاریخ/زمان فعلی تغییر دهید
- `total_events` را به تعداد کل events تغییر دهید

**مثال:**
```json
{
  "version": "1.0.1",
  "updated_at": "2024-01-21T15:30:00Z",
  "total_events": 145
}
```

### 2. `version.json`
این فایل برای چک کردن آپدیت اپ استفاده می‌شود.

**وقتی می‌خواهید ورژن اپ را تغییر دهید:**

- **Bug fix / تغییرات کوچک:** `0.9.0` → `0.9.1` (update_type: `"normal"`)
- **Feature جدید:** `0.9.0` → `1.0.0` (update_type: `"critical"` یا `"major"`)
- **آپدیت اجباری:** `force_update: true`

**مثال برای bug fix:**
```json
{
  "version": "0.9.1",
  "build_number": 2,
  "update_type": "normal",
  "release_notes": "Fixed calendar display bug",
  "release_notes_fa": "رفع باگ نمایش تقویم",
  "download_url": "https://play.google.com/store/apps/details?id=...",
  "force_update": false
}
```

**مثال برای feature جدید:**
```json
{
  "version": "1.0.0",
  "build_number": 3,
  "update_type": "critical",
  "release_notes": "New search feature added!",
  "release_notes_fa": "قابلیت جستجو اضافه شد!",
  "download_url": "https://play.google.com/store/apps/details?id=...",
  "force_update": false
}
```

## نحوه استفاده

1. این فایل‌ها را در گیت repository خود در پوشه `data/` قرار دهید
2. URL گیت را در `lib/config/app_config.dart` تنظیم کنید:
   ```dart
   static const String githubRawBase = 'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/data';
   ```
3. اپ به صورت خودکار در splash screen این فایل‌ها را چک می‌کند

## نکات مهم

- این فایل‌ها باید در **گیت repository** باشند (نه در assets)
- URL باید به branch و path درست اشاره کند
- برای تست، می‌توانید از این فایل‌های محلی استفاده کنید

