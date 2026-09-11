import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/app_colors.dart';
import 'data/repositories/progress_repository.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/main_menu/main_menu_screen.dart';
import 'screens/level_select/level_select_screen.dart';
import 'screens/game/game_screen.dart';
import 'screens/game_over/game_over_screen.dart';
import 'screens/settings/settings_screen.dart';

import 'core/services/notification_service.dart';

class ArrowPuzzleApp extends StatefulWidget {
  const ArrowPuzzleApp({super.key});

  @override
  State<ArrowPuzzleApp> createState() => _ArrowPuzzleAppState();
}

class _ArrowPuzzleAppState extends State<ArrowPuzzleApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cancel any pending reminders upon opening the app
    NotificationService.instance.cancelAllReminders();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // User left the game -> Schedule smart re-engagement reminders
      final progress = context.read<ProgressRepository>();
      NotificationService.instance.scheduleSmartReminders(
        currentLevel: progress.currentLevel,
        streakDays: progress.streakDays,
        notificationsEnabled: progress.notificationsEnabled,
      );
    } else if (state == AppLifecycleState.resumed) {
      // User returned -> Cancel reminders to avoid notifications while playing
      NotificationService.instance.cancelAllReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressRepository>();

    final themeMode = progress.themeMode;
    final systemBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && systemBrightness == Brightness.dark);
    AppColors.updateTheme(isDark);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    return MaterialApp(
      title: 'Arrow Escape',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData.light().textTheme,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData.dark().textTheme,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/menu': (_) => const MainMenuScreen(),
        '/levels': (_) => const LevelSelectScreen(),
        '/game': (_) => const GameScreen(),
        '/game_over': (_) => const GameOverScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
