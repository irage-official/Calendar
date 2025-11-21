import 'package:flutter/material.dart';
import 'theme_colors.dart';
import 'theme_roles.dart';
import '../utils/font_helper.dart';

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
  // English text styles using local Inter font
  // Note: Cannot be const because FontHelper.getInter() uses fontVariations
  static TextStyle get heading1 => FontHelper.getInter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: LightCnt.neutralMain,
  );
  
  static TextStyle get heading2 => FontHelper.getInter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: LightCnt.neutralMain,
  );
  
  static TextStyle get heading3 => FontHelper.getInter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: LightCnt.neutralMain,
  );
  
  static TextStyle get bodyLarge => FontHelper.getInter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralMain,
  );
  
  static TextStyle get bodyMedium => FontHelper.getInter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralMain,
  );
  
  static TextStyle get bodySmall => FontHelper.getInter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralWeak,
  );
  
  static TextStyle get caption => FontHelper.getInter(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralWeak,
  );
  
  // Persian Text Styles
  // Note: Cannot be const because FontHelper.getYekanBakh() uses fontVariations
  static TextStyle get persianHeading1 => FontHelper.getYekanBakh(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: LightCnt.neutralMain,
  );
  
  static TextStyle get persianHeading2 => FontHelper.getYekanBakh(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: LightCnt.neutralMain,
  );
  
  static TextStyle get persianBodyLarge => FontHelper.getYekanBakh(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralMain,
  );
  
  static TextStyle get persianBodyMedium => FontHelper.getYekanBakh(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralMain,
  );
  
  static TextStyle get persianHeading3 => FontHelper.getYekanBakh(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: LightCnt.neutralMain,
  );
  
  static TextStyle get persianBodySmall => FontHelper.getYekanBakh(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: LightCnt.neutralWeak,
  );
}
