import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../config/app_icons.dart';
import '../providers/app_provider.dart';

class CustomRadioButton extends StatelessWidget {
  final bool? isSelected;
  final VoidCallback? onTap;
  final String label;
  final bool isManualLabel;

  const CustomRadioButton({
    super.key,
    this.isSelected,
    this.onTap,
    required this.label,
    this.isManualLabel = false,
  });

  Widget _buildRichText(BuildContext context) {
    final bool isSelected = this.isSelected ?? false;
    final List<TextSpan> spans = [];
    
    // Regular expression to find text inside parentheses
    final RegExp parenthesesRegex = RegExp(r'\(([^)]+)\)');
    final String text = label;
    
    int lastIndex = 0;
    for (final Match match in parenthesesRegex.allMatches(text)) {
      // Add text before the parentheses
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            letterSpacing: -0.007,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: TCnt.neutralMain(context),
          ),
        ));
      }
      
      // Add text inside parentheses with different color
      spans.add(TextSpan(
        text: match.group(0), // This includes the parentheses
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          letterSpacing: -0.007,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          color: isSelected ? TCnt.neutralTertiary(context) : TCnt.neutralFourth(context),
        ),
      ));
      
      lastIndex = match.end;
    }
    
    // Add remaining text after the last parentheses
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          letterSpacing: -0.007,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          color: TCnt.neutralMain(context),
        ),
      ));
    }
    
    // If no parentheses found, return the original text
    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          letterSpacing: -0.007,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          color: TCnt.neutralMain(context),
        ),
      ));
    }
    
    // Determine text direction based on app language
    // But for labels that are primarily English (like "English (EN)"), always use LTR
    final bool isPersian = Provider.of<AppProvider>(context, listen: false).language == 'fa';
    // Check if label is primarily English (starts with English letters)
    final bool isPrimarilyEnglish = RegExp(r'^[A-Za-z]').hasMatch(text);
    final TextDirection textDirection = (isPersian && !isPrimarilyEnglish) ? TextDirection.rtl : TextDirection.ltr;
    
    return Directionality(
      textDirection: textDirection,
      child: RichText(
        text: TextSpan(children: spans),
        textDirection: textDirection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isManualLabel) {
      // Align based on app language: Persian -> left, English -> right
      final bool isPersian = Provider.of<AppProvider>(context).language == 'fa';
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Align(
          alignment: isPersian ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 1.4, // 140% line height
              letterSpacing: -0.007, // -0.7% letter spacing
              fontWeight: FontWeight.w400, // Regular
              color: TCnt.neutralTertiary(context),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          children: [
            // Radio button icon
            SizedBox(
              width: 24,
              height: 24,
              child: (isSelected ?? false)
                  ? SvgPicture.asset(
                      AppIcons.radioBt,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        ThemeColors.primary500,
                        BlendMode.srcIn,
                      ),
                    )
                  : SvgPicture.asset(
                      AppIcons.circle,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        TCnt.neutralFourth(context),
                        BlendMode.srcIn,
                      ),
                    ),
            ),
            const SizedBox(width: 6),
            // Label text
            Expanded(
            child: _buildRichText(context),
            ),
          ],
        ),
      ),
    );
  }
}
