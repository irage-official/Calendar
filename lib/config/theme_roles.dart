import 'package:flutter/material.dart';
import 'theme_colors.dart';

/// Light theme role tokens
class LightBg {
  // Backgrounds
  static const Color main = ThemeColors.white; // splash, settings
  static const Color home = ThemeColors.gray100;

  // Surfaces / containers
  static const Color bottomSheet = ThemeColors.white;
  static const Color card1 = ThemeColors.white;
  static const Color card2 = ThemeColors.white;
  static const Color card3 = ThemeColors.gray100;
  static const Color card4 = ThemeColors.gray200;

  // Buttons
  static const Color neutralButton = ThemeColors.gray400; // donation neutral buttons

  // Brand
  static const Color brandMain = ThemeColors.primary500;
  static const Color brandMd = ThemeColors.primary400;
  static const Color brandWeak = ThemeColors.primary300;
  static const Color brandTint = ThemeColors.primary100;
  static const Color brandTint2 = ThemeColors.primary50;

  // Semantic backgrounds
  static const Color successTint = ThemeColors.green50;
  static const Color successMain = ThemeColors.green500;

  static const Color errorTint = ThemeColors.red50;
  static const Color errorMain = ThemeColors.red500;

  static const Color informalTint = ThemeColors.informal50;
  static const Color informalMain = ThemeColors.informal500;

  static const Color warningTint = ThemeColors.yellow50;
  static const Color warningMain = ThemeColors.yellow500;
}

class LightCnt {
  // Neutral content (icon + text)
  static const Color neutralMain = ThemeColors.gray900;
  static const Color neutralSecond = ThemeColors.gray800;
  static const Color neutralTertiary = ThemeColors.gray700;
  static const Color neutralFourth = ThemeColors.gray600;
  static const Color neutralWeak = ThemeColors.gray500;
  static const Color unsurface = ThemeColors.white;

  // Brand content
  static const Color brandMain = ThemeColors.primary500;
  static const Color brandMd = ThemeColors.primary400;
  static const Color brandWeak = ThemeColors.primary300;
  static const Color brandTint = ThemeColors.primary100;

  // Semantic content
  static const Color errorMain = ThemeColors.red500;
  static const Color errorBold = ThemeColors.red600;
  static const Color errorMd = ThemeColors.red400;
  static const Color errorWeak = ThemeColors.red300;

  static const Color successMain = ThemeColors.green500;
  static const Color successBold = ThemeColors.green600;
  static const Color successMd = ThemeColors.green400;
  static const Color successWeak = ThemeColors.green300;

  static const Color informalMain = ThemeColors.informal500;
  static const Color informalBold = ThemeColors.informal600;
  static const Color informalMd = ThemeColors.informal400;
  static const Color informalWeak = ThemeColors.informal300;

  static const Color warningMain = ThemeColors.yellow500;
  static const Color warningBold = ThemeColors.yellow600;
  static const Color warningMd = ThemeColors.yellow400;
  static const Color warningWeak = ThemeColors.yellow300;
}

class LightBr {
  // Neutral borders
  static const Color neutralMain = ThemeColors.gray400;
  static const Color neutralSecondary = ThemeColors.gray300;
  static const Color neutralTertiary = ThemeColors.gray200;
  static const Color neutralStrong = ThemeColors.gray500;
  static const Color neutralWeak = ThemeColors.gray100;

  // Brand borders
  static const Color brandMain = ThemeColors.primary500;
  static const Color brandMd = ThemeColors.primary400;
  static const Color brandWeak = ThemeColors.primary300;
  static const Color brandTint = ThemeColors.primary100;

  // Semantic borders
  static const Color successTint = ThemeColors.green100;
  static const Color successWeak = ThemeColors.green300;
  static const Color successMain = ThemeColors.green500;

  static const Color errorTint = ThemeColors.red100;
  static const Color errorWeak = ThemeColors.red300;
  static const Color errorMain = ThemeColors.red500;

  static const Color informalTint = ThemeColors.informal100;
  static const Color informalWeak = ThemeColors.informal300;
  static const Color informalMain = ThemeColors.informal500;

  static const Color warningTint = ThemeColors.yellow100;
  static const Color warningWeak = ThemeColors.yellow300;
  static const Color warningMain = ThemeColors.yellow500;
}

