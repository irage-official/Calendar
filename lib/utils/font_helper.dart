import 'package:flutter/material.dart';

/// Helper class for font management
/// Uses local Inter font (English) and local YekanBakh for Persian
class FontHelper {
  /// YekanBakh font weight mappings
  /// Thin: 1, Light: 150, Regular: 325, Medium: 390, SemiBold: 450, Bold: 600, ExtraBold: 725, Black: 875, ExtraBlack: 1000
  static int getYekanBakhWeight(FontWeight? fontWeight) {
    if (fontWeight == null) return 325; // Regular
    
    // Map Flutter FontWeight to YekanBakh weights
    switch (fontWeight) {
      case FontWeight.w100:
        return 1; // Thin
      case FontWeight.w200:
      case FontWeight.w300:
        return 150; // Light
      case FontWeight.w400:
      case FontWeight.normal:
        return 325; // Regular
      case FontWeight.w500:
        return 390; // Medium
      case FontWeight.w600:
        return 450; // SemiBold
      case FontWeight.w700:
      case FontWeight.bold:
        return 600; // Bold
      case FontWeight.w800:
        return 725; // ExtraBold
      case FontWeight.w900:
        return 875; // Black
      default:
        return 325; // Regular as default
    }
  }
  
  /// Get Inter font weight value (standard 100-900 for Variable Font)
  /// Inter Variable Font uses standard weight values
  static double getInterWeight(FontWeight? fontWeight) {
    if (fontWeight == null) return 400.0; // Regular
    
    // Map Flutter FontWeight to Inter Variable Font weights (100-900)
    switch (fontWeight) {
      case FontWeight.w100:
        return 100.0;
      case FontWeight.w200:
        return 200.0;
      case FontWeight.w300:
        return 300.0;
      case FontWeight.w400:
      case FontWeight.normal:
        return 400.0;
      case FontWeight.w500:
        return 500.0;
      case FontWeight.w600:
        return 600.0;
      case FontWeight.w700:
      case FontWeight.bold:
        return 700.0;
      case FontWeight.w800:
        return 800.0;
      case FontWeight.w900:
        return 900.0;
      default:
        return 400.0; // Regular as default
    }
  }
  
  /// Get Inter font from local assets for English text
  /// Inter is a Variable Font, so we use fontVariations for proper weight control
  static TextStyle getInter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    final interWeight = getInterWeight(fontWeight);
    
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight, // Keep for compatibility and fallback
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: [
        FontVariation('wght', interWeight),
      ],
    );
  }
  
  /// Get YekanBakh font for Persian text (local Variable Font)
  /// Uses fontVariations to set the exact weight for Variable Font
  /// IMPORTANT: Always use this method instead of creating TextStyle directly with fontFamily: 'YekanBakh'
  /// 
  /// This method uses fontVariations to set precise weights for the Variable Font.
  /// The weights are mapped from Flutter's FontWeight to YekanBakh's specific weight values.
  static TextStyle getYekanBakh({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    final yekanBakhWeight = getYekanBakhWeight(fontWeight);
    
    // Use fontVariations for precise weight control with Variable Font
    // This should work on Flutter 3.0+ on most platforms
    return TextStyle(
      fontFamily: 'YekanBakh',
      fontSize: fontSize,
      fontWeight: fontWeight, // Keep for compatibility and fallback
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: [
        FontVariation('wght', yekanBakhWeight.toDouble()),
      ],
    );
  }
  
  /// Helper to create YekanBakh TextStyle from an existing TextStyle
  /// This ensures fontVariations are always applied
  static TextStyle createYekanBakhFromStyle(TextStyle style, {FontWeight? overrideWeight}) {
    final weight = overrideWeight ?? style.fontWeight;
    final yekanBakhWeight = getYekanBakhWeight(weight);
    
    return style.copyWith(
      fontFamily: 'YekanBakh',
      fontVariations: [
        FontVariation('wght', yekanBakhWeight.toDouble()),
      ],
    );
  }
  
  /// Get font based on language (Persian or English)
  /// This is the recommended method to use throughout the app
  static TextStyle getFontByLanguage({
    required bool isPersian,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    if (isPersian) {
      return getYekanBakh(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    } else {
      return getInter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }
  }
  
  /// Get font family string (for cases where you need the string, not TextStyle)
  /// Returns 'Inter' for English and 'YekanBakh' for Persian
  static String? getFontFamilyString(bool isPersian) {
    return isPersian ? 'YekanBakh' : 'Inter';
  }
  
  /// Apply YekanBakh font variations to an existing TextStyle
  /// This converts Flutter FontWeight to YekanBakh-specific weights
  static TextStyle applyYekanBakhWeight(TextStyle style) {
    if (style.fontFamily != 'YekanBakh') {
      return style; // Not YekanBakh, return as is
    }
    
    final yekanBakhWeight = getYekanBakhWeight(style.fontWeight);
    
    return style.copyWith(
      fontVariations: [
        FontVariation('wght', yekanBakhWeight.toDouble()),
      ],
    );
  }
  
  /// Create a TextStyle with YekanBakh font and proper weight
  /// This is a convenience method that combines fontFamily and fontVariations
  static TextStyle yekanBakhTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    final yekanBakhWeight = getYekanBakhWeight(fontWeight);
    
    return TextStyle(
      fontFamily: 'YekanBakh',
      fontSize: fontSize,
      fontWeight: fontWeight, // Keep for compatibility
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: [
        FontVariation('wght', yekanBakhWeight.toDouble()),
      ],
    );
  }
}

/// Extension to add YekanBakh font variations to existing TextStyle
/// IMPORTANT: Use this extension on any TextStyle that has fontFamily: 'YekanBakh'
extension YekanBakhTextStyleExtension on TextStyle {
  /// Apply YekanBakh font weight variations if fontFamily is YekanBakh
  /// This MUST be called on any TextStyle with fontFamily: 'YekanBakh' to ensure proper weights
  TextStyle withYekanBakhWeight() {
    if (fontFamily != 'YekanBakh') {
      return this; // Not YekanBakh, return as is
    }
    
    final yekanBakhWeight = FontHelper.getYekanBakhWeight(fontWeight);
    
    return copyWith(
      fontVariations: [
        FontVariation('wght', yekanBakhWeight.toDouble()),
      ],
    );
  }
}

