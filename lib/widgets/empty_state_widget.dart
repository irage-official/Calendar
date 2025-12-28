import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/theme_roles.dart';
import '../utils/svg_helper.dart';
import '../utils/font_helper.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isPersian;

  const EmptyStateWidget({
    super.key,
    this.isPersian = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check if dark mode - use actual brightness (same logic as TCnt)
    final theme = Theme.of(context);
    Brightness actualBrightness;
    if (theme.brightness == Brightness.dark || theme.brightness == Brightness.light) {
      actualBrightness = theme.brightness;
    } else {
      // System mode - use platform brightness
      actualBrightness = MediaQuery.of(context).platformBrightness;
    }
    final isDarkMode = actualBrightness == Brightness.dark;
    final opacity = isDarkMode ? 0.75 : 1.0;
    
    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 48.0, // 48-pixel horizontal padding as per design
          vertical: AppDimensions.paddingXL,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon - calen-fill, 32x32, neutral fourth, no background
            SvgIconWidget(
              assetPath: 'assets/images/icons/calen-fill.svg',
              size: 32,
              color: TCnt.neutralWeak(context),
            ),
            
            // Spacing between icon and content - 12 pixels
            const SizedBox(height: 12),
            
            // Title - font size 14, semi-bold, neutral main, line height 140%, letter spacing -2%
            Text(
              isPersian ? 'یک روز آرام در گاه‌شمار' : 'A Quiet Day on the Calendar.',
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TCnt.neutralMain(context),
                      height: 1.4,
                      letterSpacing: -0.28, // -2% of 14px
                    )
                  : FontHelper.getInter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TCnt.neutralMain(context),
                      height: 1.4,
                      letterSpacing: -0.28, // -2% of 14px
                    ),
              textAlign: TextAlign.center,
            ),
            
            // Gap between title and description - 4 pixels
            const SizedBox(height: 4),
            
            // Description - font size 12, neutral tertiary, line height 140%, letter spacing -0.7%
            Text(
              isPersian ? 'هیچ رویداد ملی یا جهانی مهمی برای این تاریخ ثبت نشده است. از آرامش امروز لذت ببرید.' : 'No significant national or global events are marked for this date. Enjoy the calm.',
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: TCnt.neutralTertiary(context),
                      height: 1.4,
                      letterSpacing: -0.084, // -0.7% of 12px
                    )
                  : FontHelper.getInter(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: TCnt.neutralTertiary(context),
                      height: 1.4,
                      letterSpacing: -0.084, // -0.7% of 12px
                    ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
