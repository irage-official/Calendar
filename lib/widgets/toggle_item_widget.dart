import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../utils/font_helper.dart';
import '../providers/app_provider.dart';

/// Toggle item widget for Origins and Event Types selection
class ToggleItem extends StatelessWidget {
  const ToggleItem({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onChanged,
    this.origin,
    this.icon,
    this.isRtl = false,
  }) : assert(
          (origin != null && icon == null) || (origin == null && icon != null),
          'Either origin or icon must be provided',
        );

  final String title;
  final String description;
  final bool isSelected;
  final ValueChanged<bool> onChanged;
  final String? origin; // For origin items (iranian, international, etc.)
  final Widget? icon; // For event type items
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appProvider = Provider.of<AppProvider>(context);
    final isPersian = appProvider.language == 'fa';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!isSelected),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 60.0, // Fixed height to prevent size changes
          ),
          padding: EdgeInsets.only(
            left: isRtl ? 14.0 : 10.0,
            right: isRtl ? 10.0 : 14.0, // 14px padding from card edge
            top: 10.0,
            bottom: 10.0,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? TCnt.brandMain(context).withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: !isSelected
                ? Border.all(
                    color: TBr.neutralTertiary(context).withOpacity(
                      isDark ? 0.3 : 1.0,
                    ),
                    width: 1,
                  )
                : Border.all(
                    color: Colors.transparent,
                    width: 1,
                  ),
          ),
          child: Row(
            children: [
              // Origin dot or Event type icon
              if (origin != null)
                _buildOriginDot(context)
              else if (icon != null)
                _buildEventTypeIcon(context, isDark),
              
              const SizedBox(width: 8),
              
              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: isPersian
                          ? FontHelper.getYekanBakh(
                              fontSize: 14,
                              height: 1.4, // 140%
                              letterSpacing: -0.098, // -0.7% of 14 = -0.098
                              fontWeight: isSelected
                                  ? FontWeight.w600 // semi-bold for better visibility
                                  : FontWeight.w400, // regular
                              color: TCnt.neutralMain(context),
                            )
                          : FontHelper.getInter(
                              fontSize: 14,
                              height: 1.4, // 140%
                              letterSpacing: -0.098, // -0.7% of 14 = -0.098
                              fontWeight: isSelected
                                  ? FontWeight.w600 // semi-bold for better visibility
                                  : FontWeight.w400, // regular
                              color: TCnt.neutralMain(context),
                            ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: isPersian
                          ? FontHelper.getYekanBakh(
                              fontSize: 12,
                              height: 1.4, // 140%
                              letterSpacing: -0.084, // -0.7% of 12 = -0.084
                              color: isSelected
                                  ? TCnt.neutralTertiary(context)
                                  : TCnt.neutralFourth(context),
                            )
                          : FontHelper.getInter(
                              fontSize: 12,
                              height: 1.4, // 140%
                              letterSpacing: -0.084, // -0.7% of 12 = -0.084
                              color: isSelected
                                  ? TCnt.neutralTertiary(context)
                                  : TCnt.neutralFourth(context),
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Toggle switch (Cupertino style) - smaller size with Apple green color
              SizedBox(
                width: 38.25, // 51 * 0.75 = 38.25 (reduced width to match scale)
                child: Transform.scale(
                  scale: 0.75, // Make switch smaller
                  alignment: Alignment.centerRight, // Align to right
                  child: CupertinoSwitch(
                    value: isSelected,
                    onChanged: onChanged,
                    activeColor: const Color(0xFF34C759), // Apple green color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOriginDot(BuildContext context) {
    if (origin == null) return const SizedBox.shrink();
    
    final color = AppColors.getEventTypeColor(origin!);
    
    return SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer border (outside)
            Container(
              width: 12, // 6 + 3*2
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            // Inner circle
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TBg.bottomSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeIcon(BuildContext context, bool isDark) {
    if (icon == null) return const SizedBox.shrink();
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected
            ? TBg.bottomSheet(context)
            : (isDark
                ? ThemeColors.gray100.withOpacity(0.08)
                : ThemeColors.gray950.withOpacity(0.05)),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon!,
      ),
    );
  }
}

