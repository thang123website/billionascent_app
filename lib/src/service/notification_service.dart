import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:martfury/src/model/device_token.dart';
import 'package:martfury/src/service/device_token_service.dart';
import 'package:martfury/src/service/profile_service.dart';
import 'package:martfury/src/service/token_service.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final DeviceTokenService _deviceTokenService = DeviceTokenService();
  static final ProfileService _profileService = ProfileService();
  static String? _deviceToken;

  /// Initialize FCM Push Notifications
  static Future<void> initialize() async {
    try {
      // Initialize local notifications (always available)
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_notification');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      // Check if Firebase is available before initializing FCM
      if (!_isFirebaseAvailable()) {
        if (kDebugMode) {
          print('⚠️ Firebase not available, skipping FCM initialization');
        }
        return;
      }

      // Request FCM permissions
      final messaging = FirebaseMessaging.instance;

      // Request permission for iOS and configure APNS
      if (Platform.isIOS) {
        if (kDebugMode) {
          print('🍎 Requesting iOS notification permissions...');
        }

        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
          criticalAlert: false,
          announcement: false,
        );

        if (kDebugMode) {
          print('📱 iOS Permission Status: ${settings.authorizationStatus}');
          print('   Alert: ${settings.alert}');
          print('   Badge: ${settings.badge}');
          print('   Sound: ${settings.sound}');
        }

        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          if (kDebugMode) {
            print('❌ Notification permissions denied by user');
            print('📝 User needs to enable notifications in iOS Settings');
          }
        }

        // Set APNS token for iOS (helps with FCM token generation)
        try {
          await messaging.setAutoInitEnabled(true);
          if (kDebugMode) {
            print('✅ FCM auto-init enabled for iOS');
          }

          // Force APNS token registration
          await messaging.setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

          if (kDebugMode) {
            print('✅ iOS foreground notification options set');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ FCM auto-init setup: $e');
          }
        }
      } else {
        // Android permissions
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Set up FCM message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Listen for token refresh
      messaging.onTokenRefresh.listen((token) {
        if (kDebugMode) {
          print('FCM token refreshed: $token');
        }
        _deviceToken = token;
        _sendTokenToServer(token);
      });

      // Get and register initial token
      await registerDeviceToken();

    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
    }
  }

  /// Check if Firebase is available and initialized
  static bool _isFirebaseAvailable() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get FCM token and register with API
  static Future<void> registerDeviceToken() async {
    try {
      String? token = await _getFCMToken();
      if (token != null) {
        _deviceToken = token;
        await _sendTokenToServer(token);
      } else {
        if (kDebugMode) {
          print('⚠️ No FCM token available');
          if (Platform.isIOS) {
            print('💡 This is normal on iOS simulators');
            print('📱 For push notifications, test on a physical iOS device');
          }
        }

        // Generate a fallback token for development/testing
        if (kDebugMode) {
          final fallbackToken = await _generateFallbackToken();
          if (fallbackToken != null) {
            _deviceToken = fallbackToken;
            await _sendTokenToServer(fallbackToken);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering device token: $e');
      }
    }
  }

  /// Generate a fallback token for development when FCM is not available
  static Future<String?> _generateFallbackToken() async {
    try {
      final deviceInfo = await _getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final fallbackToken = 'dev_${platform}_${deviceInfo['deviceId']}_${packageInfo.version}';

      if (kDebugMode) {
        print('🔧 Generated fallback token for development: ${fallbackToken.substring(0, 20)}...');
        print('⚠️ WARNING: This is NOT a real FCM token!');
        print('📝 Real FCM tokens are needed for push notifications to work');
        if (Platform.isAndroid) {
          print('🔧 To fix: Add Android app to Firebase project and download real google-services.json');
        } else {
          print('📱 To fix: Test on a physical iOS device for real FCM tokens');
        }
      }

      return fallbackToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error generating fallback token: $e');
      }
      return null;
    }
  }

  /// Get FCM token from Firebase
  static Future<String?> _getFCMToken() async {
    try {
      if (!_isFirebaseAvailable()) {
        if (kDebugMode) {
          print('⚠️ Firebase not available, cannot get FCM token');
        }
        return null;
      }

      final messaging = FirebaseMessaging.instance;

      if (kDebugMode) {
        print('🔍 Attempting to get FCM token...');
        print('📱 Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
      }

      // For iOS, ensure APNS token is available first
      if (Platform.isIOS) {
        try {
          if (kDebugMode) {
            print('🍎 iOS detected - checking APNS token...');
          }

          // Wait for APNS token to be available
          final apnsToken = await messaging.getAPNSToken();
          if (apnsToken == null) {
            if (kDebugMode) {
              print('⚠️ APNS token not available yet, waiting 5 seconds...');
            }
            // Wait longer for physical devices
            await Future.delayed(const Duration(seconds: 5));
            final retryApnsToken = await messaging.getAPNSToken();
            if (retryApnsToken == null) {
              if (kDebugMode) {
                print('❌ APNS token still not available after retry');
                print('🔧 This indicates an iOS configuration issue');
                print('📝 Check: iOS app permissions, Firebase iOS setup, APNS certificates');
              }
              // For physical devices, this is a real problem
              return null;
            } else {
              if (kDebugMode) {
                print('✅ APNS token obtained on retry: ${retryApnsToken.substring(0, 20)}...');
              }
            }
          } else {
            if (kDebugMode) {
              print('✅ APNS token available: ${apnsToken.substring(0, 20)}...');
            }
          }
        } catch (apnsError) {
          if (kDebugMode) {
            print('❌ APNS token error: $apnsError');
            print('🔧 This suggests iOS Firebase configuration issues');
          }
          return null;
        }
      }

      // Get FCM token with timeout
      if (kDebugMode) {
        print('🔄 Requesting FCM token from Firebase...');
      }

      final String? token = await messaging.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) {
            print('⏰ FCM token request timed out after 10 seconds');
          }
          return null;
        },
      );

      if (kDebugMode) {
        if (token != null) {
          print('✅ FCM token obtained successfully!');
          print('📱 Token: ${token.substring(0, 30)}...');
          print('📏 Token length: ${token.length} characters');
        } else {
          print('❌ FCM token is null - this indicates a configuration problem');
          print('🔧 Possible causes:');
          print('   - iOS: Missing APNS configuration or certificates');
          print('   - Android: Incomplete google-services.json');
          print('   - Firebase: App not properly registered');
        }
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting FCM token: $e');
        print('🔧 Error details: ${e.runtimeType}');
        if (e.toString().contains('apns-token-not-set')) {
          print('💡 APNS token not set - this should not happen on physical iOS devices');
        } else if (e.toString().contains('network')) {
          print('💡 Network error - check internet connection');
        } else if (e.toString().contains('permission')) {
          print('💡 Permission error - check notification permissions');
        }
      }
      return null;
    }
  }

  /// Check if token is a real FCM token or fallback
  static bool _isRealFCMToken(String token) {
    return !token.startsWith('dev_');
  }

  /// Send device token to server
  static Future<void> _sendTokenToServer(String token) async {
    try {
      if (kDebugMode) {
        print('🔄 Starting device token registration...');
        print('📱 Token: $token');

        if (_isRealFCMToken(token)) {
          print('✅ Real FCM token detected - push notifications will work!');
        } else {
          print('⚠️ Fallback development token - push notifications will NOT work');
          print('📝 See FIX_REAL_FCM_TOKENS.md for solution');
        }
      }

      // Get device information
      final deviceInfo = await _getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();

      if (kDebugMode) {
        print('📱 Device Info: $deviceInfo');
        print('📱 App Version: ${packageInfo.version}');
      }

      // Get user information if logged in
      int? userId;
      String userType = 'guest';

      try {
        final authToken = await TokenService.getToken();
        if (authToken != null && authToken.isNotEmpty) {
          if (kDebugMode) {
            print('🔐 Auth token found, getting user profile...');
          }
          final userProfile = await _profileService.getProfile();
          userId = userProfile['id'];
          userType = 'customer';
          if (kDebugMode) {
            print('👤 User ID: $userId, Type: $userType');
          }
        } else {
          if (kDebugMode) {
            print('👤 No auth token, registering as guest');
          }
        }
      } catch (e) {
        // User not logged in, continue as guest
        if (kDebugMode) {
          print('👤 User not logged in, registering as guest: $e');
        }
      }

      // Create device token object
      final deviceToken = DeviceToken(
        token: token,
        platform: Platform.isAndroid ? 'android' : 'ios',
        appVersion: packageInfo.version,
        deviceId: deviceInfo['deviceId'],
        userType: userType,
        userId: userId,
      );

      if (kDebugMode) {
        print('📤 Sending device token to API: ${deviceToken.toJson()}');
      }

      // Send to API
      await _deviceTokenService.registerDeviceToken(deviceToken);

      if (kDebugMode) {
        print('✅ Device token registered successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending token to server: $e');
      }
    }
  }

  /// Get device information
  static Future<Map<String, String?>> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return {
        'deviceId': androidInfo.id,
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
      };
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return {
        'deviceId': iosInfo.identifierForVendor,
        'model': iosInfo.model,
        'manufacturer': 'Apple',
      };
    }
    
    return {'deviceId': null, 'model': null, 'manufacturer': null};
  }

  /// Handle FCM messages when app is in foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Show local notification for foreground messages
    await _showLocalNotification(message);
  }

  /// Handle FCM messages when app is opened from notification
  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    if (kDebugMode) {
      print('Message opened app: ${message.messageId}');
      print('Data: ${message.data}');
    }

    // Handle navigation based on message data
    _handleNotificationNavigation(message.data);
  }



  /// Show local notification from FCM message
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification navigation
  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('Handling notification navigation with data: $data');
    }
    // Add your navigation logic here based on the data
  }

  /// Handle notification tap
  static void _handleNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }

    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _handleNotificationNavigation(data);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing notification payload: $e');
        }
      }
    }
  }

  /// Unregister device token (call on logout)
  static Future<void> unregisterDeviceToken() async {
    try {
      if (_deviceToken != null) {
        await _deviceTokenService.unregisterDeviceToken(_deviceToken!);
        _deviceToken = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unregistering device token: $e');
      }
    }
  }


}
