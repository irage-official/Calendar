import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../config/constants.dart';
import '../config/app_icons.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../providers/app_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/header_page_widget.dart';
import '../widgets/setting_item_widget.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../widgets/content_bottom_sheet.dart';
import '../widgets/alert_message_widget.dart';
import '../widgets/custom_radio_button.dart';
import '../utils/svg_helper.dart';
import '../utils/extensions.dart';
import '../services/date_converter_service.dart';
import '../services/update_service.dart';
import '../services/event_service.dart';
import '../models/app_version.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isPersian = appProvider.language == 'fa';
        
        return Scaffold(
          backgroundColor: TBg.main(context),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                HeaderPageWidget(
                  title: isPersian ? 'تنظیمات' : 'Settings',
                ),
              Expanded(
                child: ListView(
                  children: [
                    // App Settings Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildAppSettingsSection(context, isPersian),
                    ),
                    
                    // More Settings Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildMoreSettingsSection(context, isPersian),
                    ),
                  ],
                ),
              ),
              
              // Version at bottom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  'v 0.9',
            style: AppTextStyles.bodySmall.copyWith(
                    color: TCnt.neutralWeak(context),
                  ),
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppSettingsSection(BuildContext context, bool isPersian) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Column(
          children: [
            SettingItem(
              icon: AppIcons.globe,
              title: isPersian ? 'تغییر زبان' : 'Change Language',
              subtitle: _getCurrentLanguageText(appProvider.language, isPersian),
              onTap: () => _showLanguageBottomSheet(context, isPersian),
              margin: EdgeInsets.zero,
            ),
            SettingItem(
              icon: AppIcons.calendar,
              title: isPersian ? 'سیستم تقویم' : 'Calendar System',
              subtitle: _getCurrentCalendarSystemText(appProvider.calendarSystem, isPersian),
              onTap: () => _showCalendarSystemBottomSheet(context, isPersian),
              margin: EdgeInsets.zero,
            ),
            Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                return SettingItem(
                  icon: AppIcons.palette,
                  title: isPersian ? 'ظاهر تم نمایش' : 'Appearance',
                  subtitle: _getCurrentAppearanceTextStatic(appProvider, isPersian),
                  onTap: () => _showAppearanceBottomSheet(context, isPersian),
                  margin: EdgeInsets.zero,
                );
              },
            ),
            SettingItem(
              icon: AppIcons.heartFun,
              title: isPersian ? 'حمایت مالی' : 'Donation',
              onTap: () => _showDonationDialog(context, isPersian),
              showArrow: false,
              margin: EdgeInsets.zero,
            ),
            SettingItem(
              icon: AppIcons.book,
              title: isPersian ? 'منابع' : 'Resources',
              onTap: () => _showResourcesDialog(context, isPersian),
              showArrow: false,
              margin: EdgeInsets.zero,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoreSettingsSection(BuildContext context, bool isPersian) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
          child: Text(
            isPersian ? 'تنظیمات بیشتر' : 'More Settings',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              height: 1.4,
              letterSpacing: -0.007,
              fontWeight: FontWeight.w600,
              color: TCnt.neutralMain(context).withOpacity(0.4),
            ),
          ),
        ),
        SettingItem(
          icon: AppIcons.infoCircle,
          title: isPersian ? 'درباره ما' : 'About Us',
          onTap: () => _showAboutDialog(context, isPersian),
          showArrow: false,
          margin: EdgeInsets.zero,
        ),
        SettingItem(
          icon: AppIcons.lock,
          title: isPersian ? 'سیاست حریم خصوصی' : 'Privacy Policy',
          onTap: () => _showPrivacyPolicyDialog(context, isPersian),
          showArrow: false,
          margin: EdgeInsets.zero,
        ),
        SettingItem(
          icon: AppIcons.document,
          title: isPersian ? 'شرایط استفاده' : 'Terms and Conditions',
          onTap: () => _showTermsOfServiceDialog(context, isPersian),
          showArrow: false,
          margin: EdgeInsets.zero,
        ),
        // SettingItem(
        //   icon: AppIcons.feedback,
        //   title: isPersian ? 'بازخورد' : 'Feedback',
        //   onTap: () => _showFeedbackDialog(context, isPersian),
        //   showArrow: false,
        //   margin: EdgeInsets.zero,
        // ),
        SettingItem(
          icon: AppIcons.download,
          title: isPersian ? 'بررسی آپدیت' : 'Check for Updates',
          onTap: () => _checkForUpdates(context, isPersian),
          showArrow: false,
          margin: EdgeInsets.zero,
        ),
        SettingItem(
          icon: AppIcons.share,
          title: isPersian ? 'اشتراک با دوستان' : 'Share with your Friends',
          onTap: () => _shareApp(context, isPersian),
          showArrow: false,
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }


  String _getCurrentLanguageText(String language, bool isPersian) {
    switch (language) {
      case 'system':
        return isPersian ? 'سیستم (خودکار)' : 'System (Auto)';
      case 'fa':
        return 'فارسی';
      case 'en':
        return 'English';
      default:
        return isPersian ? 'سیستم (خودکار)' : 'System (Auto)';
    }
  }

  String _getCurrentCalendarSystemText(String calendarSystem, bool isPersian) {
    if (calendarSystem == 'solar') {
      return isPersian ? 'شمسی' : 'Solar Hijri';
    } else if (calendarSystem == 'shahanshahi') {
      return isPersian ? 'شاهنشاهی' : 'Shahanshahi';
    } else {
      return isPersian ? 'میلادی' : 'Gregorian';
    }
  }

  String _getCurrentAppearanceTextStatic(AppProvider appProvider, bool isPersian) {
    final mode = appProvider.themeModeString;
    if (mode == 'system') {
      return isPersian ? 'سیستم (خودکار)' : 'System (Auto)';
    } else if (mode == 'dark') {
      return isPersian ? 'تاریک' : 'Dark';
    } else if (mode == 'light') {
      return isPersian ? 'روشن' : 'Light';
    }
    // Fallback for backward compatibility
    return appProvider.isDarkMode 
        ? (isPersian ? 'تاریک' : 'Dark')
        : (isPersian ? 'روشن' : 'Light');
  }

  Color _getDescriptionColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? TCnt.neutralSecond(context).withOpacity(0.9)
        : TCnt.neutralSecond(context);
  }

  String _formatLastUpdatedDate(AppProvider appProvider, bool isPersian) {
    final dateConverter = DateConverterService();
    // Original date: 17 October, 2025 (Gregorian) = 25 مهر 1404 (Solar)
    final gregorianDate = DateTime(2025, 10, 17);
    final calendarSystem = appProvider.calendarSystem;
    
    if (calendarSystem == 'solar') {
      final jalali = dateConverter.gregorianToJalali(gregorianDate);
      if (isPersian) {
        final monthName = dateConverter.getJalaliMonthNameFa(jalali.month);
        return 'آخرین به‌روزرسانی ${jalali.day} ${monthName} ${jalali.year}';
      } else {
        final monthName = dateConverter.getJalaliMonthNameEn(jalali.month);
        return 'Last Updated ${jalali.day}\u2009${monthName}, ${jalali.year}';
      }
    } else if (calendarSystem == 'shahanshahi') {
      final jalali = dateConverter.gregorianToJalali(gregorianDate);
      final shahanshahi = dateConverter.jalaliToShahanshahi(jalali);
      if (isPersian) {
        final monthName = dateConverter.getJalaliMonthNameFa(shahanshahi.month);
        return 'آخرین به‌روزرسانی ${shahanshahi.day} ${monthName} ${shahanshahi.year}';
      } else {
        final monthName = dateConverter.getJalaliMonthNameEn(shahanshahi.month);
        return 'Last Updated ${shahanshahi.day}\u2009${monthName}, ${shahanshahi.year}';
      }
    } else {
      // Gregorian
      if (isPersian) {
        final monthName = dateConverter.getGregorianMonthNameFa(gregorianDate.month);
        return 'آخرین به‌روزرسانی ${gregorianDate.day} ${monthName} ${gregorianDate.year}';
      } else {
        final monthName = dateConverter.getGregorianMonthName(gregorianDate.month);
        return 'Last Updated ${monthName} ${gregorianDate.day}, ${gregorianDate.year}';
      }
    }
  }

  void _showLanguageBottomSheet(BuildContext context, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // 30% opacity black backdrop
      isScrollControlled: true,
      builder: (context) => Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SettingsBottomSheet(
            title: isPersian ? 'تغییر زبان' : 'Change Language',
            description: isPersian 
                ? 'زبان رابط کاربری برنامه، منوها، دکمه‌ها و غیره را انتخاب کنید.'
                : 'Choose the language of the app interface, including menus, buttons, and etc.',
            content: Column(
              children: [
                // System (Auto) option
                CustomRadioButton(
                  label: isPersian ? 'سیستم (خودکار)' : 'System (Auto)',
                  isSelected: appProvider.language == 'system',
                  onTap: () {
                    appProvider.setLanguage('system');
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                // Manual setting label
                CustomRadioButton(
                  label: isPersian ? 'انتخاب دستی' : 'Choose manual setting',
                  isManualLabel: true,
                ),
                const SizedBox(height: 8),
                // English option
                CustomRadioButton(
                  label: isPersian ? 'انگلیسی (EN)' : 'English (EN)',
                  isSelected: appProvider.language == 'en',
                  onTap: () {
                    appProvider.setLanguage('en');
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                // Persian option
                CustomRadioButton(
                  label: 'فارسی (Persian)',
                  isSelected: appProvider.language == 'fa',
                  onTap: () {
                    appProvider.setLanguage('fa');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _showCalendarSystemBottomSheet(BuildContext context, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // 30% opacity black backdrop
      isScrollControlled: true,
      builder: (context) => Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SettingsBottomSheet(
            title: isPersian ? 'تغییر تقویم' : 'Change Calendar',
            description: isPersian ? 'سیستم تقویم تاریخ را انتخاب کنید.' : 'Choose the calendar system of date.',
            content: Column(
              children: [
                // Gregorian option
                CustomRadioButton(
                  label: isPersian ? 'میلادی (Gregorian)' : 'Gregorian',
                  isSelected: appProvider.calendarSystem == 'gregorian',
                  onTap: () {
                    appProvider.setCalendarSystem('gregorian');
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                // Shahanshahi option
                CustomRadioButton(
                  label: isPersian ? 'شاهنشاهی (Shahanshahi)' : 'Shahanshahi (شاهنشاهی)',
                  isSelected: appProvider.calendarSystem == 'shahanshahi',
                  onTap: () {
                    appProvider.setCalendarSystem('shahanshahi');
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                // Solar Hijri option
                CustomRadioButton(
                  label: isPersian ? 'شمسی (Solar Hijri)' : 'Solar Hijri (شمسی)',
                  isSelected: appProvider.calendarSystem == 'solar',
                  onTap: () {
                    appProvider.setCalendarSystem('solar');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _showAppearanceBottomSheet(BuildContext context, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // 30% opacity black backdrop
      isScrollControlled: true,
      builder: (context) => Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SettingsBottomSheet(
            title: isPersian ? 'تم ظاهری' : 'Appearance',
            description: isPersian ? 'حالت ظاهری برنامه را انتخاب کنید.' : 'Choose the appearance mode of the app.',
            content: Column(
              children: [
                // System (Auto) option
                Consumer<AppProvider>(
                  builder: (context, app, _) => CustomRadioButton(
                    label: isPersian ? 'سیستم (خودکار)' : 'System (Auto)',
                    isSelected: app.themeModeString == 'system',
                    onTap: () async {
                      await context.read<AppProvider>().setThemeModeToSystem();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Manual setting label
                CustomRadioButton(
                  label: isPersian ? 'انتخاب دستی' : 'Choose manual setting',
                  isManualLabel: true,
                ),
                const SizedBox(height: 8),
                // Light option
                Consumer<AppProvider>(
                  builder: (context, app, _) => CustomRadioButton(
                    label: isPersian ? 'روشن' : 'Light',
                    isSelected: app.themeModeString == 'light' || (app.themeModeString == null && !app.isDarkMode),
                    onTap: () async {
                      await context.read<AppProvider>().setThemeMode(false);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Dark option
                Consumer<AppProvider>(
                  builder: (context, app, _) => CustomRadioButton(
                    label: isPersian ? 'تاریک' : 'Dark',
                    isSelected: app.themeModeString == 'dark' || (app.themeModeString == null && app.isDarkMode),
                    onTap: () async {
                      await context.read<AppProvider>().setThemeMode(true);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _showDonationDialog(BuildContext context, bool isPersian) {
    const String walletAddress = 'TNdXt3TSZnhuyGraxFhdSrUsNPtyXS4MZp';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // 30% opacity black backdrop
      isScrollControlled: true,
      builder: (context) => ContentBottomSheet(
        title: isPersian ? 'حمایت از حافظه' : 'Support the Memory',
        titleIconEmoji: '☕',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description at the top of content (scrolls with content)
            Text(
              isPersian
                  ? 'این پروژه بر پایه تعهد رشد می‌کند، نه سود — ساخته شده توسط کسانی که حقیقت را بر سکوت ترجیح می‌دهند. حمایت شما این آرشیو را مستقل و زنده نگه می‌دارد.'
                  : 'This project thrives on dedication, not profit — crafted by those who value truth over silence. Your support keeps this archive independent and vibrant.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                letterSpacing: -0.098,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 24),
            // Wallet Info Container
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Crypto Kind Section
                  _buildCryptoKindSection(context, isPersian),
                  
                  const SizedBox(height: 12),
                  
                  // QR Code
                  _buildQRCodeSection(context),
                  
                  const SizedBox(height: 12),
                  
                  // Wallet Address
                  _buildWalletAddress(walletAddress),
                  
                  const SizedBox(height: 12),
                  
                  // Action Buttons
                  _buildActionButtons(context, walletAddress, isPersian),
                ],
              ),
            ),
            
            // Anonymous Donations Section
            AlertMessageWidget(
              type: AlertType.warning,
              title: isPersian ? 'اهدای ناشناس' : 'Anonymous Donations',
              child: isPersian
                  ? Text.rich(
                      TextSpan(
              style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          letterSpacing: -0.098,
                color: LightCnt.neutralSecond,
                          fontWeight: FontWeight.w400,
                        ),
                        children: const [
                          TextSpan(text: 'برای محافظت از حریم خصوصی شما، کمک‌های مالی را به کیف پول تتر ('),
                          TextSpan(text: 'USDT', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ') ما در شبکه '),
                          TextSpan(text: 'TRON', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' ('),
                          TextSpan(text: 'TRC20', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ') ارسال کنید. هیچ داده شخصی جمع‌آوری نخواهد شد.'),
                        ],
                      ),
                    )
                  : Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          letterSpacing: -0.098,
                          color: _getDescriptionColor(context),
                          fontWeight: FontWeight.w400,
                        ),
                        children: const [
                          TextSpan(text: 'To protect your privacy, send contributions to our Tether ('),
                          TextSpan(text: 'USDT', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ') wallet on '),
                          TextSpan(text: 'TRON', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' ('),
                          TextSpan(text: 'TRC20', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '). No personal data will be collected.'),
                        ],
                      ),
                    ),
              isPersian: isPersian,
            ),
          ],
        ),
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildCryptoKindSection(BuildContext context, bool isPersian) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgIconWidget(
          assetPath: AppIcons.tether,
          size: 24,
          color: const Color(0xFF27A17C),
        ),
        const SizedBox(width: 4),
        Text(
          'USDT',
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            letterSpacing: -0.32,
            color: TCnt.neutralMain(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? ThemeColors.gray100.withOpacity(0.1)
                : ThemeColors.gray900.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Tron',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              letterSpacing: -0.084,
              color: TCnt.neutralTertiary(context),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeSection(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: TBg.card1(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TBr.neutralTertiary(context), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/adjective/qr-code.jpeg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildWalletAddress(String address) {
    return Center(
      child: Text(
        address,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          letterSpacing: 0.14,
          color: ThemeColors.gray600,
          fontFamily: 'monospace',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String walletAddress, bool isPersian) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            onTap: () => _copyToClipboard(context, walletAddress, isPersian),
            iconPath: AppIcons.copy,
            label: isPersian ? 'کپی' : 'Copy',
            context: context,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            onTap: () => _downloadQRCode(context, walletAddress, isPersian),
            iconPath: AppIcons.download,
            label: isPersian ? 'دانلود' : 'Download',
            context: context,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            onTap: () => _shareAddress(context, walletAddress, isPersian),
            iconPath: AppIcons.share,
            label: isPersian ? 'اشتراک' : 'Share',
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onTap,
    required String iconPath,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ThemeColors.gray100.withOpacity(0.1)
              : ThemeColors.gray900.withOpacity(0.06),
          shape: BoxShape.circle,
        ),
        child: SvgIconWidget(
          assetPath: iconPath,
          size: 20,
          color: TCnt.neutralTertiary(context),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ThemeColors.gray100.withOpacity(0.1)
              : ThemeColors.gray900.withOpacity(0.06),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgIconWidget(
            assetPath: iconPath,
            size: 20,
            color: TCnt.neutralSecond(context),
          ),
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context, String text, bool isPersian) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      context.showToast(isPersian ? 'آدرس ولت کپی شد' : 'Wallet address copied');
    }
  }

  Future<File?> _getQRCodeFile(String walletAddress) async {
    try {
      // Load image from assets
      final ByteData data = await rootBundle.load('assets/images/adjective/qr-code.jpeg');
      final Uint8List bytes = data.buffer.asUint8List();
      
      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = walletAddress.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final File file = File('${tempDir.path}/$fileName.jpg');
      
      // Write image to file
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  Future<void> _downloadQRCode(BuildContext context, String walletAddress, bool isPersian) async {
    try {
      // Load image directly from assets
      final ByteData data = await rootBundle.load('assets/images/adjective/qr-code.jpeg');
      final Uint8List imageBytes = data.buffer.asUint8List();
      
      // Get application documents directory (accessible to user)
      final Directory? appDocDir = await getExternalStorageDirectory();
      if (appDocDir == null) {
        if (context.mounted) {
          context.showToast(isPersian ? 'خطا در دسترسی به حافظه' : 'Error accessing storage');
        }
        return;
      }
      
      // Create Downloads or Pictures folder path
      final String fileName = walletAddress.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final Directory downloadDir = Directory('${appDocDir.path}/../Pictures/Irage');
      
      // Create directory if it doesn't exist
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      
      final File file = File('${downloadDir.path}/$fileName.jpg');
      
      // Write image to file
      await file.writeAsBytes(imageBytes);
      
      if (context.mounted) {
        context.showToast(isPersian ? 'تصویر در پوشه Pictures ذخیره شد' : 'Image saved to Pictures folder');
      }
    } catch (e) {
      if (context.mounted) {
        context.showToast(isPersian ? 'خطا در دانلود تصویر' : 'Error downloading image');
      }
    }
  }

  Future<void> _shareAddress(BuildContext context, String address, bool isPersian) async {
    try {
      final File? qrFile = await _getQRCodeFile(address);
      if (qrFile == null || !await qrFile.exists()) {
        // Fallback to text sharing if image fails
        await Share.share(
          address,
          subject: isPersian ? 'آدرس کیف پول' : 'Wallet Address',
        );
        return;
      }

      // Share image with caption
      final XFile xFile = XFile(qrFile.path);
      await Share.shareXFiles(
        [xFile],
        text: address,
        subject: isPersian ? 'آدرس کیف پول' : 'Wallet Address',
      );
    } catch (e) {
      if (context.mounted) {
        context.showToast(isPersian ? 'خطا در اشتراک‌گذاری' : 'Error sharing');
      }
    }
  }

  void _showResourcesDialog(BuildContext context, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // 30% opacity black backdrop
      isScrollControlled: true,
      builder: (context) => ContentBottomSheet(
        title: isPersian ? 'منابع و مراجع' : 'Resources & References',
        titleIconEmoji: '📚',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description at the top of content (scrolls with content)
            Text(
              isPersian 
                  ? 'این پروژه بر اساس داده‌های تأیید شده از سازمان‌های مستقل حقوق بشر و آرشیوهای مستندسازی جنایات رژیم جمهوری اسلامی ساخته شده است.'
                  : 'This project was built on verified data from independent human rights organizations and archives documenting the crimes of the Islamic Republic regime.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                letterSpacing: -0.098,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPersian 
                  ? 'در زیر منابع کلیدی که در حفظ حقیقت و حافظه مشارکت داشته‌اند را خواهید یافت:'
                  : 'Below you\'ll find key sources that have contributed to preserving truth and memory.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                letterSpacing: -0.098, // -0.7% of 14
                color: _getDescriptionColor(context),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            _buildResourceItem(context,
              iconPath: AppIcons.ihrdc,
              title: isPersian ? 'مرکز مستندسازی حقوق بشر ایران (IHRDC)' : 'Iran Human Rights Documentation Center (IHRDC)',
              description: isPersian 
                  ? 'یک سازمان مستقل که شواهد جنایات و نقض حقوق بشر توسط رژیم جمهوری اسلامی را حفظ می‌کند.'
                  : 'An independent organization preserving evidence of crimes and human rights violations committed by the Islamic Republic regime.',
              onTap: () => _openResourceUrl('https://www.iranhrdc.org'),
            ),
            const SizedBox(height: 16),
            _buildResourceItem(context,
              iconPath: AppIcons.iranrights,
              title: isPersian ? 'بنیاد عبدالرحمن برومند' : 'Abdorrahman Boroumand Foundation',
              description: isPersian 
                  ? 'مرکز یادبود و اسناد اختصاص داده شده به قربانیان اعدام‌های سیاسی و نقض حقوق بشر در ایران.'
                  : 'A memorial and documentation center dedicated to victims of political executions and human rights abuses in Iran.',
              onTap: () => _openResourceUrl('https://www.iranrights.org'),
            ),
            const SizedBox(height: 16),
            _buildResourceItem(context,
              iconPath: AppIcons.justiceForIran,
              title: isPersian ? 'عدالت برای ایران' : 'Justice for Iran',
              description: isPersian 
                  ? 'یک گروه غیرانتفاعی که برای افشای خشونت دولتی و آزار و اذیت جنسیتی تحت رژیم جمهوری اسلامی فعالیت می‌کند.'
                  : 'A non-profit group working to expose state violence and gender-based persecution under the Islamic Republic regime.',
              onTap: () => _openResourceUrl('https://justice4iran.org'),
            ),
            const SizedBox(height: 16),
            _buildResourceItem(context,
              iconPath: AppIcons.hrana,
              title: isPersian ? 'خبرگزاری حقوق بشر ایران (HRANA)' : 'Human Rights Activists News Agency (HRANA)',
              description: isPersian 
                  ? 'شبکه رسانه‌ای مستقل که از سال ۲۰۰۶ نقض حقوق بشر در ایران را گزارش می‌دهد.'
                  : 'An independent media network reporting human rights violations across Iran since 2006.',
              onTap: () => _openResourceUrl('https://www.hra-news.org'),
            ),
            const SizedBox(height: 16),
            _buildResourceItem(context,
              iconPath: AppIcons.unitedForIran,
              title: isPersian ? 'متحد برای ایران' : 'United for Iran',
              description: isPersian 
                  ? 'یک ابتکار جامعه مدنی جهانی که ایرانیان را از طریق حقوق دیجیتال و حمایت از حقوق بشر توانمند می‌سازد.'
                  : 'A global civil society initiative empowering Iranians through digital rights and human rights advocacy.',
              onTap: () => _openResourceUrl('https://united4iran.org'),
            ),
            const SizedBox(height: 16),
            _buildResourceItem(context,
              iconPath: AppIcons.amnestyInternational,
              title: isPersian ? 'عفو بین‌الملل - گزارش‌های ایران' : 'Amnesty International - Iran Reports',
              description: isPersian 
                  ? 'گزارش‌ها و تحقیقات تأیید شده در مورد جنایات، اعدام‌ها و نقض حقوق بشر توسط رژیم جمهوری اسلامی.'
                  : 'Verified reports and investigations on crimes, executions, and human rights violations by the Islamic Republic regime.',
              onTap: () => _openResourceUrl('https://www.amnesty.org/en/location/middle-east-and-north-africa/iran/'),
            ),
          ],
        ),
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // 30% opacity black backdrop
      isScrollControlled: true,
      builder: (context) => ContentBottomSheet(
        title: isPersian ? 'درباره ما' : 'About Us',
        titleIconEmoji: '🕊️',
          content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            _buildRichTextWithIrage(
              context,
              isPersian 
                  ? 'ایراژ (میراث ایران) یک برنامه تقویم مستقل و ساخته شده توسط جامعه است که توسط افرادی که به ایران - ایران واقعی - اعتقاد دارند، ایجاد شده است.'
                  : 'The Irage (Iranian Heritage) is a community-built, independent calendar app created by people who believe in Iran — the real Iran.',
            ),
            const SizedBox(height: 16),
            Text(
              isPersian 
                  ? 'نه نسخه‌ای که توسط رژیم جمهوری اسلامی بازنویسی شده است، بلکه ایرانِ غرور، فرهنگ، هویت و آزادی باستانی.'
                  : 'Not the version rewritten by the Islamic Republic regime, but the Iran of ancient pride, culture, identity, and freedom.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 24),
            // Independence statement
            Text(
              isPersian 
                  ? 'ما اولین برنامه تقویم ملی‌گرای ایرانی هستیم و هیچ ارتباطی با جمهوری اسلامی ندارد.'
                  : 'We are the first Iranian nationalist calendar app with zero connection to the Islamic Republic.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 12),
            // Bullet points
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPersian ? '• بدون حمایت مالی' : '• No sponsorship',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _getDescriptionColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPersian ? '• بدون روابط سیاسی' : '• No political ties',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _getDescriptionColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPersian ? '• بدون تبلیغات' : '• No propaganda',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _getDescriptionColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPersian 
                  ? 'فقط عشق خالص به میهن و تعهد به بیان حقیقت.'
                  : 'Just pure love for our homeland and a commitment to tell the truth.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 24),
            // Two stories introduction
            Text(
              isPersian 
                  ? 'این پروژه دو داستان قدرتمند را گرد هم می‌آورد:'
                  : 'This project brings together two powerful stories:',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 16),
            // Our Heritage section
            Text(
              isPersian ? '⭐ ۱. میراث ما' : '⭐ 1. Our Heritage',
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.32,
                color: TCnt.neutralMain(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPersian 
                  ? 'جشن‌ها، سنت‌ها، اسطوره‌ها، قهرمانان و فرهنگ باستانی که مدت‌ها قبل از وجود رژیم، هویت واقعی ما را به عنوان یک ملت شکل داده‌اند.'
                  : 'The festivals, traditions, myths, heroes, and ancient culture that shaped who we truly are as a nation long before the regime existed.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                letterSpacing: -0.098,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 16),
            // Our Reality section
            Text(
              isPersian ? '🔥 ۲. واقعیت ما' : '🔥 2. Our Reality',
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.32,
                color: TCnt.neutralMain(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPersian 
                  ? 'یک سابقه روشن و بدون سانسور از جنایاتی که رژیم جمهوری اسلامی علیه مردم ایران مرتکب شده است - بنابراین هیچ زندگی، هیچ نامی و هیچ بی‌عدالتی هرگز فراموش نمی‌شود.'
                  : 'A clear, uncensored record of the crimes committed by the Islamic Republic regime against the people of Iran — so no life, no name, and no injustice is ever forgotten.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                letterSpacing: -0.098,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 16),
            // Together statement
            Text(
              isPersian 
                  ? 'آنها با هم چیزی اساسی را به ما یادآوری می‌کنند:'
                  : 'Together, they remind us of something essential:',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPersian 
                  ? 'ما قبل از این رژیم هویتی داشتیم. و مدت‌ها پس از آن نیز هویتی خواهیم داشت.'
                  : 'We had an identity before this regime. And we will have one long after it.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 24),
            // Anonymous builders statement
            Text(
              isPersian 
                  ? 'این برنامه به صورت ناشناس، توسط ایرانیانی ساخته شده است که حقیقت را به ترس ترجیح دادند - افرادی که می‌خواهند هر کاربر افتخار ایرانی بودن و مسئولیت یادآوری کسانی را که جنگیدند، رنج کشیدند یا ساکت شدند، احساس کند.'
                  : 'This app is built anonymously, by Iranians who chose truth over fear — people who want every user to feel the pride of being Iranian and the responsibility of remembering those who fought, suffered, or were silenced.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 16),
            // Note callout section
            _buildNoteCallout(
              context,
              isPersian 
                  ? 'اگر اینجا هستید، شما هم بخشی از این ماموریت هستید.'
                  : 'If you\'re here, you\'re part of that mission too.',
              null,
            ),
            const SizedBox(height: 24),
            // "This isn't just a calendar" section
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPersian ? '• این فقط یک تقویم نیست.' : '• This isn\'t just a calendar.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _getDescriptionColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPersian ? '• این یک عمل آرام مقاومت است.' : '• It\'s a quiet act of resistance.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _getDescriptionColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPersian ? '• ادای احترام به میراث ما.' : '• A tribute to our heritage.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _getDescriptionColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPersian ? '• یادآوری قدرت جمعی ما.' : '• A reminder of our collective strength.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _getDescriptionColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPersian ? '• و گامی کوچک به سوی ایرانی که شایسته آن هستیم.' : '• And a small step toward the Iran we deserve.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _getDescriptionColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Contact Us Section
            Text(
              isPersian ? 'تماس با ما' : 'Contact us',
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.32,
                color: TCnt.neutralMain(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                style: TextStyle(
                fontSize: 14,
                  height: 1.6,
                  letterSpacing: -0.098,
                  color: _getDescriptionColor(context),
                ),
                children: [
                  TextSpan(
                    text: isPersian 
                        ? 'اگر مایل به ارتباط با ما هستید، می‌توانید به آدرس '
                        : 'If you\'d like to reach out to us, you can send an email to ',
                  ),
                  TextSpan(
                    text: 'info@irage.site',
                    style: TextStyle(
                      color: TCnt.brandMain(context),
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        const emailText = 'info@irage.site';
                        final Uri emailUri = Uri.parse('mailto:$emailText');
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                  ),
                  TextSpan(
                    text: isPersian 
                        ? ' ایمیل ارسال کنید. همچنین، در صورت داشتن هرگونه گزارش یا بازخورد، می‌توانید از طریق ایمیل '
                        : '. Alternatively, if you have any reports or feedback, you can contact us via ',
                  ),
                  TextSpan(
                    text: 'feedback@irage.site',
                    style: TextStyle(
                      color: TCnt.brandMain(context),
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        const emailText = 'feedback@irage.site';
                        final Uri emailUri = Uri.parse('mailto:$emailText');
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                  ),
                  TextSpan(
                    text: isPersian 
                        ? ' با ما تماس بگیرید.'
                        : '.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Developer Section
            Text(
              isPersian 
                  ? 'توسعه‌دهنده: تیم توسعه ایراژ'
                  : 'Developer: Irage Development Team',
              style: TextStyle(
                fontSize: 14,
                color: _getDescriptionColor(context),
              ),
            ),
            const SizedBox(height: 24),
            // Follow Us On Section
            Text(
              isPersian ? 'ما را دنبال کنید' : 'Follow us on',
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.32,
                color: TCnt.neutralMain(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSocialButton(
                  context: context,
                  iconPath: AppIcons.xSocial,
                  onTap: () async {
                    // Try to open in X app first, fallback to browser
                    final Uri appUri = Uri.parse('twitter://user?screen_name=irage_official');
                    final Uri webUri = Uri.parse('https://x.com/irage_official');
                    
                    try {
                      // Try app first
                      if (await canLaunchUrl(appUri)) {
                        await launchUrl(appUri, mode: LaunchMode.externalApplication);
                      } else if (await canLaunchUrl(webUri)) {
                        // Fallback to web - platform will open in app if available
                        await launchUrl(webUri, mode: LaunchMode.platformDefault);
                      }
                    } catch (e) {
                      // If app launch fails, try web
                      if (await canLaunchUrl(webUri)) {
                        await launchUrl(webUri, mode: LaunchMode.platformDefault);
                      }
                    }
                  },
                ),
                const SizedBox(width: 10),
                _buildSocialButton(
                  context: context,
                  iconPath: AppIcons.instagram,
                  onTap: () async {
                    // Try to open in Instagram app first, fallback to browser
                    final Uri appUri = Uri.parse('instagram://user?username=irage.site');
                    final Uri webUri = Uri.parse('https://instagram.com/irage.site');
                    
                    try {
                      // Try app first
                      if (await canLaunchUrl(appUri)) {
                        await launchUrl(appUri, mode: LaunchMode.externalApplication);
                      } else if (await canLaunchUrl(webUri)) {
                        // Fallback to web - platform will open in app if available
                        await launchUrl(webUri, mode: LaunchMode.platformDefault);
                      }
                    } catch (e) {
                      // If app launch fails, try web
                      if (await canLaunchUrl(webUri)) {
                        await launchUrl(webUri, mode: LaunchMode.platformDefault);
                      }
                    }
                  },
                ),
                const SizedBox(width: 10),
                _buildSocialButton(
                  context: context,
                  iconPath: AppIcons.github,
                  onTap: () async {
                    final Uri uri = Uri.parse('https://github.com/irage-official/iranian-heritage');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // 30% opacity black backdrop
      isScrollControlled: true,
      builder: (context) => Consumer<AppProvider>(
        builder: (context, appProvider, child) => ContentBottomSheet(
          title: isPersian ? 'سیاست حریم خصوصی' : 'Privacy Policy',
          titleIconEmoji: '🔒',
          description: _formatLastUpdatedDate(appProvider, isPersian),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Overview
            _buildTermsSection(context,
              number: '1',
              title: isPersian ? 'بررسی کلی' : 'Overview',
              content: isPersian 
                  ? 'حریم خصوصی و امنیت شما برای ما از اهمیت بالایی برخوردار است. این برنامه کاملاً به اصل عدم جمع‌آوری داده‌های شخصی، ردیابی اطلاعات یا هرگونه فعالیت قابل شناسایی کاربر پایبند است. این برنامه به گونه‌ای طراحی شده است که کاملاً آفلاین عمل کند، به جز برای ارائه به‌روزرسانی‌های رویدادها یا زمانی که تصمیم می‌گیرید اطلاعات را به صورت دستی به اشتراک بگذارید یا ارسال کنید.'
                  : 'Your privacy and security are of utmost importance to us. This app strictly adheres to the principle of not collecting personal data, tracking information, or any identifiable user activity. It is designed to function entirely offline, except for providing event updates or when you choose to manually share or send information.',
            ),
            
            // 2. Information Collection
            _buildTermsSectionWithBullets(context,
              number: '2',
              title: isPersian ? 'جمع‌آوری اطلاعات' : 'Information Collection',
              bullets: isPersian 
                  ? [
                      'این برنامه نیازی به حساب کاربری یا ورود به سیستم ندارد.',
                      'هیچ شناسه شخصی (ایمیل، نام، داده‌های دستگاه) جمع‌آوری نمی‌شود.',
                      'اگر تصمیم به ارسال محتوا دارید، فقط داده‌هایی که ارائه می‌دهید ذخیره می‌شوند و فقط برای تأیید رکورد.',
                    ]
                  : [
                      'This app does not require an account or login.',
                      'No personal identifiers (email, name, device data) are collected.',
                      'If you decide to submit content, only the data you provide will be stored and only for record verification.',
                    ],
            ),
            
            // 3. Data Storage and Protection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      child: Text(
                        '3.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          letterSpacing: -0.32,
                          color: TCnt.neutralMain(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isPersian ? 'ذخیره‌سازی و حفاظت از داده‌ها' : 'Data Storage and Protection',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          letterSpacing: -0.32,
                          color: TCnt.neutralMain(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPersian 
                            ? 'تمام رکوردهای جمع‌آوری‌شده به طور ایمن در سرورهای رمزگذاری‌شده ذخیره می‌شوند و دسترسی به آنها محدود به تیم تأیید است.'
                            : 'All collected records are securely stored on encrypted servers, and access is limited to the verification team.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          letterSpacing: -0.098,
                          color: _getDescriptionColor(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildNoteCallout(
                        context,
                        isPersian 
                            ? 'هیچ سرویس شخص ثالثی به اطلاعات شما دسترسی ندارد.'
                            : 'No third-party services have access to your information.',
                        null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            
            // 4. Analytics and Tracking
            _buildTermsSection(context,
              number: '4',
              title: isPersian ? 'تجزیه و تحلیل و ردیابی' : 'Analytics and Tracking',
              content: isPersian 
                  ? 'ما از ابزارهای تجزیه و تحلیل، تبلیغات، کوکی‌ها یا هیچ نرم‌افزار ردیابی استفاده نمی‌کنیم.'
                  : 'We don\'t use analytics tools, advertising, cookies, or any tracking software.',
            ),
            
            // 5. External Links
            _buildTermsSection(context,
              number: '5',
              title: isPersian ? 'لینک‌های خارجی' : 'External Links',
              content: isPersian 
                  ? 'برخی از صفحات ممکن است حاوی پیوندهایی به بایگانی‌های یادبود تأیید شده یا پروژه‌های مستندسازی (مثلاً مرکز اسناد حقوق بشر) باشند.\n\nاین سایت‌های خارجی تحت سیاست‌های حفظ حریم خصوصی خود اداره می‌شوند.\n\nما شما را تشویق می‌کنیم که هنگام بازدید از پیوندهای خارجی، آنها را مرور کنید.'
                  : 'Some pages may contain links to verified memorial archives or documentation projects (e.g., the Human Rights Documentation Center).\n\nThese external sites are governed by their own privacy policies.\n\nWe encourage you to review them when visiting external links.',
            ),
            
            // 6. Changes to Policy
            _buildTermsSection(context,
              number: '6',
              title: isPersian ? 'تغییرات در سیاست' : 'Changes to Policy',
              content: isPersian 
                  ? 'ما ممکن است این سیاست حفظ حریم خصوصی را برای بهبود شفافیت و حفاظت به‌روزرسانی کنیم و پس از آن همه به‌روزرسانی‌ها در بخش به‌روزرسانی‌های حریم خصوصی قابل مشاهده خواهند بود.'
                  : 'We may update this Privacy Policy to enhance transparency and protection. All updates will be visible in the Privacy Updates section.',
            ),
            
            // Questions and comments
            _buildTermsSection(context,
              number: '',
              title: isPersian ? 'سوالات و نظرات' : 'Questions and comments',
              content: isPersian 
                  ? 'برای سوالات، اصلاحات یا تأیید اطلاعات ارسالی، لطفاً با ما از طریق support@irage.site تماس بگیرید.'
                  : 'For questions, corrections, or verified data submissions, please reach out to us at support@irage.site.',
              emailText: 'support@irage.site',
            ),
          ],
        ),
        onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showTermsOfServiceDialog(BuildContext context, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // 30% opacity black backdrop
      isScrollControlled: true,
      builder: (context) => Consumer<AppProvider>(
        builder: (context, appProvider, child) => ContentBottomSheet(
          title: isPersian ? 'شرایط استفاده' : 'Terms and Conditions',
          titleIconEmoji: '⚖️',
          description: _formatLastUpdatedDate(appProvider, isPersian),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Introduction
            _buildTermsSectionWithIrage(context,
              number: '1',
              title: isPersian ? 'معرفی' : 'Introduction',
              content: isPersian 
                  ? 'این اپلیکیشن، ایراژ (میراث ایران)، یک ابتکار غیرانتفاعی پیشگام است که به عنوان اولین تقویم ملی ایران طراحی شده است. با استفاده از این اپلیکیشن، شما این شرایط و ضوابط را تأیید و می‌پذیرید. ما شما را به مطالعه کامل آنها تشویق می‌کنیم.'
                  : 'This application, Irage (Iranian Heritage), is a pioneering non-profit initiative designed as the first national calendar of Iran. By using this app, you acknowledge and accept these terms and conditions. We encourage you to read them in full.',
            ),
            
            // 2. Purpose of the App
            _buildTermsSection(context,
              number: '2',
              title: isPersian ? 'هدف برنامه' : 'Purpose of the App',
              content: isPersian 
                  ? 'این اپلیکیشن رویدادهای فرهنگی مهم از میراث باستانی ما را برجسته می‌کند و در عین حال دسترسی عمومی به تاریخ‌ها، رویدادها و سوابق یادبود مربوط به قربانیان خشونت دولتی، قتل و اعدام‌های رژیم جمهوری اسلامی را فراهم می‌کند.\n\nهدف آن آموزشی، تاریخی و بشردوستانه است - حفظ حقیقت، بزرگداشت قربانیان و جلوگیری از پاک شدن خاطرات.'
                  : 'This app highlights important cultural events from our ancient heritage while providing public access to dates, events, and memorial records related to victims of state violence, murders, and executions of the Islamic Republic regime.\n\nIts purpose is educational, historical, and humanitarian - preserving the truth, honoring the victims, and preventing the erasure of memories.',
            ),
            
            // 3. Use of Data
            _buildTermsSectionWithBullets(context,
              number: '3',
              title: isPersian ? 'استفاده از داده‌ها' : 'Use of Data',
              bullets: isPersian 
                  ? [
                      'تمام اطلاعات موجود در برنامه از منابع آزاد، اسناد تأیید شده یا مشارکت‌های عمومی جمع‌آوری شده است.',
                      'شما می‌توانید داده‌ها را فقط برای اهداف غیرتجاری و آموزشی مشاهده، به اشتراک بگذارید یا به آنها ارجاع دهید.',
                      'هرگونه تلاش برای تحریف، دستکاری یا استفاده از محتوا برای ترویج نفرت، اطلاعات نادرست یا تبلیغات سیاسی اکیداً ممنوع است.',
                    ]
                  : [
                      'All information in the App is collected from open sources, verified documentation, or public contributions.',
                      'You may view, share, or reference the data only for non-commercial and educational purposes.',
                      'Any attempt to distort, manipulate, or use the content to promote hate, misinformation, or political propaganda is strictly prohibited.',
                    ],
              hasNote: true,
              noteContent: isPersian 
                  ? 'توجه: اگر خطایی مشاهده کردید یا مایل به ارائه داده‌های تأیید شده هستید، می‌توانید از طریق **ارسال گزارش** با ما تماس بگیرید.'
                  : 'Note: If you discover an error or wish to contribute verified data, you can contact us through **Submit a Report**.',
              linkText: isPersian ? 'ارسال گزارش' : 'Submit a Report',
            ),
            
            // 4. User Contributions
            _buildTermsSectionWithBullets(context,
              number: '4',
              title: isPersian ? 'مشارکت‌های کاربران' : 'User Contributions',
              bullets: isPersian 
                  ? [
                      'مطالب ارسالی ممکن است شامل نام، تاریخ یا داستان‌هایی از قربانیان باشد.',
                      'با ارسال، شما تأیید می‌کنید که اطلاعات تا جایی که می‌دانید دقیق است.',
                      'تمام مطالب ارسالی از نظر دقت و احترام به قربانیان و خانواده‌هایشان بررسی می‌شوند.',
                      'هرگونه مطلب توهین‌آمیز یا نادرست بدون اطلاع قبلی حذف خواهد شد.',
                    ]
                  : [
                      'Submissions may include names, dates, or stories of victims.',
                      'By submitting, you confirm that the information is accurate to the best of your knowledge.',
                      'All contributions are reviewed for accuracy and respect toward victims and their families.',
                      'Any offensive or false submissions will be removed without notice.',
                    ],
              hasNote: true,
              noteContent: isPersian 
                  ? 'برای مشارکت، لطفاً به بخش **افزودن یا ویرایش رکورد** مراجعه کنید.'
                  : 'To contribute, please visit **Add or Edit Record**.',
              linkText: isPersian ? 'افزودن یا ویرایش رکورد' : 'Add or Edit Record',
            ),
            
            // 5. Intellectual Property
            _buildTermsSection(context,
              number: '5',
              title: isPersian ? 'مالکیت معنوی' : 'Intellectual Property',
              content: isPersian 
                  ? 'تمام محتوای متنی، تصویری و داده‌های برنامه تحت مجوز Creative Commons Attribution–NonCommercial (CC BY-NC) به اشتراک گذاشته می‌شود.\n\nاین بدان معناست که شما می‌توانید محتوا را به اشتراک بگذارید یا اقتباس کنید، مشروط بر اینکه برای اهداف تجاری نباشد و به درستی به این پروژه نسبت داده شود.'
                  : 'All textual, visual, and data content of the App is shared under a Creative Commons Attribution–NonCommercial (CC BY-NC) license.\n\nThis means you are free to share or adapt the content, provided it is not for commercial purposes and proper attribution is given to this project.',
            ),
            
            // 6. Disclaimer
            _buildTermsSectionWithBullets(context,
              number: '6',
              title: isPersian ? 'سلب مسئولیت' : 'Disclaimer',
              bullets: isPersian 
                  ? [
                      'این برنامه نماینده هیچ سازمان یا گروه سیاسی نیست.',
                      'این برنامه صرفاً به عنوان یک پروژه یادبود و مستندسازی علیه جنایات انجام شده توسط رژیم جمهوری اسلامی عمل می‌کند.',
                      'سازندگان به دلایل امنیتی ناشناس هستند و مستقل از هر دولت یا نهادی فعالیت می‌کنند.',
                    ]
                  : [
                      'The App does not represent any political organization or group.',
                      'It serves solely as a memorial and documentation project against crimes committed by the Islamic Republic regime.',
                      'The creators are anonymous for safety reasons and operate independently of any government or institution.',
                    ],
            ),
            
            // 7. Limitation of Liability
            _buildTermsSectionWithIrageQuoted(context,
              number: '7',
              title: isPersian ? 'محدودیت مسئولیت' : 'Limitation of Liability',
              content: isPersian 
                  ? 'این پروژه توسط «ایراژ» (میراث ایران) ارائه شده است.\n\nما هیچ مسئولیتی در قبال هرگونه سوءاستفاده، تفسیر نادرست یا توزیع مجدد غیرمجاز داده‌ها نداریم.'
                  : 'The project is provided "Irage" (Iranian Heritage). We are not responsible for any misuse, misinterpretation, or unauthorized redistribution of the data.',
            ),
            
            // Questions and comments (no number)
            _buildTermsSection(context,
              number: '',
              title: isPersian ? 'سوالات و نظرات' : 'Questions and comments',
              content: isPersian 
                  ? 'برای سوالات، اصلاحات یا تأیید اطلاعات ارسالی، لطفاً با ما از طریق support@irage.site تماس بگیرید.'
                  : 'For questions, corrections, or verified data submissions, please reach out to us at support@irage.site.',
              emailText: 'support@irage.site',
            ),
          ],
        ),
        onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context, bool isPersian) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPersian ? 'راهنما و پشتیبانی' : 'Help & Support'),
        content: Text(
          isPersian 
              ? 'راهنمای استفاده و پشتیبانی فنی برنامه.'
              : 'User guide and technical support for the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isPersian ? 'بستن' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // 30% opacity black backdrop
      isScrollControlled: true,
      builder: (context) => ContentBottomSheet(
        title: isPersian ? 'به اشتراک بگذارید بازخورد شما' : 'Share your Feedback',
        titleIconEmoji: '📬',
        description: isPersian 
            ? 'نظرات و پیشنهادات خود را با ما در میان بگذارید. بازخورد شما به ما کمک می‌کند تا برنامه را بهتر کنیم.'
            : 'Share your thoughts and suggestions with us. Your feedback helps us improve the app.',
        content: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // How to Send Feedback
                  _buildFeedbackSection(context,
              title: isPersian ? 'نحوه ارسال بازخورد' : 'How to Send Feedback',
              bullets: isPersian 
                  ? [
                      'ایمیل: feedback@irage.site',
                      'توییتر: @irage_official',
                      'اینستاگرام: irage.site',
                      'گیت‌هاب: github.com/irage-official/iranian-heritage',
                    ]
                  : [
                      'Email: feedback@irage.site',
                      'Twitter: @irage_official',
                      'Instagram: irage.site',
                      'GitHub: github.com/irage-official/iranian-heritage',
                    ],
            ),
            
            // Suggested Topics
            _buildFeedbackSection(context,
              title: isPersian ? 'موضوعات پیشنهادی' : 'Suggested Topics',
              bullets: isPersian 
                  ? [
                      'گزارش باگ‌ها و مشکلات',
                      'پیشنهادات برای ویژگی‌های جدید',
                      'بهبود رابط کاربری',
                      'دقت اطلاعات تقویم',
                    ]
                  : [
                      'Bug reports and issues',
                      'Suggestions for new features',
                      'UI/UX improvements',
                      'Calendar information accuracy',
                    ],
            ),
                ],
              ),
            );
          },
        ),
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context, {
    required String title,
    required List<String> bullets,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
            Text(
          title,
            style: TextStyle(
                fontSize: 14,
            height: 1.4,
            letterSpacing: -0.28,
            color: TCnt.neutralMain(context),
            fontWeight: FontWeight.w700,
           ),
        ),
        const SizedBox(height: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var bullet in bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildFeedbackBullet(context, bullet),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeedbackBullet(BuildContext context, String text) {
    // Check if text has link
    if (text.contains('@') || text.contains('twitter.com') || text.contains('instagram.com') || text.contains('github.com')) {
      // Extract link text (email, Twitter handle, Instagram handle, or GitHub URL)
      final linkMatch = RegExp(r'(https?://[^\s]+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}|@[A-Za-z0-9_]+|[A-Za-z0-9._-]+\.[A-Za-z]{2,})').firstMatch(text);
      if (linkMatch != null) {
        final linkText = linkMatch.group(0)!;
        final textBefore = text.substring(0, linkMatch.start);
        final textAfter = text.substring(linkMatch.end);
        
        // Check if it's a Twitter handle, Instagram handle, or email
        final isTwitterHandle = linkText.startsWith('@');
        final isInstagramHandle = linkText.contains('.') && !linkText.contains('@') && !linkText.startsWith('http');
        final isEmail = linkText.contains('@') && linkText.contains('.');
        final isUrl = linkText.startsWith('http');
        
        return Text.rich(
          TextSpan(
              style: TextStyle(
              fontSize: 14,
                height: 1.6,
              letterSpacing: -0.098,
              color: TCnt.neutralSecond(context),
            ),
            children: [
              TextSpan(text: textBefore),
              TextSpan(
                text: linkText,
                style: const TextStyle(
                  color: ThemeColors.primary500,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    Uri? uri;
                    if (isTwitterHandle) {
                      uri = Uri.parse('https://twitter.com/${linkText.substring(1)}');
                    } else if (isInstagramHandle) {
                      uri = Uri.parse('https://instagram.com/$linkText');
                    } else if (isEmail) {
                      uri = Uri.parse('mailto:$linkText');
                    } else if (isUrl) {
                      uri = Uri.parse(linkText);
                    }
                    
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
              ),
              TextSpan(text: textAfter),
            ],
          ),
        );
      }
    }
    
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        letterSpacing: -0.098,
        color: TCnt.neutralSecond(context),
      ),
    );
  }

  Future<void> _checkForUpdates(BuildContext context, bool isPersian) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TBg.main(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                isPersian ? 'در حال بررسی...' : 'Checking...',
                style: TextStyle(
                  fontFamily: isPersian ? 'Vazir' : 'Inter',
                  color: TCnt.neutralMain(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final updateService = UpdateService.instance;
      bool eventsUpdated = false;
      AppVersion? appVersion;

      // Check events update
      final needsEventsUpdate = await updateService.forceCheckEventsUpdate();
      if (needsEventsUpdate) {
        final newEvents = await updateService.downloadEvents();
        if (newEvents.isNotEmpty) {
          await EventService.instance.saveEvents(newEvents);
          await context.read<EventProvider>().reload();
          eventsUpdated = true;
        }
      }

      // Check app version
      appVersion = await updateService.checkAppVersion();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show results
      if (appVersion != null) {
        // Show app update dialog
        if (context.mounted) {
          _showUpdateDialog(context, appVersion, isPersian);
        }
      } else if (eventsUpdated) {
        // Show events updated message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPersian ? 'ایونت‌ها با موفقیت به‌روزرسانی شدند' : 'Events updated successfully',
                style: TextStyle(
                  fontFamily: isPersian ? 'Vazir' : 'Inter',
                ),
              ),
              backgroundColor: ThemeColors.primary500,
            ),
          );
        }
      } else {
        // Show no update message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPersian ? 'همه چیز به‌روز است!' : 'Everything is up to date!',
                style: TextStyle(
                  fontFamily: isPersian ? 'Vazir' : 'Inter',
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPersian ? 'خطا در بررسی آپدیت' : 'Error checking for updates',
              style: TextStyle(
                fontFamily: isPersian ? 'Vazir' : 'Inter',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show update dialog
  void _showUpdateDialog(BuildContext context, AppVersion version, bool isPersian) {
    final releaseNotes = version.getReleaseNotes(isPersian ? 'fa' : 'en') ??
        (isPersian ? 'آپدیت جدید در دسترس است' : 'New update is available');

    showDialog(
      context: context,
      barrierDismissible: !version.isCritical,
      builder: (context) => AlertDialog(
        title: Text(
          isPersian ? 'آپدیت جدید' : 'New Update',
          style: TextStyle(
            fontFamily: isPersian ? 'Vazir' : 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            releaseNotes,
            style: TextStyle(
              fontFamily: isPersian ? 'Vazir' : 'Inter',
            ),
          ),
        ),
        actions: [
          if (!version.isCritical)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isPersian ? 'بعداً' : 'Later',
                style: TextStyle(
                  fontFamily: isPersian ? 'Vazir' : 'Inter',
                ),
              ),
            ),
          TextButton(
            onPressed: () async {
              if (version.downloadUrl != null) {
                final uri = Uri.parse(version.downloadUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
              if (!version.isCritical) {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              isPersian ? 'آپدیت' : 'Update',
              style: TextStyle(
                fontFamily: isPersian ? 'Vazir' : 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareApp(BuildContext context, bool isPersian) async {
    try {
      final String shareText = isPersian 
          ? '''🕊️ ایراژ (میراث ایرانی) - تقویم یادبود و مستندسازی

یک تقویم یادبود برای حفظ حافظه و مستندسازی جنایات انجام شده توسط رژیم جمهوری اسلامی. این برنامه تاریخ‌های مهم، رویدادها و سوابق مربوط به قربانیان خشونت دولتی را ثبت می‌کند.

هر تاریخ در این تقویم حامل خاطره زندگی گرفته شده، داستان خاموش شده، یا حقیقتی پنهان شده است.

📱 دانلود برنامه:
https://ir-heritage.com/download

#میراث_ایرانی #حافظه_مقاومت #تقویم_یادبود'''
          : '''🕊️ Irage (Iranian Heritage) - Memorial and Documentation Calendar

A memorial calendar to preserve memory and document crimes committed by the Islamic Republic regime. This app records important dates, events, and records related to victims of state violence.

Every date in this calendar carries the memory of a life taken, a story silenced, or a truth hidden.

📱 Download the app:
https://ir-heritage.com/download

#IranianHeritage #MemoryIsResistance #MemorialCalendar''';
      
      await Share.share(
        shareText,
        subject: isPersian ? '🕊️ ایراژ (میراث ایرانی) - تقویم یادبود' : '🕊️ Irage (Iranian Heritage) - Memorial Calendar',
      );
    } catch (e) {
      if (context.mounted) {
        context.showToast(isPersian ? 'خطا در اشتراک‌گذاری' : 'Error sharing');
      }
    }
  }

  Widget _buildResourceItem(BuildContext context, {
    required String iconPath,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TBr.neutralSecondary(context), width: 0.5),
              image: DecorationImage(
                image: AssetImage(iconPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4, // 140%
                    letterSpacing: -0.098, // -0.7% of 14
                    color: TCnt.neutralMain(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5, // 150%
                    letterSpacing: -0.084, // -0.7% of 12
                    color: TCnt.neutralFourth(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Arrow icon
          SvgIconWidget(
            assetPath: AppIcons.arrowUpRight,
            size: 24,
            color: TCnt.neutralWeak(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openResourceUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        height: 1.4, // 140%
        letterSpacing: -0.32, // -2% of 16
        color: TCnt.neutralMain(context),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTermsSectionWithMultipleEmails(BuildContext context, {
    required String number,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        number.isNotEmpty
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    child: Text(
                      '$number.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.32,
                  color: TCnt.neutralMain(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
        const SizedBox(height: 6),
        Padding(
          padding: number.isEmpty ? EdgeInsets.zero : const EdgeInsets.only(left: 24),
          child: _buildRichTextWithMultipleEmails(context, content),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTermsSectionWithIrage(BuildContext context, {
    required String number,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        number.isNotEmpty
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    child: Text(
                      '$number.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.32,
                  color: TCnt.neutralMain(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
        const SizedBox(height: 6),
        Padding(
          padding: number.isEmpty ? EdgeInsets.zero : const EdgeInsets.only(left: 24),
          child: _buildRichTextWithIrage(context, content),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTermsSectionWithIrageQuoted(BuildContext context, {
    required String number,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        number.isNotEmpty
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    child: Text(
                      '$number.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.32,
                  color: TCnt.neutralMain(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
        const SizedBox(height: 6),
        Padding(
          padding: number.isEmpty ? EdgeInsets.zero : const EdgeInsets.only(left: 24),
          child: _buildRichTextWithIrageQuoted(context, content),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRichTextWithIrage(BuildContext context, String text) {
    // Get isPersian from AppProvider
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final isPersian = appProvider.language == 'fa';
    
    // Find "Irage (Iranian Heritage)" or "Irage (میراث ایرانی)" or "ایراژ (میراث ایرانی)"
    final iragePattern = RegExp(r'(Irage|ایراژ)\s*\(([^)]+)\)');
    final match = iragePattern.firstMatch(text);
    
    if (match == null) {
      // If pattern not found, return regular text
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          letterSpacing: -0.098,
          color: TCnt.neutralSecond(context),
        ),
      );
    }
    
    final beforeText = text.substring(0, match.start);
    final irageText = isPersian ? 'ایراژ' : 'Irage';
    final heritageText = ' (${match.group(2)})';
    final afterText = text.substring(match.end);
    
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          letterSpacing: -0.098,
          color: TCnt.neutralSecond(context),
        ),
        children: [
          if (beforeText.isNotEmpty) TextSpan(text: beforeText),
          TextSpan(
            text: irageText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TCnt.neutralMain(context)
                  : null,
            ),
          ),
          TextSpan(
            text: heritageText,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TCnt.neutralTertiary(context)
                  : TCnt.neutralTertiary(context).withOpacity(0.7),
            ),
          ),
          if (afterText.isNotEmpty) TextSpan(text: afterText),
        ],
      ),
    );
  }

  Widget _buildRichTextWithIrageQuoted(BuildContext context, String text) {
    // Get isPersian from AppProvider
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final isPersian = appProvider.language == 'fa';
    
    // Find "Irage" (Iranian Heritage)" or «ایراژ» (میراث ایرانی)" pattern - Irage in quotes, heritage outside
    // Support both English quotes (") and Persian quotes («»)
    final iragePattern = RegExp(r'["«](Irage|ایراژ)["»]\s*\(([^)]+)\)');
    final match = iragePattern.firstMatch(text);
    
    if (match == null) {
      // If pattern not found, return regular text
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          letterSpacing: -0.098,
          color: TCnt.neutralSecond(context),
        ),
      );
    }
    
    final beforeText = text.substring(0, match.start);
    final quoteStart = match.group(0)!.startsWith('«') ? '«' : '"';
    final irageText = isPersian ? 'ایراژ' : 'Irage';
    final quoteEnd = match.group(0)!.contains('»') ? '»' : '"';
    final heritageText = ' (${match.group(2)})';
    final afterText = text.substring(match.end);
    
    // Handle newlines in text
    final textParts = afterText.split('\n\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              letterSpacing: -0.098,
              color: TCnt.neutralSecond(context),
            ),
            children: [
              if (beforeText.isNotEmpty) TextSpan(text: beforeText),
              TextSpan(text: quoteStart),
              TextSpan(
                text: irageText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TCnt.neutralMain(context)
                      : null,
                ),
              ),
              TextSpan(text: quoteEnd),
              TextSpan(
                text: heritageText,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TCnt.neutralTertiary(context)
                      : TCnt.neutralTertiary(context).withOpacity(0.7),
                ),
              ),
              if (textParts.isNotEmpty && textParts[0].isNotEmpty) TextSpan(text: textParts[0]),
            ],
          ),
        ),
        if (textParts.length > 1) ...[
          const SizedBox(height: 16),
          for (int i = 1; i < textParts.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                textParts[i],
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  letterSpacing: -0.098,
                  color: _getDescriptionColor(context),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildTermsSection(BuildContext context, {
    required String number,
    required String title,
    required String content,
    String? boldText,
    String? emailText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        number.isNotEmpty
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    child: Text(
                      '$number.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.32,
                  color: TCnt.neutralMain(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
        const SizedBox(height: 6),
        Padding(
          padding: number.isEmpty ? EdgeInsets.zero : const EdgeInsets.only(left: 24),
          child: emailText != null 
              ? _buildRichTextWithEmail(context, content, emailText)
              : _buildRichTextWithBoldAndLink(context, content, boldText, null),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTermsSectionWithBullets(BuildContext context, {
    required String number,
    required String title,
    required List<String> bullets,
    bool hasNote = false,
    String? noteContent,
    String? linkText,
    bool hasAdditionalText = false,
    String? additionalText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              child: Text(
                '$number.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.32,
                  color: TCnt.neutralMain(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.32,
                  color: TCnt.neutralMain(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bullet points
              for (var bullet in bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          letterSpacing: -0.098,
                          color: _getDescriptionColor(context),
                        ),
                      ),
                      Expanded(
                        child: _buildRichTextWithBold(context, bullet),
                      ),
                    ],
                  ),
                ),
              // Note callout
              if (hasNote) ...[
                const SizedBox(height: 6),
                _buildNoteCallout(context, noteContent!, linkText),
              ],
              // Additional text with link
              if (hasAdditionalText)
                Padding(
                  padding: EdgeInsets.only(top: hasNote ? 0 : 6),
                  child: _buildRichTextWithLink(context, additionalText!, linkText),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRichTextWithBold(BuildContext context, String text) {
    final parts = text.split('**');
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.6, // 160%
          letterSpacing: -0.098, // -0.7% of 14
          color: TCnt.neutralSecond(context),
        ),
        children: parts.asMap().entries.map((entry) {
          final index = entry.key;
          final part = entry.value;
          return TextSpan(
            text: part,
            style: index.isOdd
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRichTextWithBoldAndLink(BuildContext context, String text, String? boldText, String? linkText) {
    final parts = text.split('**');
    final spans = <TextSpan>[];
    
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      final isOdd = i % 2 == 1;
      
      if (isOdd) {
        // Bold text
        spans.add(TextSpan(
          text: part,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else {
        // Regular text - check for links
        if (linkText != null && part.contains(linkText)) {
          final linkIndex = part.indexOf(linkText);
          if (linkIndex > 0) {
            spans.add(TextSpan(text: part.substring(0, linkIndex)));
          }
          spans.add(TextSpan(
            text: linkText,
            style: const TextStyle(
              color: ThemeColors.indigo500,
            ),
          ));
          if (linkIndex + linkText.length < part.length) {
            spans.add(TextSpan(text: part.substring(linkIndex + linkText.length)));
          }
        } else {
          spans.add(TextSpan(text: part));
        }
      }
    }
    
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.6, // 160%
          letterSpacing: -0.098, // -0.7% of 14
          color: TCnt.neutralSecond(context),
        ),
        children: spans,
      ),
    );
  }

  Widget _buildRichTextWithMultipleEmails(BuildContext context, String text) {
    final emailRegex = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    final parts = text.split('**');
    final spans = <TextSpan>[];
    
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      final isOdd = i % 2 == 1;
      
      if (isOdd) {
        // Bold text - check if it contains email
        final emailMatch = emailRegex.firstMatch(part);
        if (emailMatch != null && emailMatch.group(0) == part) {
          // The entire bold text is an email
          spans.add(TextSpan(
            text: part,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: ThemeColors.primary500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final Uri emailUri = Uri.parse('mailto:$part');
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
          ));
        } else {
          spans.add(TextSpan(
            text: part,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ));
        }
      } else {
        // Regular text - find all emails
        int lastIndex = 0;
        for (final match in emailRegex.allMatches(part)) {
          // Add text before email
          if (match.start > lastIndex) {
            spans.add(TextSpan(text: part.substring(lastIndex, match.start)));
          }
          // Add clickable email
          final email = match.group(0)!;
          spans.add(TextSpan(
            text: email,
            style: const TextStyle(
              color: ThemeColors.primary500,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final Uri emailUri = Uri.parse('mailto:$email');
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
          ));
          lastIndex = match.end;
        }
        // Add remaining text
        if (lastIndex < part.length) {
          spans.add(TextSpan(text: part.substring(lastIndex)));
        }
      }
    }
    
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          letterSpacing: -0.098,
          color: TCnt.neutralSecond(context),
        ),
        children: spans,
      ),
    );
  }

  Widget _buildRichTextWithEmail(BuildContext context, String text, String emailText) {
    final parts = text.split('**');
    final spans = <TextSpan>[];
    
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      final isOdd = i % 2 == 1;
      
      if (isOdd) {
        // Bold text - check if it's the email
        if (part == emailText) {
          spans.add(TextSpan(
            text: part,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: ThemeColors.primary500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final Uri emailUri = Uri.parse('mailto:$emailText');
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
          ));
        } else {
          spans.add(TextSpan(
            text: part,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ));
        }
      } else {
        // Regular text - check for email
        if (part.contains(emailText)) {
          final emailIndex = part.indexOf(emailText);
          if (emailIndex > 0) {
            spans.add(TextSpan(text: part.substring(0, emailIndex)));
          }
          spans.add(TextSpan(
            text: emailText,
            style: const TextStyle(
              color: ThemeColors.primary500,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final Uri emailUri = Uri.parse('mailto:$emailText');
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
          ));
          if (emailIndex + emailText.length < part.length) {
            spans.add(TextSpan(text: part.substring(emailIndex + emailText.length)));
          }
        } else {
          spans.add(TextSpan(text: part));
        }
      }
    }
    
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          letterSpacing: -0.098,
          color: TCnt.neutralSecond(context),
        ),
        children: spans,
      ),
    );
  }

  Widget _buildRichTextWithLink(BuildContext context, String text, String? linkText) {
    if (linkText == null) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          letterSpacing: -0.098,
          color: TCnt.neutralSecond(context),
        ),
      );
    }
    
    // Get isPersian from AppProvider
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final isPersian = appProvider.language == 'fa';
    
    // Check if this is the "Submit a Report" or "Add or Edit Record" link - should open feedback email
    final isSubmitReportLink = linkText == 'ارسال گزارش' || linkText == 'Submit a Report';
    final isAddEditRecordLink = linkText == 'افزودن یا ویرایش رکورد' || linkText == 'Add or Edit Record';
    final shouldOpenFeedbackEmail = isSubmitReportLink || isAddEditRecordLink;
    
    // Check if linkText is wrapped in ** for bold
    final linkInBold = '**$linkText**';
    final hasBoldLink = text.contains(linkInBold);
    
    if (hasBoldLink) {
      final parts = text.split(linkInBold);
      return Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            letterSpacing: -0.098,
            color: TCnt.neutralSecond(context),
          ),
          children: [
            for (int i = 0; i < parts.length; i++) ...[
              if (parts[i].isNotEmpty) TextSpan(text: parts[i]),
              if (i < parts.length - 1)
                TextSpan(
                  text: linkText,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: TCnt.brandMain(context),
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      if (shouldOpenFeedbackEmail) {
                        // Open feedback email
                        const emailText = 'feedback@irage.site';
                        final Uri emailUri = Uri.parse('mailto:$emailText');
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      } else {
                        final msg = isPersian
                            ? 'این قابلیت فعلاً در دسترس نیست. به زودی فعال می‌شود.'
                            : 'This feature is not available yet. Coming soon!';
                        context.showToast(msg);
                      }
                    },
                ),
            ],
          ],
        ),
      );
    }
    
    final index = text.indexOf('**$linkText**');
    if (index != -1) {
      return Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            letterSpacing: -0.098,
            color: TCnt.neutralSecond(context),
          ),
          children: [
            TextSpan(text: text.substring(0, index)),
            TextSpan(
              text: linkText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: TCnt.brandMain(context),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (isSubmitReportLink) {
                    // Open feedback email
                    const emailText = 'feedback@irage.site';
                    final Uri emailUri = Uri.parse('mailto:$emailText');
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    }
                  } else {
                    final msg = isPersian
                        ? 'این قابلیت فعلاً در دسترس نیست. به زودی فعال می‌شود.'
                        : 'This feature is not available yet. Coming soon!';
                    context.showToast(msg);
                  }
                },
            ),
            TextSpan(text: text.substring(index + linkInBold.length)),
          ],
        ),
      );
    }
    
    final simpleIndex = text.indexOf(linkText);
    if (simpleIndex == -1) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          letterSpacing: -0.098,
          color: TCnt.neutralSecond(context),
        ),
      );
    }
    
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          letterSpacing: -0.098,
          color: TCnt.neutralSecond(context),
        ),
        children: [
          TextSpan(text: text.substring(0, simpleIndex)),
          TextSpan(
            text: linkText,
            style: TextStyle(
              color: TCnt.brandMain(context),
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                if (isSubmitReportLink) {
                  // Open feedback email
                  const emailText = 'feedback@irage.site';
                  final Uri emailUri = Uri.parse('mailto:$emailText');
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                } else {
                  final msg = isPersian
                      ? 'این قابلیت فعلاً در دسترس نیست. به زودی فعال می‌شود.'
                      : 'This feature is not available yet. Coming soon!';
                  context.showToast(msg);
                }
              },
          ),
          TextSpan(text: text.substring(simpleIndex + linkText.length)),
        ],
      ),
    );
  }

  Widget _buildNoteCallout(BuildContext context, String noteContent, String? linkText) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left border with height matching content
          Container(
            width: 2,
            color: ThemeColors.indigo500,
            margin: const EdgeInsets.only(right: 8),
          ),
          // Content without top/bottom padding
          Expanded(
            child: _buildRichTextWithLink(context, noteContent, linkText),
          ),
        ],
      ),
    );
  }
}
