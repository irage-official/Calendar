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
import '../utils/font_helper.dart';
import '../utils/svg_helper.dart';
import '../utils/about_content_helpers.dart';
import '../widgets/about_bottom_sheet.dart';
import '../utils/extensions.dart';
import '../utils/calendar_utils.dart';
import '../config/app_config.dart';
import '../services/date_converter_service.dart';
import '../services/update_service.dart';
import '../services/event_service.dart';
import '../models/app_version.dart';
import 'calendar_events_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final isScrolled = _scrollController.hasClients && 
                       _scrollController.position.pixels > 0;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

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
                child: Stack(
                  children: [
                    ListView(
                      controller: _scrollController,
                      children: [
                        // Personalization Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildPersonalizationSection(context, isPersian),
                        ),
                        
                        // Support & Extras Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildSupportAndExtrasSection(context, isPersian),
                        ),
                        
                        // System & Policies Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildSystemAndPoliciesSection(context, isPersian),
                        ),
                        
                        // Version at bottom (inside ListView)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(
                            child: Text(
                              _formatVersion(AppConfig.appVersion, isPersian),
                              style: isPersian
                                  ? FontHelper.getYekanBakh(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: TCnt.neutralWeak(context),
                                    )
                                  : AppTextStyles.bodySmall.copyWith(
                                      color: TCnt.neutralWeak(context),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Top gradient overlay (below header) - only show when scrolled
                    if (_isScrolled)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 32,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  TBg.main(context),
                                  TBg.main(context).withOpacity(0.8),
                                  TBg.main(context).withOpacity(0),
                                ],
                                stops: const [0.0, 0.3, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Bottom gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 32,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                TBg.main(context),
                                TBg.main(context).withOpacity(0.8),
                                TBg.main(context).withOpacity(0),
                              ],
                              stops: const [0.0, 0.3, 1.0],
                            ),
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
        );
      },
    );
  }

  Widget _buildPersonalizationSection(BuildContext context, bool isPersian) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
              child: Text(
                isPersian ? 'شخصی سازی' : 'Personalization',
                style: isPersian
                    ? FontHelper.getYekanBakh(
                        fontSize: 14,
                        height: 1.4,
                        letterSpacing: -0.007,
                        fontWeight: FontWeight.w500,
                        color: TCnt.neutralMain(context).withOpacity(0.5),
                      )
                    : FontHelper.getInter(
                        fontSize: 14,
                        height: 1.4,
                        letterSpacing: -0.007,
                        fontWeight: FontWeight.w500,
                        color: TCnt.neutralMain(context).withOpacity(0.5),
                      ),
              ),
            ),
            SettingItem(
              icon: AppIcons.calendarDays,
              title: isPersian ? 'تقویم و رویدادها' : 'Calendar & Events',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CalendarEventsSettingsScreen(),
                  ),
                );
              },
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
              icon: AppIcons.globe,
              title: isPersian ? ' تغییر زبان اپلیکیشن' : 'Change Language',
              subtitle: _getCurrentLanguageText(appProvider.language, isPersian),
              onTap: () => _showLanguageBottomSheet(context, isPersian),
              margin: EdgeInsets.zero,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSupportAndExtrasSection(BuildContext context, bool isPersian) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
          child: Text(
            isPersian ? 'پشتیبانی و موارد اضافی' : 'Support & Extras',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.4,
                    letterSpacing: -0.007,
                    fontWeight: FontWeight.w500,
                    color: TCnt.neutralMain(context).withOpacity(0.5),
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    height: 1.4,
                    letterSpacing: -0.007,
                    fontWeight: FontWeight.w500,
                    color: TCnt.neutralMain(context).withOpacity(0.5),
                  ),
          ),
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
        SettingItem(
          icon: AppIcons.infoCircle,
          title: isPersian ? 'درباره ما' : 'About Us',
          onTap: () => _showAboutDialog(context, isPersian),
          showArrow: false,
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSystemAndPoliciesSection(BuildContext context, bool isPersian) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
          child: Text(
            isPersian ? 'سیستم و سیاست‌ها' : 'System & Policies',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.4,
                    letterSpacing: -0.007,
                    fontWeight: FontWeight.w500,
                    color: TCnt.neutralMain(context).withOpacity(0.5),
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    height: 1.4,
                    letterSpacing: -0.007,
                    fontWeight: FontWeight.w500,
                    color: TCnt.neutralMain(context).withOpacity(0.5),
                  ),
          ),
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
          title: isPersian ? 'شرایط استفاده' : 'Terms of Service',
          onTap: () => _showTermsOfServiceDialog(context, isPersian),
          showArrow: false,
          margin: EdgeInsets.zero,
        ),
        SettingItem(
          icon: AppIcons.update,
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
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
                    )
                  : FontHelper.getInter(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
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
                        style: FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.6,
                          letterSpacing: -0.098,
                          color: aboutDescriptionColor(context),
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          const TextSpan(text: 'برای محافظت از حریم خصوصی شما، کمک‌های مالی را به کیف پول تتر ('),
                          TextSpan(text: 'USDT', style: FontHelper.getInter(fontWeight: FontWeight.bold)),
                          const TextSpan(text: ') ما در شبکه '),
                          TextSpan(text: 'TRON', style: FontHelper.getInter(fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' ('),
                          TextSpan(text: 'TRC20', style: FontHelper.getInter(fontWeight: FontWeight.bold)),
                          const TextSpan(text: ') ارسال کنید. هیچ داده شخصی جمع‌آوری نخواهد شد.'),
                        ],
                      ),
                    )
                  : Text.rich(
                      TextSpan(
                        style: FontHelper.getInter(
                          fontSize: 14,
                          height: 1.6,
                          letterSpacing: -0.098,
                          color: aboutDescriptionColor(context),
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          const TextSpan(text: 'To protect your privacy, send contributions to our Tether ('),
                          TextSpan(text: 'USDT', style: FontHelper.getInter(fontWeight: FontWeight.bold)),
                          const TextSpan(text: ') wallet on '),
                          TextSpan(text: 'TRON', style: FontHelper.getInter(fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' ('),
                          TextSpan(text: 'TRC20', style: FontHelper.getInter(fontWeight: FontWeight.bold)),
                          const TextSpan(text: '). No personal data will be collected.'),
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
          style: FontHelper.getInter(
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
            style: FontHelper.getInter(
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
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
                    )
                  : FontHelper.getInter(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              isPersian 
                  ? 'در زیر منابع کلیدی که در حفظ حقیقت و حافظه مشارکت داشته‌اند را خواهید یافت:'
                  : 'Below you\'ll find key sources that have contributed to preserving truth and memory.',
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098, // -0.7% of 14
                      color: aboutDescriptionColor(context),
                      fontWeight: FontWeight.w400,
                    )
                  : FontHelper.getInter(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098, // -0.7% of 14
                      color: aboutDescriptionColor(context),
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
    showAboutBottomSheet(context, isPersian: isPersian);
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
                        style: FontHelper.getInter(
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
                        style: FontHelper.getInter(
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
                        style: FontHelper.getInter(
                          fontSize: 14,
                          height: 1.6,
                          letterSpacing: -0.098,
                          color: aboutDescriptionColor(context),
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
            buildTermsSectionWithIrage(context,
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
            buildTermsSectionWithIrageQuoted(context,
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

  Future<void> _checkForUpdates(BuildContext context, bool isPersian) async {
    // Show checking toast
    if (context.mounted) {
      context.showToast(
        isPersian ? 'در حال بررسی...' : 'Checking...',
        duration: const Duration(seconds: 2),
      );
    }

    try {
      final updateService = UpdateService.instance;
      bool eventsUpdated = false;
      AppVersion? appVersion;

      // Check events update
      final needsEventsUpdate = await updateService.forceCheckEventsUpdate();
      if (needsEventsUpdate) {
        final newEvents = await updateService.downloadEvents();
        if (newEvents.isNotEmpty) {
          final eventService = EventService.instance;
          // Clear all cache before saving new events
          await eventService.clearAllCache();
          await eventService.saveEvents(newEvents);
          await context.read<EventProvider>().reload();
          eventsUpdated = true;
        }
      }

      // Check app version
      appVersion = await updateService.checkAppVersion();

      // Show results
      if (appVersion != null) {
        // Show app update dialog
        if (context.mounted) {
          _showUpdateDialog(context, appVersion, isPersian);
        }
      } else if (eventsUpdated) {
        // Show events updated message
        if (context.mounted) {
          context.showToast(
            isPersian ? 'ایونت‌ها با موفقیت به‌روزرسانی شدند' : 'Events updated successfully',
          );
        }
      } else {
        // Show no update message
        if (context.mounted) {
          context.showToast(
            isPersian ? 'همه چیز به‌روز است!' : 'Everything is up to date!',
          );
        }
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        context.showToast(
          isPersian ? 'خطا در بررسی آپدیت' : 'Error checking for updates',
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
          style: isPersian
              ? FontHelper.getYekanBakh(fontWeight: FontWeight.bold)
              : FontHelper.getInter(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            releaseNotes,
            style: isPersian
                ? FontHelper.getYekanBakh()
                : FontHelper.getInter(),
          ),
        ),
        actions: [
          if (!version.isCritical)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isPersian ? 'بعداً' : 'Later',
                style: isPersian
                    ? FontHelper.getYekanBakh()
                    : FontHelper.getInter(),
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
              style: isPersian
                  ? FontHelper.getYekanBakh(fontWeight: FontWeight.bold)
                  : FontHelper.getInter(fontWeight: FontWeight.bold),
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
    final appProvider = Provider.of<AppProvider>(context);
    final isPersian = appProvider.language == 'fa';
    
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
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.4, // 140%
                          letterSpacing: -0.098, // -0.7% of 14
                          color: TCnt.neutralMain(context),
                          fontWeight: FontWeight.w500,
                        )
                      : FontHelper.getInter(
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
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 12,
                          height: 1.5, // 150%
                          letterSpacing: -0.084, // -0.7% of 12
                          color: TCnt.neutralFourth(context),
                        )
                      : FontHelper.getInter(
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

  Widget _buildTermsSection(BuildContext context, {
    required String number,
    required String title,
    required String content,
    String? boldText,
    String? emailText,
  }) {
    final appProvider = Provider.of<AppProvider>(context);
    final isPersian = appProvider.language == 'fa';
    
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
                      style: isPersian
                          ? FontHelper.getYekanBakh(
                              fontSize: 16,
                              height: 1.4,
                              letterSpacing: -0.32,
                              color: TCnt.neutralMain(context),
                              fontWeight: FontWeight.w800,
                            )
                          : FontHelper.getInter(
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
                      style: isPersian
                          ? FontHelper.getYekanBakh(
                              fontSize: 16,
                              height: 1.4,
                              letterSpacing: -0.32,
                              color: TCnt.neutralMain(context),
                              fontWeight: FontWeight.w600,
                            )
                          : FontHelper.getInter(
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
                style: FontHelper.getInter(
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
    final appProvider = Provider.of<AppProvider>(context);
    final isPersian = appProvider.language == 'fa';
    
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
                style: isPersian
                    ? FontHelper.getYekanBakh(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w800,
                      )
                    : FontHelper.getInter(
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
                style: isPersian
                    ? FontHelper.getYekanBakh(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w600,
                      )
                    : TextStyle(
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
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
                    )
                  : FontHelper.getInter(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
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
    final appProvider = Provider.of<AppProvider>(context);
    final isPersian = appProvider.language == 'fa';
    final parts = text.split('**');
    return Text.rich(
      TextSpan(
        style: isPersian
            ? FontHelper.getYekanBakh(
                fontSize: 14,
                height: 1.6, // 160%
                letterSpacing: -0.098, // -0.7% of 14
                color: TCnt.neutralSecond(context),
              )
            : FontHelper.getInter(
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
                ? (isPersian
                    ? FontHelper.getYekanBakh(fontWeight: FontWeight.bold)
                    : FontHelper.getInter(fontWeight: FontWeight.bold))
                : (isPersian
                    ? FontHelper.getYekanBakh()
                    : null),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRichTextWithBoldAndLink(BuildContext context, String text, String? boldText, String? linkText) {
    final appProvider = Provider.of<AppProvider>(context);
    final isPersian = appProvider.language == 'fa';
    final parts = text.split('**');
    final spans = <TextSpan>[];
    
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      final isOdd = i % 2 == 1;
      
      if (isOdd) {
        // Bold text
        spans.add(TextSpan(
          text: part,
          style: isPersian
              ? FontHelper.getYekanBakh(fontWeight: FontWeight.bold)
              : FontHelper.getInter(fontWeight: FontWeight.bold),
        ));
      } else {
        // Regular text - check for links
        if (linkText != null && part.contains(linkText)) {
          final linkIndex = part.indexOf(linkText);
          if (linkIndex > 0) {
            spans.add(TextSpan(
              text: part.substring(0, linkIndex),
              style: isPersian ? FontHelper.getYekanBakh() : null,
            ));
          }
          spans.add(TextSpan(
            text: linkText,
            style: isPersian
                ? FontHelper.getYekanBakh(color: ThemeColors.indigo500)
                : FontHelper.getInter(color: ThemeColors.indigo500),
          ));
          if (linkIndex + linkText.length < part.length) {
            spans.add(TextSpan(
              text: part.substring(linkIndex + linkText.length),
              style: isPersian ? FontHelper.getYekanBakh() : null,
            ));
          }
        } else {
          spans.add(TextSpan(
            text: part,
            style: isPersian ? FontHelper.getYekanBakh() : null,
          ));
        }
      }
    }
    
    return Text.rich(
      TextSpan(
        style: isPersian
            ? FontHelper.getYekanBakh(
                fontSize: 14,
                height: 1.6, // 160%
                letterSpacing: -0.098, // -0.7% of 14
                color: TCnt.neutralSecond(context),
              )
            : FontHelper.getInter(
                fontSize: 14,
                height: 1.6, // 160%
                letterSpacing: -0.098, // -0.7% of 14
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
            style: FontHelper.getInter(
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
            style: FontHelper.getInter(fontWeight: FontWeight.bold),
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
            style: FontHelper.getInter(
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
        style: FontHelper.getInter(
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
        style: FontHelper.getInter(
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
                  style: FontHelper.getInter(
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
              style: FontHelper.getInter(
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
        style: FontHelper.getInter(
          fontSize: 14,
          height: 1.6,
          letterSpacing: -0.098,
          color: TCnt.neutralSecond(context),
        ),
      );
    }
    
    return Text.rich(
      TextSpan(
        style: FontHelper.getInter(
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

  /// Format version string based on language
  /// - English: "v0.9" or "v0.9.1" (hide patch if 0)
  /// - Persian: "ورژن ۰.۹" or "ورژن ۰.۹.۱" (hide patch if 0)
  String _formatVersion(String version, bool isPersian) {
    final parts = version.split('.');
    if (parts.isEmpty) return isPersian ? 'ورژن' : 'v';
    
    final major = parts.length > 0 ? parts[0] : '0';
    final minor = parts.length > 1 ? parts[1] : '0';
    final patch = parts.length > 2 ? parts[2] : '0';
    
    String formattedVersion;
    if (patch == '0') {
      // Hide patch if it's 0
      formattedVersion = '$major.$minor';
    } else {
      formattedVersion = '$major.$minor.$patch';
    }
    
    if (isPersian) {
      // Convert to Persian digits and add "ورژن" prefix
      return 'ورژن ${CalendarUtils.englishToPersianDigits(formattedVersion)}';
    } else {
      // Add "v" prefix with space for English
      return 'v $formattedVersion';
    }
  }
}
