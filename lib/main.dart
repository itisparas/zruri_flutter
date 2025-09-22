import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
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
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/core/routes/app_routes.dart';
import 'package:zruri/core/services/notification_service.dart';
import 'package:zruri/core/themes/app_theme.dart';
import 'package:zruri/core/utils/constants.dart';
import 'package:zruri/firebase_options.dart';
import 'package:uni_links/uni_links.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

// Stream subscription for deep links
StreamSubscription? _linkSubscription;

// Handle incoming deep links
void _handleIncomingLinks() {
  if (!kIsWeb) {
    // Handle app links while the app is already started
    _linkSubscription = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          debugPrint('Got deep link: $uri');
          _handleDeepLink(uri.toString());
        }
      },
      onError: (Object err) {
        debugPrint('Error handling deep link: $err');
      },
    );
  }
}

// Handle the initial link if the app was launched from a deep link
Future<void> _handleInitialLink() async {
  if (!kIsWeb) {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        debugPrint('Initial deep link: $initialUri');
        // Delay navigation slightly to ensure app is fully initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleDeepLink(initialUri.toString());
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to get initial link: $e');
    } on FormatException catch (e) {
      debugPrint('Malformed initial link: $e');
    }
  }
}

// Parse and navigate based on the deep link
void _handleDeepLink(String link) {
  final uri = Uri.parse(link);
  debugPrint(
    'Handling deep link - path: ${uri.path}, query: ${uri.queryParameters}',
  );

  // Handle different deep link patterns
  // Example patterns:
  // https://yourdomain.com/products/123
  // https://yourdomain.com/profile?userId=456
  // yourapp://products/123

  if (uri.path.isEmpty || uri.path == '/') {
    // Handle root path
    Get.offAllNamed(AppRoutes.initialRoute);
    return;
  }

  // Remove leading slash for GetX route matching
  String path = uri.path.startsWith('/') ? uri.path : '/${uri.path}';

  // Check if the route exists in your AppRoutes
  // You might need to adjust this based on your route structure
  if (_isValidRoute(path)) {
    // Navigate with query parameters if any
    if (uri.queryParameters.isNotEmpty) {
      Get.toNamed(path, parameters: uri.queryParameters);
    } else {
      Get.toNamed(path);
    }
  } else {
    // Handle specific deep link patterns
    _handleCustomDeepLinkPatterns(uri);
  }
}

// Check if a route is valid in your app
bool _isValidRoute(String path) {
  // Check against your defined routes in AppRoutes
  // This is a simplified example - adjust based on your actual routes
  final validRoutes = AppRoutes.getPages.map((page) => page.name).toList();
  return validRoutes.contains(path);
}

// Handle custom deep link patterns that don't directly match routes
void _handleCustomDeepLinkPatterns(Uri uri) {
  final pathSegments = uri.pathSegments;

  if (pathSegments.isEmpty) {
    Get.offAllNamed(AppRoutes.initialRoute);
    return;
  }

  // Example: Handle /products/123 -> Navigate to product details with ID
  if (pathSegments.length >= 2 && pathSegments[0] == 'listing') {
    final productId = pathSegments[1];
    // Navigate to product details page with the product ID
    // Adjust the route name based on your AppRoutes
    Get.toNamed('${AppRouteNames.adPageMainRoute}$productId');
    return;
  }

  // Example: Handle /profile?userId=456
  if (pathSegments[0] == 'profile' &&
      uri.queryParameters.containsKey('userId')) {
    final userId = uri.queryParameters['userId'];
    // Navigate to user profile with the user ID
    Get.toNamed('/userProfile', parameters: {'userId': userId!});
    return;
  }

  // Add more custom patterns as needed

  // Fallback to home if no pattern matches
  debugPrint('No matching route for deep link: ${uri.toString()}');
  Get.offAllNamed(AppRoutes.initialRoute);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Normal portrait mode
  ]);

  try {
    // Initialize Firebase
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    auth = FirebaseAuth.instanceFor(app: app);

    // Initialize Firebase Messaging
    Get.put(NotificationService());
    // Setup Firebase Messaging after Firebase is initialized
    Get.find<NotificationService>().setupFirebaseMessaging();

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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize deep linking
    _handleInitialLink(); // Handle deep link if app was launched from one
    _handleIncomingLinks(); // Listen for deep links while app is running
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      FirebaseAnalytics.instance.logEvent(
        name: 'app_inactive',
        parameters: {'app_inactive': 'true'},
      );
    }

    // Handle app lifecycle changes if needed for deep linking
    if (state == AppLifecycleState.resumed) {
      FirebaseAnalytics.instance.logAppOpen();
    }
  }

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
