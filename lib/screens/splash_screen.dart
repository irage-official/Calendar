import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_icons.dart';
import '../config/theme_colors.dart';
import '../widgets/loading_lines_animation.dart';
import '../config/theme_roles.dart';
import '../providers/app_provider.dart';
import '../providers/event_provider.dart';
import '../providers/calendar_provider.dart';
import '../utils/logger.dart';
import '../services/year_cache_service.dart';
import '../utils/calendar_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

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
      await context.read<EventProvider>().initialize();
      
      // Get current language from AppProvider
      final appProvider = context.read<AppProvider>();
      final currentLanguage = appProvider.language;
      // Normalize language: 'fa' -> 'fa', everything else -> 'en'
      final normalizedLanguage = currentLanguage == 'fa' ? 'fa' : 'en';
      
      // Preload year cache for both calendar systems in background
      final calendarProvider = context.read<CalendarProvider>();
      final calendarSystem = appProvider.calendarSystem;
      
      // Get current year based on calendar system
      int currentYear;
      if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
        final jalali = CalendarUtils.gregorianToJalali(calendarProvider.displayedMonth);
        currentYear = jalali.year;
      } else {
        currentYear = calendarProvider.displayedMonth.year;
      }
      
      // Preload 10 years before and after for current calendar system
      final yearCacheService = YearCacheService();
      unawaited(yearCacheService.preloadYears(currentYear, calendarSystem: calendarSystem));
      
      // Also preload for the other calendar system in background
      // Preload the other calendar systems for quick switching
      if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
        // If using solar/shahanshahi, also preload gregorian
        final otherCurrentYear = DateTime.now().year;
        unawaited(yearCacheService.preloadYears(otherCurrentYear, calendarSystem: 'gregorian'));
      } else {
        // If using gregorian, also preload solar
        final jalali = CalendarUtils.gregorianToJalali(DateTime.now());
        unawaited(yearCacheService.preloadYears(jalali.year, calendarSystem: 'solar'));
      }

      AppLogger.info('Splash screen: App initialized successfully');
    } catch (e) {
      AppLogger.error('Splash screen: Error initializing app', error: e);
      // Continue to app even if update fails
    } finally {
      // Ensure minimum display time
      final elapsed = DateTime.now().difference(startTime);
      final remaining = minDisplayTime - elapsed;
      
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
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
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  letterSpacing: -0.7 / 100 * 12,
                                  color: TCnt.neutralTertiary(context),
                                  fontFamily: isPersian ? 'Vazir' : 'Inter',
                                ),
                              ),

                              const SizedBox(height: 4),

                              // App Name
                              Text(
                                isPersian ? 'میراث ایران' : 'Iranian Heritage',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  letterSpacing: -2.0 / 100 * 30,
                                  color: TCnt.neutralMain(context),
                                  fontFamily: isPersian ? 'Vazir' : 'Inter',
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Description
                              Text(
                                isPersian 
                                  ? 'اولین تقویم ملی و سنت‌های فرهنگی ایران، به همراه بزرگداشت کسانی که برای آزادی ما جنگیدند.'
                                  : 'The first national calendar and cultural traditions of Iran, along with honoring those who fought for our freedom.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  letterSpacing: -0.7 / 100 * 14,
                                  color: TCnt.neutralSecond(context),
                                  fontFamily: isPersian ? 'Vazir' : 'Inter',
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
                    'assets/images/splash-img.png',
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

                  // Gradient Overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 150,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              TBg.main(context),
                              TBg.main(context),
                              TBg.main(context).withOpacity(0.9),
                              TBg.main(context).withOpacity(0.7),
                              TBg.main(context).withOpacity(0.4),
                              TBg.main(context).withOpacity(0),
                            ],
                            stops: const [0.0, 0.15, 0.3, 0.5, 0.7, 1.0],
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
    // Try PNG first, fallback to SVG
    return Image.asset(
      'assets/images/logo_2.png',
      width: 60,
      height: 60,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to SVG
        return SvgPicture.asset(
          AppIcons.logo_2,
          width: 60,
          height: 60,
        );
      },
    );
  }
}

// Helper function to run async code without awaiting
void unawaited(Future<void> future) {
  future.catchError((error) {
    debugPrint('Unawaited future error: $error');
  });
}
