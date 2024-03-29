import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseStorageService {
  final storageRef = FirebaseStorage.instance.ref();

  Future<String?> getDownloadUrl({required String path}) async {
    try {
      return await storageRef.child(path).getDownloadURL();
    } catch (e) {
      FirebaseCrashlytics.instance
          .recordFlutterFatalError(FlutterErrorDetails(exception: e));
      return null;
    }
  }
}
