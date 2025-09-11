import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Configure Firebase Messaging
  Future<void> setupFirebaseMessaging() async {
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

      FirebaseAnalytics.instance.logEvent(
        name: 'app_notification_authorisation_status',
        parameters: {
          'authorisation_status': settings.authorizationStatus.toString(),
        },
      );

      // Get the token - this will automatically handle both Android and iOS
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token first (works on both platforms)
        await _getFCMToken();

        // For iOS, we need to ensure the APNS token is available
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          await _getAPNSTokenWithRetry();
        }

        // Handle token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          print('Refreshed FCM Token: $newToken');
          _saveTokenToFirestore(newToken);
        });

        // Listen to auth state changes to manage tokens
        _auth.authStateChanges().listen((User? user) {
          if (user != null) {
            // User signed in, save/update token
            _getFCMToken();
          } else {
            // User signed out, remove token
            _removeTokenFromFirestore();
          }
        });
      }

      // Handle incoming messages when the app is in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        _handleForegroundMessage(message);

        if (message.notification != null) {
          print(
            'Message also contained a notification: ${message.notification}',
          );
        }
      });

      // Handle background messages (when app is in background but not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message clicked!');
        _handleNotificationNavigation(message);
      });

      // Check if the app was opened from a notification
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        print('App opened from terminated state via notification');
        _handleNotificationNavigation(initialMessage);
      }
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  // Get FCM token and save to Firestore
  Future<void> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _saveTokenToFirestore(token);
      } else {
        print('FCM Token is null, will retry when available');
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  // Save token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        print('No authenticated user, cannot save token');
        return;
      }

      // Get user's current location and other details from their profile
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      await _firestore.collection('user_tokens').doc(user.uid).set({
        'userId': user.uid,
        'fcmToken': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        // Include location data for location-based notifications
        'location': userData?['location'] ?? {},
      }, SetOptions(merge: true));

      // Also update the user's main document with the latest token
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });

      print('Token saved to Firestore successfully');
    } catch (e) {
      print('Error saving token to Firestore: $e');
    }
  }

  // Remove token from Firestore when user signs out
  Future<void> _removeTokenFromFirestore() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('user_tokens').doc(user.uid).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Token marked as inactive in Firestore');
    } catch (e) {
      print('Error removing token from Firestore: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification or update UI
    // You can use flutter_local_notifications package for this
    _showLocalNotification(message);
  }

  // Show local notification (you'll need flutter_local_notifications package)
  void _showLocalNotification(RemoteMessage message) {
    // Implementation depends on your local notification setup
    // This is a placeholder
    print('Showing local notification for: ${message.notification?.title}');
  }

  // Get APNS token with retry logic for iOS
  Future<void> _getAPNSTokenWithRetry({int maxAttempts = 3}) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          print('APNS Token retrieved: $apnsToken');
          return;
        } else {
          print('APNS Token is null on attempt $attempt');
        }
      } catch (e) {
        print('Attempt $attempt - Error getting APNS token: $e');
      }

      if (attempt < maxAttempts) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    print(
      'Could not retrieve APNS token after $maxAttempts attempts. '
      'This might be normal on simulator or if push notifications are not properly configured.',
    );
  }

  // Handle navigation from notification
  void _handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;

    if (data.containsKey('route')) {
      final route = data['route'];
      final arguments = data['arguments'];

      if (arguments != null) {
        Get.toNamed(route, arguments: arguments);
      } else {
        Get.toNamed(route);
      }
    } else if (data.containsKey('chatId')) {
      // Handle chat notification
      Get.toNamed('/chat', arguments: {'chatId': data['chatId']});
    }
  }

  // Update user location for location-based notifications
  Future<void> updateUserLocation({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      final locationData = {
        'city': city,
        'country': country,
        'coordinates': {'latitude': latitude, 'longitude': longitude},
        'location': {'city': city, 'country': country},
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      };

      // Update user document
      await _firestore.collection('users').doc(user.uid).update(locationData);

      // Update token document for location-based notifications
      await _firestore
          .collection('user_tokens')
          .doc(user.uid)
          .update(locationData);

      print('User location updated successfully');
    } catch (e) {
      print('Error updating user location: $e');
    }
  }
}
