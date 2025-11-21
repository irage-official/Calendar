import 'package:flutter/material.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../config/app_icons.dart';
import '../utils/svg_helper.dart';
import '../utils/font_helper.dart';

enum AlertType { warning, danger, success, informal }

class AlertMessageWidget extends StatelessWidget {
  final AlertType type;
  final String? title;
  final String? description;
  final Widget? child;
  final bool isPersian;

  const AlertMessageWidget({
    super.key,
    required this.type,
    this.title,
    this.description,
    this.child,
    required this.isPersian,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context).withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.6 : 1.0,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBorderColor(context).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and Title in a Row with 4px gap
          if (title != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(context).withOpacity(
                      Theme.of(context).brightness == Brightness.dark ? 0.0 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgIconWidget(
                      assetPath: _getIconPath(),
                      size: 24,
                      color: _getIconColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title!,
                    style: isPersian
                        ? FontHelper.getYekanBakh(
                            fontSize: 15,
                            height: 1.4, // 140%
                            letterSpacing: -0.098, // -0.7% of 14
                            color: TCnt.neutralMain(context),
                            fontWeight: FontWeight.w700,
                          )
                        : FontHelper.getInter(
                            fontSize: 15,
                            height: 1.4, // 140%
                            letterSpacing: -0.098, // -0.7% of 14
                            color: TCnt.neutralMain(context),
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                ),
              ],
            ),
          // Description with 4px gap from title/icon and 2px horizontal padding
          if (child != null) ...[
            SizedBox(height: title != null ? 4 : 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: child!,
            ),
          ] else if (description != null) ...[
            SizedBox(height: title != null ? 4 : 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                description!,
                style: isPersian
                    ? FontHelper.getYekanBakh(
                        fontSize: 12,
                        height: 1.6, // 160%
                        letterSpacing: -0.072, // -0.7% of 12
                        color: TCnt.neutralSecond(context),
                        fontWeight: FontWeight.w400,
                      )
                    : FontHelper.getInter(
                        fontSize: 12,
                        height: 1.6, // 160%
                        letterSpacing: -0.072, // -0.7% of 12
                        color: TCnt.neutralSecond(context),
                        fontWeight: FontWeight.w400,
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case AlertType.warning:
        return Theme.of(context).brightness == Brightness.dark ? DarkBg.warningTint : LightBg.warningTint;
      case AlertType.danger:
        return Theme.of(context).brightness == Brightness.dark ? DarkBg.errorTint : LightBg.errorTint;
      case AlertType.success:
        return Theme.of(context).brightness == Brightness.dark ? DarkBg.successTint : LightBg.successTint;
      case AlertType.informal:
        return Theme.of(context).brightness == Brightness.dark ? DarkBg.informalTint : LightBg.informalTint;
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (type) {
      case AlertType.warning:
        return TBr.warningMain(context);
      case AlertType.danger:
        return TBr.errorMain(context);
      case AlertType.success:
        return TBr.successMain(context);
      case AlertType.informal:
        return TBr.informalMain(context);
    }
  }

  Color _getIconBackgroundColor(BuildContext context) {
    switch (type) {
      case AlertType.warning:
        return _getBackgroundColor(context);
      case AlertType.danger:
        return _getBackgroundColor(context);
      case AlertType.success:
        return _getBackgroundColor(context);
      case AlertType.informal:
        return _getBackgroundColor(context);
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (type) {
      case AlertType.warning:
        return Theme.of(context).brightness == Brightness.dark ? ThemeColors.yellow700 : ThemeColors.yellow700;
      case AlertType.danger:
        return Theme.of(context).brightness == Brightness.dark ? ThemeColors.red700 : ThemeColors.red700;
      case AlertType.success:
        return Theme.of(context).brightness == Brightness.dark ? ThemeColors.green700 : ThemeColors.green700;
      case AlertType.informal:
        return Theme.of(context).brightness == Brightness.dark ? ThemeColors.informal700 : ThemeColors.informal700;
    }
  }

  String _getIconPath() {
    switch (type) {
      case AlertType.warning:
        return AppIcons.errorBadge;
      case AlertType.danger:
        return AppIcons.errorHexagonal;
      case AlertType.success:
        return AppIcons.checkCircle;
      case AlertType.informal:
        return AppIcons.infoCircleFill;
    }
  }
}

