import 'dart:ui';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zruri/core/routes/app_routes.dart';
import 'package:zruri/core/themes/app_theme.dart';
import 'package:zruri/core/utils/constants.dart';
import 'package:zruri/firebase_options.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

// Configure Firebase Messaging
Future<void> _setupFirebaseMessaging() async {
  try {
    // Request permission for notifications
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get the token - this will automatically handle both Android and iOS
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // For iOS, we need to ensure the APNS token is available
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Request APNS token explicitly
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        print('APNS Token: $apnsToken');
      }

      // Get the FCM token
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

      // Handle token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('Refreshed FCM Token: $newToken');
        // TODO: Update the token on your server
      });
    }

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  } catch (e) {
    print('Error initializing Firebase Messaging: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    auth = FirebaseAuth.instanceFor(app: app);

    // Initialize Firebase Messaging
    await _setupFirebaseMessaging();

    // Initialize Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Activate App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.debug,
    );
  } catch (error, stackTrace) {
    // Handle any initialization errors
    if (error is FirebaseException) {
      debugPrint('Firebase initialization error: ${error.message}');
    } else {
      debugPrint('Error during initialization: $error');
    }
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  }
  // Run the app
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    return GetMaterialApp(
      title: title,
      theme: AppTheme.defaultTheme,
      initialRoute: AppRoutes.initialRoute,
      getPages: AppRoutes.getPages,
      debugShowCheckedModeBanner: false,
    );
  }
}
