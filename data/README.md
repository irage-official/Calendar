# Update Files

These files are used for the app update system.

## Files

### 1. `events-metadata.json`
This file is used to check for events updates.

**Every time you modify `events.json`:**
- Increase the `version` (e.g., from `1.0.0` to `1.0.1`)
- Update `updated_at` to the current date/time
- Update `total_events` to the total number of events

**Example:**
```json
{
  "version": "1.0.1",
  "updated_at": "2024-01-21T15:30:00Z",
  "total_events": 145
}
```

### 2. `version.json`
This file is used to check for app updates.

**When you want to change the app version:**

- **Bug fix / minor changes:** `0.9.0` → `0.9.1` (update_type: `"normal"`)
- **New feature:** `0.9.0` → `1.0.0` (update_type: `"critical"` or `"major"`)
- **Force update:** `force_update: true`

**Example for bug fix:**
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

**Example for new feature:**
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

## How to Use

1. Place these files in your git repository in the `data/` folder
2. Configure the git URL in `lib/config/app_config.dart`:
   ```dart
   static const String githubRawBase = 'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/data';
   ```
3. The app automatically checks these files on the splash screen

## Important Notes

- These files must be in the **git repository** (not in assets)
- The URL must point to the correct branch and path
- For testing, you can use these local files

