import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zruri_flutter/core/routes/app_routes.dart';
import 'package:zruri_flutter/core/themes/app_theme.dart';
import 'package:zruri_flutter/firebase_options.dart';
import 'package:zruri_flutter/core/utils/constants.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  await GetStorage.init();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    return true;
  };
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: title,
      theme: AppTheme.defaultTheme,
      initialRoute: AppRoutes.initialRoute,
      unknownRoute: AppRoutes.unknownGetPage,
      getPages: AppRoutes.getPages,
      debugShowCheckedModeBanner: false,
    );
  }
}
