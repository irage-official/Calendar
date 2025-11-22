import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_icons.dart';
import '../config/theme_colors.dart';
import '../widgets/loading_lines_animation.dart';
import '../config/theme_roles.dart';
import '../providers/app_provider.dart';
import '../providers/event_provider.dart';
import '../providers/calendar_provider.dart';
import '../utils/logger.dart';
import '../services/year_cache_service.dart';
import '../services/update_service.dart';
import '../services/event_service.dart';
import '../models/app_version.dart';
import '../utils/calendar_utils.dart';
import '../utils/font_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();
    const minDisplayTime = Duration(milliseconds: 2000);

    try {
      // Initialize providers
      await context.read<AppProvider>().initialize();
      
      // Get current language from AppProvider
      final appProvider = context.read<AppProvider>();
      
      // Check for events update
      final updateService = UpdateService.instance;
      bool needsEventsUpdate = false;
      
      try {
        needsEventsUpdate = await updateService.checkEventsUpdate();
        
        if (needsEventsUpdate) {
          AppLogger.info('Splash screen: Events update available, downloading...');
          // Download and update events
          final newEvents = await updateService.downloadEvents();
          if (newEvents.isNotEmpty) {
            final eventService = EventService.instance;
            // Clear all cache before saving new events
            await eventService.clearAllCache();
            await eventService.saveEvents(newEvents);
            // Reload events in provider
            await context.read<EventProvider>().reload();
            AppLogger.info('Splash screen: Events updated successfully (${newEvents.length} events)');
          } else {
            AppLogger.warning('Splash screen: Failed to download events, using cached version');
            await context.read<EventProvider>().initialize();
          }
        } else {
          // Load existing events
          await context.read<EventProvider>().initialize();
        }
      } catch (e) {
        AppLogger.error('Splash screen: Error checking/updating events', error: e);
        // Continue with existing events
        await context.read<EventProvider>().initialize();
      }
      
      // Check for app version update (in background, don't block startup)
      unawaited(_checkAppVersionUpdate(appProvider));
      
      // Preload year cache for current calendar system only (optimize for Android)
      // Don't preload other calendar systems to avoid blocking startup
      final calendarProvider = context.read<CalendarProvider>();
      final calendarSystem = appProvider.calendarSystem;
      
      // Get current year based on calendar system
      int currentYear;
      String calendarSystemForPreload = calendarSystem;
      if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
        final jalali = CalendarUtils.gregorianToJalali(calendarProvider.displayedMonth);
        currentYear = jalali.year;
        calendarSystemForPreload = 'solar'; // Both use same structure
      } else {
        currentYear = calendarProvider.displayedMonth.year;
      }
      
      // Preload only current calendar system in background (non-blocking)
      // Other calendar systems will be preloaded on-demand when user switches
      final yearCacheService = YearCacheService();
      unawaited(yearCacheService.preloadYears(currentYear, calendarSystem: calendarSystemForPreload));

      AppLogger.info('Splash screen: App initialized successfully');
    } catch (e) {
      AppLogger.error('Splash screen: Error initializing app', error: e);
      // Continue to app even if update fails
      try {
        await context.read<EventProvider>().initialize();
      } catch (e2) {
        AppLogger.error('Splash screen: Error initializing events provider', error: e2);
      }
    } finally {
      // Ensure minimum display time
      final elapsed = DateTime.now().difference(startTime);
      final remaining = minDisplayTime - elapsed;
      
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }
      
      if (mounted) {
        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  /// Check for app version update and show dialog if needed
  Future<void> _checkAppVersionUpdate(AppProvider appProvider) async {
    try {
      final updateService = UpdateService.instance;
      final appVersion = await updateService.checkAppVersion();
      
      if (appVersion != null && mounted) {
        // Wait a bit before showing dialog to ensure navigation is complete
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          _showUpdateDialog(context, appVersion, appProvider);
        }
      }
    } catch (e) {
      AppLogger.error('Splash screen: Error checking app version', error: e);
    }
  }

  /// Show update dialog based on update type
  void _showUpdateDialog(BuildContext context, AppVersion version, AppProvider appProvider) {
    final isPersian = appProvider.language == 'fa';
    final releaseNotes = version.getReleaseNotes(appProvider.language) ?? 
        (isPersian ? 'آپدیت جدید در دسترس است' : 'New update is available');

    showDialog(
      context: context,
      barrierDismissible: !version.isCritical,
      builder: (context) => AlertDialog(
        title: Text(
          isPersian ? 'آپدیت جدید' : 'New Update',
          style: isPersian
              ? FontHelper.getYekanBakh(
                  fontWeight: FontWeight.bold,
                )
              : FontHelper.getInter(
                  fontWeight: FontWeight.bold,
                ),
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
                } else {
                  AppLogger.error('Splash screen: Cannot launch URL: ${version.downloadUrl}');
                }
              }
              if (version.isCritical) {
                // For critical updates, keep dialog open until user updates
                return;
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              isPersian ? 'آپدیت' : 'Update',
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontWeight: FontWeight.bold,
                    )
                  : FontHelper.getInter(
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TBg.main(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section (74px height)
            SizedBox(
              height: 74,
              child: Stack(
                children: [
                  // Loading animation in top-right
                  Positioned(
                    right: 24,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: LoadingLinesAnimation(
                        strokeWidth: 3,
                        gap: 5,
                        activeColor: Theme.of(context).brightness == Brightness.dark 
                            ? ThemeColors.white 
                            : ThemeColors.black,
                        inactiveColor: Theme.of(context).brightness == Brightness.dark 
                            ? ThemeColors.white.withOpacity(0.2) 
                            : ThemeColors.black.withOpacity(0.2),
                        activeLineWidth: 24,
                        inactiveLineWidth: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Container - با ارتفاع بر اساس محتوا
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    _buildLogo(),

                    const SizedBox(height: 24),

                    // Text Content
                    Consumer<AppProvider>(
                      builder: (context, appProvider, child) {
                        // Detect language: if 'system', check device locale, otherwise use stored language
                        final deviceLocale = Localizations.localeOf(context);
                        final effectiveLanguage = appProvider.language == 'system' 
                            ? (deviceLocale.languageCode == 'fa' ? 'fa' : 'en')
                            : appProvider.language;
                        final isPersian = effectiveLanguage == 'fa';
                        
                        return ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 324),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Welcome Message
                              Text(
                                isPersian ? 'اپلیکیشن' : 'Welcome to',
                                style: isPersian
                                    ? FontHelper.getYekanBakh(
                                        fontSize: 12,
                                        height: 1.4,
                                        letterSpacing: -0.7 / 100 * 12,
                                        color: TCnt.neutralTertiary(context),
                                      )
                                    : FontHelper.getInter(
                                        fontSize: 12,
                                        height: 1.4,
                                        letterSpacing: -0.7 / 100 * 12,
                                        color: TCnt.neutralTertiary(context),
                                      ),
                              ),

                              const SizedBox(height: 4),

                              // App Name
                              Text(
                                isPersian ? 'میراث ایران' : 'Iranian Heritage',
                                style: isPersian
                                    ? FontHelper.getYekanBakh(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                        letterSpacing: -2.0 / 100 * 30,
                                        color: TCnt.neutralMain(context),
                                      )
                                    : FontHelper.getInter(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                        letterSpacing: -2.0 / 100 * 30,
                                        color: TCnt.neutralMain(context),
                                      ),
                              ),

                              const SizedBox(height: 4),

                              // Description
                              Text(
                                isPersian 
                                  ? 'اولین تقویم ملی و سنت‌های فرهنگی ایران، به همراه بزرگداشت کسانی که برای آزادی ما جنگیدند.'
                                  : 'The first national calendar and cultural traditions of Iran, along with honoring those who fought for our freedom.',
                                textAlign: TextAlign.center,
                                style: isPersian
                                    ? FontHelper.getYekanBakh(
                                        fontSize: 14,
                                        height: 1.6,
                                        letterSpacing: -0.7 / 100 * 14,
                                        color: TCnt.neutralSecond(context),
                                      )
                                    : FontHelper.getInter(
                                        fontSize: 14,
                                        height: 1.6,
                                        letterSpacing: -0.7 / 100 * 14,
                                        color: TCnt.neutralSecond(context),
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Image Section (Bottom)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  // Background Image
                  Image.asset(
                    'assets/images/adjective/splash-img.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image, size: 64, color: Colors.grey),
                        ),
                      );
                    },
                  ),

                  // Gradient Overlay - نرم و تدریجی
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 350,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              TBg.main(context),
                              TBg.main(context).withOpacity(0.98),
                              TBg.main(context).withOpacity(0.95),
                              TBg.main(context).withOpacity(0.88),
                              TBg.main(context).withOpacity(0.75),
                              TBg.main(context).withOpacity(0.55),
                              TBg.main(context).withOpacity(0.35),
                              TBg.main(context).withOpacity(0.18),
                              TBg.main(context).withOpacity(0.08),
                              TBg.main(context).withOpacity(0),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // Use logo_launcher.svg
    return SvgPicture.asset(
      AppIcons.logoLauncher,
      width: 60,
      height: 60,
    );
  }
}

// Helper function to run async code without awaiting
void unawaited(Future<void> future) {
  future.catchError((error) {
    debugPrint('Unawaited future error: $error');
  });
}
