import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../config/app_icons.dart';
import '../config/theme_roles.dart';
import '../providers/app_provider.dart';
import '../utils/calendar_utils.dart';
import '../utils/extensions.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

class CalendarHeaderWidget extends StatelessWidget {
  final String monthName;        // "October" or "مهر"
  final int year;                // 2025
  final VoidCallback? onAddReminder;   // Currently disabled
  final VoidCallback onMultitasking;  // Opens year picker
  final VoidCallback? onSearch;        // Opens search (currently disabled)
  final VoidCallback onSettings;      // Opens settings
  final bool isPersian;          // Whether the calendar is Persian (Jalali) or Gregorian

  const CalendarHeaderWidget({
    super.key,
    required this.monthName,
    required this.year,
    this.onAddReminder,
    required this.onMultitasking,
    this.onSearch,
    required this.onSettings,
    this.isPersian = false,
  });

  /// Determine the font family for month/year display based on app language and calendar type
  String _getMonthYearFontFamily(String language, bool isPersian) {
    // When app is in English and calendar is Gregorian: Use Inter
    // When app is in Persian and calendar is Jalali: Use Vazir
    if (language == 'en' && !isPersian) {
      return 'Inter';
    } else if (language == 'fa' && isPersian) {
      return 'Vazir';
    }
    // Default fallback
    return 'Inter';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, // 32px button + 16px padding (8px top + 8px bottom)
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: const BoxDecoration(),
      width: double.infinity, // Ensure full width
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Proper justification
        children: [
          // Left Icon Buttons Group
          Row(
            children: [
              _buildIconButton(
                context: context,
                iconPath: AppIcons.calendarPlus,
                onTap: onAddReminder,
                isEnabled: false, // Disabled for now
              ),
              
              const SizedBox(width: 8),
              
              _buildIconButton(
                context: context,
                iconPath: AppIcons.multitasking,
                onTap: onMultitasking,
                isEnabled: true,
              ),
            ],
          ),
          
          // Month/Year Display (clickable) - Centered
          GestureDetector(
            onTap: onMultitasking, // Same as multitasking button
            child: _buildMonthYearDisplay(),
          ),
          
          // Right Icon Buttons Group
          Row(
            children: [
              _buildIconButton(
                context: context,
                iconPath: AppIcons.search,
                onTap: onSearch,
                isEnabled: false, // Disabled for now
              ),
              
              const SizedBox(width: 8),
              
              _buildIconButton(
                context: context,
                iconPath: AppIcons.settings,
                onTap: onSettings,
                isEnabled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required String iconPath,
    required VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isEnabled) {
              if (onTap != null) onTap();
            } else {
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              final isPersianLang = appProvider.language == 'fa';
              final msg = isPersianLang
                  ? 'این قابلیت فعلاً در دسترس نیست. به زودی فعال می‌شود.'
                  : 'This feature is not available yet. Coming soon!';
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              // Use floating toast
              // ignore: use_build_context_synchronously
              context.showToast(msg);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Transform(
                alignment: Alignment.center,
                transform: isRtl ? (Matrix4.identity()..rotateY(3.1415926535)) : Matrix4.identity(),
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isEnabled ? TCnt.neutralTertiary(context) : TCnt.neutralWeak(context),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearDisplay() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final fontFamily = _getMonthYearFontFamily(appProvider.language, isPersian);
        final isPersianLang = appProvider.language == 'fa';
        
        // Convert year to proper numerals based on language
        final yearString = isPersianLang 
            ? CalendarUtils.englishToPersianDigits(year.toString())
            : year.toString();
        
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              // Month name - bold, gray900
              TextSpan(
                text: monthName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: TCnt.neutralMain(context),
                  fontFamily: fontFamily,
                  height: 1.4, // 140% line height
                  letterSpacing: -0.02, // -2%
                ),
              ),
              // Space between month and year
              const TextSpan(text: ' '),
              // Year - regular, gray700
              TextSpan(
                text: yearString,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: TCnt.neutralTertiary(context),
                  fontFamily: fontFamily,
                  height: 1.4, // 140% line height
                  letterSpacing: -0.02, // -2%
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
