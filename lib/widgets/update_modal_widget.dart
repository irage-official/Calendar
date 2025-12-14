import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:typed_data';
import '../models/app_version.dart';
import '../config/theme_roles.dart';
import '../config/theme_colors.dart';
import '../config/app_icons.dart';
import '../utils/font_helper.dart';
import '../utils/svg_helper.dart';
import '../utils/logger.dart';

/// Full-screen update modal widget matching Figma design
class UpdateModalWidget extends StatelessWidget {
  final AppVersion version;
  final String currentVersion;
  final bool isPersian;
  final bool isCritical;

  const UpdateModalWidget({
    super.key,
    required this.version,
    required this.currentVersion,
    required this.isPersian,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    final releaseNotes = version.getReleaseNotes(isPersian ? 'fa' : 'en') ?? 
        (isPersian ? 'رفع باگ‌ها و بهبودها' : 'Bug fixes and improvements');
    
    // Parse release notes to extract bullet points
    final lines = releaseNotes.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    // Check if there are bullet points (lines starting with •, -, or *)
    final bulletPoints = lines.where((line) {
      final trimmed = line.trim();
      return trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*');
    }).toList();
    
    // If there are bullet points, don't show mainDescription in version text
    // Only show it if there are no bullet points (it's just a general description)
    final hasBulletPoints = bulletPoints.isNotEmpty;
    final mainDescription = hasBulletPoints ? '' : (lines.isNotEmpty ? lines[0] : releaseNotes);

    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: TBg.bottomSheet(context),
        ),
        child: Stack(
          children: [
          // Floating illustration image at top (behind content)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight / 2,
            child: IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  // Background Image - different for light/dark mode
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      final imagePath = isDark 
                          ? 'assets/images/adjective/update-dark.png'
                          : 'assets/images/adjective/update-iight.png';
                      
                      return Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          AppLogger.error('UpdateModal: Error loading $imagePath', error: error);
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image, size: 64, color: Colors.grey),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  // Gradient Overlay - reversed (from bottom to top)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: screenHeight / 2,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              TBg.bottomSheet(context),
                              TBg.bottomSheet(context).withOpacity(0.98),
                              TBg.bottomSheet(context).withOpacity(0.95),
                              TBg.bottomSheet(context).withOpacity(0.88),
                              TBg.bottomSheet(context).withOpacity(0.75),
                              TBg.bottomSheet(context).withOpacity(0.55),
                              TBg.bottomSheet(context).withOpacity(0.35),
                              TBg.bottomSheet(context).withOpacity(0.18),
                              TBg.bottomSheet(context).withOpacity(0.08),
                              TBg.bottomSheet(context).withOpacity(0),
                            ],
                            stops: const [
                              0.0,
                              0.12,
                              0.22,
                              0.35,
                              0.48,
                              0.62,
                              0.75,
                              0.87,
                              0.95,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating close button (X-circle) - 24px padding from top, right for English, left for Persian
          Positioned(
            top: 24,
            right: isPersian ? null : 24,
            left: isPersian ? 24 : null,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(2),
                child: SvgIconWidget(
                  assetPath: AppIcons.xCircle,
                  size: 32,
                  color: TCnt.neutralSecond(context),
                ),
              ),
            ),
          ),
          
          // Background container (content on top)
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Logo section - same size as splash screen
            SvgPicture.asset(
              AppIcons.logoLauncher,
              width: 60,
              height: 60,
            ),
            
            const SizedBox(height: 32),
            
