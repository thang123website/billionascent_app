import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:martfury/core/app_config.dart';
import 'package:martfury/src/view/screen/splash_screen.dart';
import 'package:martfury/src/utils/restart_widget.dart';
import 'package:martfury/src/theme/app_theme.dart';
import 'package:martfury/src/service/language_service.dart';
import 'package:martfury/src/service/notification_service.dart';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
    if (kDebugMode) {
      print('✅ Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Firebase initialization failed: $e');
      print('📝 Note: Add google-services.json (Android) and GoogleService-Info.plist (iOS) to enable FCM');
    }
  }

  // Initialize app configuration
  await AppConfig.load();
  await EasyLocalization.ensureInitialized();

  // Initialize FCM push notifications only if Firebase is available
  if (firebaseInitialized) {
    try {
      await NotificationService.initialize();
      if (kDebugMode) {
        print('✅ FCM notifications initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ FCM notifications initialization failed: $e');
      }
    }
  } else {
    if (kDebugMode) {
      print('⚠️ Skipping FCM initialization - Firebase not available');
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
        Locale('ar'), // Arabic (RTL)
        Locale('bn'), // Bengali
        Locale('es'), // Spanish
        Locale('fr'), // French
        Locale('hi'), // Hindi
        Locale('id'), // Indonesian
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const RestartWidget(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ui.TextDirection _textDirection = ui.TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    _loadTextDirection();
  }

  Future<void> _loadTextDirection() async {
    final textDirection = await LanguageService.getTextDirection();
    if (mounted) {
      setState(() {
        _textDirection = textDirection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _textDirection,
      child: GetMaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Follows system theme preference
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
