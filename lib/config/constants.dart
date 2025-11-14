import 'package:flutter/material.dart';
import 'theme_colors.dart';
import 'theme_roles.dart';

class AppColors {
  // Use the new theme colors
  static const Color primaryBackground = ThemeColors.background;
  static const Color secondaryBackground = ThemeColors.surface;
  static const Color festivalGreen = ThemeColors.green500;
  static const Color remembranceRed = ThemeColors.red500;
  static const Color gregorianBlue = ThemeColors.informal500;
  
  // Event Type Colors with Opacity
  static const Color festivalGreenOpacity = Color(0x2600B383); // 15% opacity
  static const Color remembranceRedOpacity = Color(0x26F25B65); // 15% opacity
  static const Color gregorianBlueOpacity = Color(0x260095FF); // 15% opacity
  
  // Event Type Colors for Donut Charts (Hardcoded)
  // Iranian - قرمز مایل به رز – برای رویدادهای ملی و یادبودها
  static const Color eventTypeIranian = Color(0xFFE94A4A);
  
  // International - آبی روشن – جهانی، رسمی و هماهنگ با تم اپ
  static const Color eventTypeInternational = Color(0xFF3B82F6);
  
  // Mixed - نارنجی ملایم – بین‌المللی + ایرانی، ترکیبی و گرم
  static const Color eventTypeMixed = Color(0xFFF59E0B);
  
  // Local - سبز مایل به فیروزه‌ای – محلی، طبیعی، نزدیک به جامعه
  static const Color eventTypeLocal = Color(0xFF10B981);
  
  /// Get color for event type/origin
  /// Maps event origin to its corresponding donut chart color
  static Color getEventTypeColor(String eventOrigin) {
    switch (eventOrigin.toLowerCase()) {
      case 'iranian':
        return eventTypeIranian;
      case 'international':
        return eventTypeInternational;
      case 'mixed':
        return eventTypeMixed;
      case 'local':
        return eventTypeLocal;
      default:
        // Fallback to international color for unknown types
        return eventTypeInternational;
    }
  }
  
  /// Get all event type colors in order
  /// Returns colors in the order: Iranian, International, Mixed, Local
  static List<Color> getEventTypeColors() {
    return [
      eventTypeIranian,
      eventTypeInternational,
      eventTypeMixed,
      eventTypeLocal,
    ];
  }
  
  // Text Colors
  static const Color textPrimary = ThemeColors.gray900;
  static const Color textSecondary = ThemeColors.gray600;
  static const Color textTertiary = ThemeColors.gray500;
  
  // UI Colors
  static const Color borderColor = ThemeColors.gray200;
  static const Color accentColor = ThemeColors.primary500;
  static const Color errorColor = ThemeColors.error;
  static const Color successColor = ThemeColors.success;
  static const Color warningColor = ThemeColors.warning;
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = ThemeColors.white;
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
}

class AppDimensions {
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXL = 24.0;
  
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: LightCnt.neutralMain,
    fontFamily: 'Inter',
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: LightCnt.neutralMain,
    fontFamily: 'Inter',
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: LightCnt.neutralMain,
    fontFamily: 'Inter',
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralMain,
    fontFamily: 'Inter',
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralMain,
    fontFamily: 'Inter',
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralWeak,
    fontFamily: 'Inter',
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralWeak,
    fontFamily: 'Inter',
  );
  
  // Persian Text Styles
  static const TextStyle persianHeading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: LightCnt.neutralMain,
    fontFamily: 'Vazir',
  );
  
  static const TextStyle persianHeading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: LightCnt.neutralMain,
    fontFamily: 'Vazir',
  );
  
  static const TextStyle persianBodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralMain,
    fontFamily: 'Vazir',
  );
  
  static const TextStyle persianBodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralMain,
    fontFamily: 'Vazir',
  );
  
  static const TextStyle persianHeading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: LightCnt.neutralMain,
    fontFamily: 'Vazir',
  );
  
  static const TextStyle persianBodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralWeak,
    fontFamily: 'Vazir',
  );
}