            // Content section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  isPersian ? 'نسخه جدید برای به‌روزرسانی\nدر دسترس است' : 'Update new version\nis available',
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: TCnt.neutralMain(context),
                          height: 1.2,
                          letterSpacing: -0.6, // -2% of 30
                        )
                      : FontHelper.getInter(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: TCnt.neutralMain(context),
                          height: 1.2,
                          letterSpacing: -0.6, // -2% of 30
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Version info and description
                RichText(
                  text: TextSpan(
                    style: isPersian
                        ? FontHelper.getYekanBakh(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: TCnt.neutralSecond(context),
                            height: 1.6,
                            letterSpacing: -0.098, // -0.7% of 14
                          )
                        : FontHelper.getInter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: TCnt.neutralSecond(context),
                            height: 1.6,
                            letterSpacing: -0.098, // -0.7% of 14
                          ),
                    children: [
                      TextSpan(
                        text: isPersian 
                            ? 'در حال حاضر شما از نسخه $currentVersion استفاده میکنید. اکنون نسخه جدید ${version.version} برای آپدیت در دسترس است.'
                            : 'A new Version ${version.version} is now available. You currently have version $currentVersion.',
                      ),
                      if (mainDescription.isNotEmpty) ...[
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: mainDescription,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Bullet points section (What's new)
                if (hasBulletPoints) ...[
                  const SizedBox(height: 16),
                  Text(
                    isPersian ? 'چه چیزهای جدیدی اضافه شده:' : "What's new:",
                    style: isPersian
                        ? FontHelper.getYekanBakh(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TCnt.neutralMain(context),
                            height: 1.6,
                            letterSpacing: -0.098,
                          )
                        : FontHelper.getInter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TCnt.neutralMain(context),
                            height: 1.6,
                            letterSpacing: -0.098,
                          ),
                  ),
                  const SizedBox(height: 8),
                  ...bulletPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: isPersian
                              ? FontHelper.getYekanBakh(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: TCnt.neutralSecond(context),
                                  height: 1.6,
                                  letterSpacing: -0.098,
                                )
                              : FontHelper.getInter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: TCnt.neutralSecond(context),
                                  height: 1.6,
                                  letterSpacing: -0.098,
                                ),
                        ),
                        Expanded(
                          child: Text(
                            point.replaceFirst(RegExp(r'^[•\-\*]\s*'), ''),
                            style: isPersian
                                ? FontHelper.getYekanBakh(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: TCnt.neutralSecond(context),
                                    height: 1.6,
                                    letterSpacing: -0.098,
                                  )
                                : FontHelper.getInter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: TCnt.neutralSecond(context),
                                    height: 1.6,
                                    letterSpacing: -0.098,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                const SizedBox(height: 16),
                
                // Question
                Text(
                  isPersian ? 'آیا می‌خواهید اکنون به‌روزرسانی کنید؟' : 'Would you like to update it now?',
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: TCnt.neutralSecond(context),
                          height: 1.6,
                          letterSpacing: -0.098,
                        )
                      : FontHelper.getInter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: TCnt.neutralSecond(context),
                          height: 1.6,
                          letterSpacing: -0.098,
                        ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons section - vertical layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  // Primary button (Update Now)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Always use GitHub Releases URL for direct APK download
                        // Ignore downloadUrl from version.json if it points to Play Store
                        String downloadUrl = 'https://github.com/irage-official/Calendar/releases/latest';
                        
                        // Only use custom URL if it's a GitHub releases URL
                        if (version.downloadUrl != null && 
                            version.downloadUrl!.isNotEmpty &&
                            version.downloadUrl!.contains('github.com') &&
                            version.downloadUrl!.contains('releases')) {
                          downloadUrl = version.downloadUrl!;
                        }
                        
                        final uri = Uri.parse(downloadUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          AppLogger.error('UpdateModal: Cannot launch URL: $downloadUrl');
                        }
                        if (!isCritical) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TBg.brandMain(context),
                        foregroundColor: TCnt.unsurface(context),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(54 / 2),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isPersian ? 'الان بروزرسانی میکنم' : 'Update Now',
                        style: isPersian
                            ? FontHelper.getYekanBakh(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: TCnt.unsurface(context),
                                height: 1.4,
                                letterSpacing: -0.112, // -0.7% of 16
                              )
                            : FontHelper.getInter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: TCnt.unsurface(context),
                                height: 1.4,
                                letterSpacing: -0.112, // -0.7% of 16
                              ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Regular button (Maybe Later)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(54 / 2),
                        ),
                      ),
                      child: Text(
                        isPersian ? 'بعدا انجام میدم' : 'Maybe Later',
                        style: isPersian
                            ? FontHelper.getYekanBakh(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: TCnt.neutralTertiary(context),
                                height: 1.4,
                                letterSpacing: -0.098, // -0.7% of 14
                              )
                            : FontHelper.getInter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: TCnt.neutralTertiary(context),
                                height: 1.4,
                                letterSpacing: -0.098, // -0.7% of 14
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
        ),
      ),
    );
  }
}

