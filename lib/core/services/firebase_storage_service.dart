import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseStorageService {
  final storageRef = FirebaseStorage.instance.ref();

  Future<String?> getDownloadUrl({required String path}) async {
    try {
      var downloadurl = await storageRef.child(path).getDownloadURL();
      return downloadurl;
    } catch (e) {
      FirebaseCrashlytics.instance
          .recordFlutterFatalError(FlutterErrorDetails(exception: e));
      return null;
    }
  }

  Future<String> uploadImage(
      {required File file, required String filePath}) async {
    try {
      return await (await storageRef.child(filePath).putFile(file))
          .ref
          .getDownloadURL();
    } catch (e) {
      FirebaseCrashlytics.instance
          .recordFlutterFatalError(FlutterErrorDetails(exception: e));
      rethrow;
    }
  }
}
