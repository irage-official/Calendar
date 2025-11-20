import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../config/app_icons.dart';
import '../utils/font_helper.dart';
import '../providers/app_provider.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

class SettingItem extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showArrow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showArrow = true,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final appProvider = Provider.of<AppProvider>(context);
    final isPersian = appProvider.language == 'fa';
    
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(8),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: isRtl ? (Matrix4.identity()..rotateY(3.1415926535)) : Matrix4.identity(),
                    child: SvgPicture.asset(
                      icon,
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        ThemeColors.primary500,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: isPersian
                                ? FontHelper.getYekanBakh(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: TCnt.neutralMain(context),
                                    height: 1.4,
                                    letterSpacing: -0.007,
                                  )
                                : AppTextStyles.bodyLarge.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: TCnt.neutralMain(context),
                                    height: 1.4,
                                    letterSpacing: -0.007,
                                  ),
                          ),
                        ),
                        if (subtitle != null) ...[
                          Text(
                            subtitle!,
                            style: isPersian
                                ? FontHelper.getYekanBakh(
                                    fontSize: 12,
                                    color: TCnt.neutralFourth(context),
                                    height: 1.4,
                                    letterSpacing: -0.007,
                                  )
                                : AppTextStyles.bodySmall.copyWith(
                                    fontSize: 12,
                                    color: TCnt.neutralFourth(context),
                                    height: 1.4,
                                    letterSpacing: -0.007,
                                  ),
                          ),
                        ],
                        if (showArrow) ...[
                          if (subtitle != null) const SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(4),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: isRtl ? (Matrix4.identity()..rotateY(3.1415926535)) : Matrix4.identity(),
                              child: SvgPicture.asset(
                                AppIcons.chevronRight,
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  TCnt.neutralWeak(context),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