/// Dark theme role tokens
class DarkBg {
  static const Color main = ThemeColors.gray900; // flipped main
  static const Color home = ThemeColors.gray950; // darker home

  static const Color bottomSheet = ThemeColors.gray900;
  static const Color card1 = ThemeColors.gray900;
  static const Color card2 = ThemeColors.gray800;
  static const Color card3 = ThemeColors.gray700;
  static const Color card4 = ThemeColors.gray600;

  static const Color neutralButton = ThemeColors.gray800;

  static const Color brandMain = ThemeColors.primary500;
  static const Color brandMd = ThemeColors.primary600;
  static const Color brandWeak = ThemeColors.primary700;
  static const Color brandTint = ThemeColors.primary900;
  static const Color brandTint2 = ThemeColors.primary950;

  static const Color successTint = ThemeColors.green950;
  static const Color successMain = ThemeColors.green500;

  static const Color errorTint = ThemeColors.red950;
  static const Color errorMain = ThemeColors.red500;

  static const Color informalTint = ThemeColors.informal950;
  static const Color informalMain = ThemeColors.informal500;

  static const Color warningTint = ThemeColors.yellow950;
  static const Color warningMain = ThemeColors.yellow500;
}

class DarkCnt {
  static const Color neutralMain = ThemeColors.white;
  static const Color neutralSecond = ThemeColors.gray200;
  static const Color neutralTertiary = ThemeColors.gray400;
  static const Color neutralFourth = ThemeColors.gray500;
  static const Color neutralWeak = ThemeColors.gray600;
  static const Color unsurface = ThemeColors.white;

  static const Color brandMain = ThemeColors.primary500;
  static const Color brandMd = ThemeColors.primary600;
  static const Color brandWeak = ThemeColors.primary700;
  static const Color brandTint = ThemeColors.primary800;

  static const Color errorMain = ThemeColors.red500;
  static const Color errorBold = ThemeColors.red700;
  static const Color errorMd = ThemeColors.red600;
  static const Color errorWeak = ThemeColors.red700;

  static const Color successMain = ThemeColors.green500;
  static const Color successBold = ThemeColors.green700;
  static const Color successMd = ThemeColors.green600;
  static const Color successWeak = ThemeColors.green700;

  static const Color informalMain = ThemeColors.informal500;
  static const Color informalBold = ThemeColors.informal700;
  static const Color informalMd = ThemeColors.informal600;
  static const Color informalWeak = ThemeColors.informal700;

  static const Color warningMain = ThemeColors.yellow500;
  static const Color warningBold = ThemeColors.yellow700;
  static const Color warningMd = ThemeColors.yellow600;
  static const Color warningWeak = ThemeColors.yellow700;
}

class DarkBr {
  static const Color neutralMain = ThemeColors.gray600;
  static const Color neutralSecondary = ThemeColors.gray700;
  static const Color neutralTertiary = ThemeColors.gray800;
  static const Color neutralStrong = ThemeColors.gray500;
  static const Color neutralWeak = ThemeColors.gray900;

  static const Color brandMain = ThemeColors.primary500;
  static const Color brandMd = ThemeColors.primary600;
  static const Color brandWeak = ThemeColors.primary700;
  static const Color brandTint = ThemeColors.primary900;

  static const Color successTint = ThemeColors.green800;
  static const Color successWeak = ThemeColors.green600;
  static const Color successMain = ThemeColors.green500;

  static const Color errorTint = ThemeColors.red800;
  static const Color errorWeak = ThemeColors.red600;
  static const Color errorMain = ThemeColors.red500;

  static const Color informalTint = ThemeColors.informal800;
  static const Color informalWeak = ThemeColors.informal600;
  static const Color informalMain = ThemeColors.informal500;

  static const Color warningTint = ThemeColors.yellow800;
  static const Color warningWeak = ThemeColors.yellow600;
  static const Color warningMain = ThemeColors.yellow500;
}

