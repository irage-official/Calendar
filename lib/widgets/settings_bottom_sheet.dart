import 'package:flutter/material.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';

class SettingsBottomSheet extends StatelessWidget {
  final String title;
  final String? description;
  final Widget content;
  final VoidCallback? onClose;
  final IconData? titleIcon;

  const SettingsBottomSheet({
    super.key,
    required this.title,
    this.description,
    required this.content,
    this.onClose,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close bottom sheet when tapping outside
        Navigator.of(context).pop();
      },
      child: Stack(
        clipBehavior: Clip.none, // Allow overflow for drag handle
        children: [
          GestureDetector(
            onTap: () {
              // Prevent closing when tapping inside the bottom sheet
            },
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
              decoration: BoxDecoration(
                color: TBg.bottomSheet(context),
                borderRadius: const BorderRadius.all(Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24), // پدینگ داخلی ۲۴ پیکسل
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header section
                    _buildHeader(context),
                    
                    // Content section
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16), // فقط گپ ۱۶ پیکسل بالا
                          child: content,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Drag handle - floating outside the box with overflow
          // 12px gap between handle and top of bottom sheet
          Positioned(
            top: -16, // -4 (handle height) - 12 (gap) = -16
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeColors.white.withOpacity(0.75), // White with 75% opacity for both light and dark
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32), // فقط پدینگ اضافی ۳۲ پیکسل چپ و راست
      child: Column(
        children: [
          // Centered title only
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              letterSpacing: -0.32, // -2% of 16
              color: TCnt.neutralMain(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Description
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                letterSpacing: -0.098, // -0.7% of 14
                color: TCnt.neutralTertiary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
