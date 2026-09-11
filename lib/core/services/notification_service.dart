import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message received: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'arrow_escape_channel';
  static const String _channelName = 'Arrow Escape Reminders';
  static const String _channelDesc =
      'Daily puzzle challenges, streak alerts, and game updates';

  // Notification IDs
  static const int _idStreakSaver = 1001;
  static const int _idDailyChallenge = 1002;
  static const int _idInactivity = 1003;
  static const int _idFcmForeground = 2001;

  bool _isInitialized = false;

  /// Initialize Local Notifications, Timezones, and Firebase Messaging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Timezone database initialization
      tz.initializeTimeZones();

      // 2. Local Notifications Setup
      const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create High-Priority Notification Channel for Android
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
      }

      // 3. FCM Setup
      await _initializeFCM();

      _isInitialized = true;
      debugPrint('NotificationService successfully initialized');
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  /// Initialize Firebase Cloud Messaging listeners & topics
  Future<void> _initializeFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Set background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Subscribe to global topic for console campaigns
      await messaging.subscribeToTopic('all_players');

      // Foreground message listener: Display heads-up banner via Local Notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          showInstantNotification(
            id: _idFcmForeground + Random().nextInt(1000),
            title: notification.title ?? 'Arrow Escape 🏹',
            body: notification.body ?? 'New puzzle challenge is here!',
          );
        }
      });

      // Handle notification click when app opened from terminated/background state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened from FCM notification: ${message.data}');
      });

      // Log FCM Token for debug / targeting
      if (kDebugMode) {
        final token = await messaging.getToken();
        debugPrint('FCM Registration Token: $token');
      }
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  /// Request Notification Permission (Polite, Android 13+ & iOS)
  Future<bool> requestPermission() async {
    try {
      // 1. Android 13+ (API 33+)
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted != null && granted) return true;
      }

      // 2. FCM / iOS Permission
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Notification permission error: $e');
      return false;
    }
  }

  /// Schedule Smart Local Reminders when the app moves to background
  Future<void> scheduleSmartReminders({
    required int currentLevel,
    required int streakDays,
    required bool notificationsEnabled,
  }) async {
    if (!_isInitialized || !notificationsEnabled) {
      await cancelAllReminders();
      return;
    }

    try {
      // Cancel previous scheduled reminders so we don't stack duplicates
      await cancelAllReminders();

      final now = tz.TZDateTime.now(tz.local);

      // ── 1. STREAK SAVER REMINDER (Today 8:30 PM) ──────────────────────────
      // Triggers if user has an active streak and today is still before 8:30 PM
      var streakSchedule = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        20, // 8:30 PM
        30,
      );

      if (streakSchedule.isBefore(now)) {
        // Schedule for tomorrow 8:30 PM
        streakSchedule = streakSchedule.add(const Duration(days: 1));
      }

      final effectiveStreak = max(streakDays, 1);
      final streakMessage = _pickStreakMessage(effectiveStreak);

      await _localNotifications.zonedSchedule(
        _idStreakSaver,
        streakMessage.title,
        streakMessage.body,
        streakSchedule,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // ── 2. STUCK LEVEL / DAILY BRAIN WORKOUT (Tomorrow 7:30 PM) ───────────
      var nextDaySchedule = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        19, // 7:30 PM
        30,
      ).add(const Duration(days: 1));

      final levelMessage = _pickLevelMessage(currentLevel);

      await _localNotifications.zonedSchedule(
        _idDailyChallenge,
        levelMessage.title,
        levelMessage.body,
        nextDaySchedule,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // ── 3. INACTIVITY COMEBACK HOOK (Day 3 at 6:00 PM) ─────────────────────
      final day3Schedule = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        18, // 6:00 PM
        0,
      ).add(const Duration(days: 3));

      final inactivityMessage = _pickInactivityMessage();

      await _localNotifications.zonedSchedule(
        _idInactivity,
        inactivityMessage.title,
        inactivityMessage.body,
        day3Schedule,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Smart notifications scheduled successfully.');
    } catch (e) {
      debugPrint('Error scheduling smart reminders: $e');
    }
  }

  /// Cancel all pending reminders (called when app enters foreground)
  Future<void> cancelAllReminders() async {
    try {
      await _localNotifications.cancel(_idStreakSaver);
      await _localNotifications.cancel(_idDailyChallenge);
      await _localNotifications.cancel(_idInactivity);
    } catch (e) {
      debugPrint('Error cancelling reminders: $e');
    }
  }

  /// Display an immediate notification (e.g. for FCM foreground messages)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await _localNotifications.show(
        id,
        title,
        body,
        _notificationDetails(),
      );
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('User tapped notification: ${response.payload}');
  }

  // ── High-Converting, Irresistible Notification Messages ───────────────────

  _NotificationText _pickStreakMessage(int days) {
    final templates = [
      _NotificationText(
        '🔥 Don\'t let your $days-Day Streak burn out!',
        'Just 1 quick puzzle keeps your flame alive. Escape the arrows before midnight!',
      ),
      _NotificationText(
        '⚡ Your $days-Day Streak is on the line!',
        'You\'ve worked hard to build this streak! Take 90 seconds to save it now.',
      ),
      _NotificationText(
        '🔥 Keep the fire burning ($days Days)!',
        'A quick 2-minute puzzle break is waiting. Can you keep the streak alive?',
      ),
    ];
    return templates[Random().nextInt(templates.length)];
  }

  _NotificationText _pickLevelMessage(int level) {
    final templates = [
      _NotificationText(
        '🏹 Level $level thinks it beat you...',
        'That tricky arrow grid is still unsolved! One fresh look is all you need.',
      ),
      _NotificationText(
        '💡 A fresh eye solves Level $level!',
        'Take a 2-minute brain break and discover the secret escape path. Tap to solve!',
      ),
      _NotificationText(
        '🎯 Unfinished business at Level $level!',
        'One arrow is holding the whole puzzle together. Can you spot which one moves first?',
      ),
      _NotificationText(
        '🧠 2-Minute Daily Brain Relaxer',
        'Clear your mind and guide the arrows out. Pure puzzle satisfaction awaits!',
      ),
    ];
    return templates[Random().nextInt(templates.length)];
  }

  _NotificationText _pickInactivityMessage() {
    final templates = [
      _NotificationText(
        '🧩 The arrows miss your sharp moves!',
        'Tangled arrows are waiting for you! Can you clear 3 levels in under 3 minutes?',
      ),
      _NotificationText(
        '🎁 Your Comeback Hints are waiting!',
        'It\'s puzzle time! Jump back in and test your arrow-escaping skills today.',
      ),
      _NotificationText(
        '✨ Need a quick mental refresh?',
        'Escape the daily stress with satisfying arrow sliding. Tap to play!',
      ),
    ];
    return templates[Random().nextInt(templates.length)];
  }
}

class _NotificationText {
  final String title;
  final String body;
  const _NotificationText(this.title, this.body);
}