// Themed role helpers that pick Light/Dark based on current brightness
class TBg {
  static Color main(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBg.main : LightBg.main;
  static Color home(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBg.home : LightBg.home;
  static Color bottomSheet(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBg.bottomSheet : LightBg.bottomSheet;
  static Color card1(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBg.card1 : LightBg.card1;
  static Color card2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBg.card2 : LightBg.card2;
  static Color card3(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBg.card3 : LightBg.card3;
  static Color card4(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBg.card4 : LightBg.card4;
  static Color neutralButton(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBg.neutralButton : LightBg.neutralButton;
  static Color brandMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBg.brandMain : LightBg.brandMain;
}

class TCnt {
  // Helper to get actual brightness (works correctly with system theme mode)
  static Brightness _getActualBrightness(BuildContext context) {
    final theme = Theme.of(context);
    // If theme mode is system, use platform brightness, otherwise use theme brightness
    if (theme.brightness == Brightness.dark || theme.brightness == Brightness.light) {
      return theme.brightness;
    }
    // Fallback to MediaQuery for system mode
    return MediaQuery.of(context).platformBrightness;
  }

  static Color neutralMain(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.neutralMain : LightCnt.neutralMain;
  static Color neutralSecond(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.neutralSecond : LightCnt.neutralSecond;
  static Color neutralTertiary(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.neutralTertiary : LightCnt.neutralTertiary;
  static Color neutralFourth(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.neutralFourth : LightCnt.neutralFourth;
  static Color neutralWeak(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.neutralWeak : LightCnt.neutralWeak;
  static Color unsurface(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.unsurface : LightCnt.unsurface;

  static Color brandMain(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.brandMain : LightCnt.brandMain;
  static Color brandMd(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.brandMd : LightCnt.brandMd;
  static Color brandWeak(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.brandWeak : LightCnt.brandWeak;
  static Color brandTint(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.brandTint : LightCnt.brandTint;

  static Color errorMain(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.errorMain : LightCnt.errorMain;
  static Color errorBold(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.errorBold : LightCnt.errorBold;
  static Color errorMd(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.errorMd : LightCnt.errorMd;
  static Color errorWeak(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.errorWeak : LightCnt.errorWeak;

  static Color successMain(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.successMain : LightCnt.successMain;
  static Color successBold(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.successBold : LightCnt.successBold;
  static Color successMd(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.successMd : LightCnt.successMd;
  static Color successWeak(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.successWeak : LightCnt.successWeak;

  static Color informalMain(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.informalMain : LightCnt.informalMain;
  static Color informalBold(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.informalBold : LightCnt.informalBold;
  static Color informalMd(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.informalMd : LightCnt.informalMd;
  static Color informalWeak(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.informalWeak : LightCnt.informalWeak;

  static Color warningMain(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.warningMain : LightCnt.warningMain;
  static Color warningBold(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.warningBold : LightCnt.warningBold;
  static Color warningMd(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.warningMd : LightCnt.warningMd;
  static Color warningWeak(BuildContext context) =>
      _getActualBrightness(context) == Brightness.dark ? DarkCnt.warningWeak : LightCnt.warningWeak;
}

class TBr {
  static Color neutralMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.neutralMain : LightBr.neutralMain;
  static Color neutralSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.neutralSecondary : LightBr.neutralSecondary;
  static Color neutralTertiary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.neutralTertiary : LightBr.neutralTertiary;
  static Color neutralStrong(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.neutralStrong : LightBr.neutralStrong;
  static Color neutralWeak(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.neutralWeak : LightBr.neutralWeak;

  static Color brandMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.brandMain : LightBr.brandMain;
  static Color brandMd(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.brandMd : LightBr.brandMd;
  static Color brandWeak(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.brandWeak : LightBr.brandWeak;
  static Color brandTint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.brandTint : LightBr.brandTint;

  static Color successTint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.successTint : LightBr.successTint;
  static Color successWeak(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.successWeak : LightBr.successWeak;
  static Color successMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.successMain : LightBr.successMain;

  static Color errorTint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.errorTint : LightBr.errorTint;
  static Color errorWeak(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.errorWeak : LightBr.errorWeak;
  static Color errorMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.errorMain : LightBr.errorMain;

  static Color informalTint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.informalTint : LightBr.informalTint;
  static Color informalWeak(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.informalWeak : LightBr.informalWeak;
  static Color informalMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.informalMain : LightBr.informalMain;

  static Color warningTint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.warningTint : LightBr.warningTint;
  static Color warningWeak(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.warningWeak : LightBr.warningWeak;
  static Color warningMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? DarkBr.warningMain : LightBr.warningMain;
}


