import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/app_config.dart';
import 'config/theme_colors.dart';
import 'config/theme_roles.dart';
import 'providers/app_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/event_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize local storage
  await LocalStorageService.init();
  
  runApp(const IranianHeritageCalendarApp());
}

class IranianHeritageCalendarApp extends StatelessWidget {
  const IranianHeritageCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // تنظیم status bar برای شفاف بودن و همرنگ بودن با background
          final Brightness brightness;
          if (appProvider.themeMode == ThemeMode.system) {
            // Use system brightness when in system mode
            brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
          } else {
            brightness = appProvider.themeMode == ThemeMode.dark 
                ? Brightness.dark 
                : Brightness.light;
          }
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SystemChrome.setSystemUIOverlayStyle(
              const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent, // شفاف برای Android
                systemNavigationBarColor: Colors.transparent, // navigation bar هم شفاف
              ).copyWith(
                statusBarIconBrightness: brightness == Brightness.dark 
                    ? Brightness.light 
                    : Brightness.dark, // رنگ آیکون‌های status bar
                statusBarBrightness: brightness == Brightness.dark 
                    ? Brightness.dark 
                    : Brightness.light, // برای iOS
                systemNavigationBarIconBrightness: brightness == Brightness.dark 
                    ? Brightness.light 
                    : Brightness.dark,
              ),
            );
          });
          
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: const ColorScheme.light(
                primary: ThemeColors.primary500,
                secondary: ThemeColors.secondary500,
                surface: ThemeColors.surface,
                error: ThemeColors.error,
                onPrimary: ThemeColors.white,
                onSecondary: ThemeColors.white,
                onSurface: ThemeColors.gray900,
                onError: ThemeColors.white,
              ),
              scaffoldBackgroundColor: LightBg.home,
              bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: ThemeColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(
                primary: ThemeColors.primary500,
                secondary: ThemeColors.secondary500,
                surface: Color(0xFF2D2D2D),
                error: ThemeColors.error,
                onPrimary: ThemeColors.white,
                onSecondary: ThemeColors.white,
                onSurface: ThemeColors.white,
                onError: ThemeColors.white,
              ),
              scaffoldBackgroundColor: DarkBg.home,
              bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: Color(0xFF2D2D2D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
            themeMode: appProvider.themeMode,
            locale: appProvider.locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('fa', 'IR'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
