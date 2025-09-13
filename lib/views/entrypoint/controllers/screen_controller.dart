// lib/views/entrypoint/controllers/screen_controller.dart
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ScreenController extends GetxController {
  // Core navigation
  final RxInt currentIndex = 0.obs;
  final RxInt previousIndex = 0.obs;

  // UI state
  final RxBool isKeyboardVisible = false.obs;

  // Chat functionality
  final RxInt unreadMessagesCount = 0.obs;
  final RxBool isChatInitialized = false.obs;

  // Services
  final GetStorage _box = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream subscriptions
  late StreamSubscription<bool> _keyboardSubscription;
  StreamSubscription<QuerySnapshot>? _chatSubscription;
  StreamSubscription<User?>? _authSubscription;

  // Constants
  static const String _currentPageKey = 'currentPage';
  static const String _previousPageKey = 'previousPage';

  @override
  void onInit() {
    super.onInit();
    _initializeStorage();
    _initializeKeyboardListener();
    _initializeAuthListener();
  }

  @override
  void onClose() {
    _disposeSubscriptions();
    _cleanupStorage();
    super.onClose();
  }

  // === INITIALIZATION METHODS ===

  void _initializeStorage() {
    try {
      // Initialize storage with defaults
      _box.writeIfNull(_currentPageKey, 0);
      _box.writeIfNull(_previousPageKey, 0);

      // Restore last page if it's not the post ad page (index 2)
      final savedPage = _box.read(_currentPageKey) as int? ?? 0;
      if (savedPage != 2) {
        _changePage(savedPage, saveToStorage: false);
      }
    } catch (e) {
      log('Storage initialization error: $e');
      // Fallback to default values
      currentIndex.value = 0;
      previousIndex.value = 0;
    }
  }

  void _initializeKeyboardListener() {
    try {
      final keyboardVisibilityController = KeyboardVisibilityController();
      _keyboardSubscription = keyboardVisibilityController.onChange.listen(
        (isVisible) {
          log('Keyboard visibility changed: $isVisible');
          isKeyboardVisible.value = isVisible;
        },
        onError: (error) {
          log('Keyboard listener error: $error');
        },
      );
    } catch (e) {
      log('Keyboard listener initialization error: $e');
    }
  }

  void _initializeAuthListener() {
    _authSubscription = _auth.authStateChanges().listen(
      (user) {
        if (user != null) {
          _initializeChatListener();
        } else {
          _disposeChatListener();
          _resetChatState();
        }
      },
      onError: (error) {
        log('Auth state listener error: $error');
      },
    );
  }

  void _initializeChatListener() {
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      log('Cannot initialize chat listener: No authenticated user');
      return;
    }

    try {
      _chatSubscription = _firestore
          .collection('chatRooms')
          .where('participants', arrayContains: currentUserId)
          .snapshots()
          .listen(
            _handleChatRoomsUpdate,
            onError: (error) {
              log('Chat listener error: $error');
              isChatInitialized.value = false;
            },
          );

      isChatInitialized.value = true;
      log('Chat listener initialized successfully');
    } catch (e) {
      log('Chat listener initialization error: $e');
      isChatInitialized.value = false;
    }
  }

  // === NAVIGATION METHODS ===

  /// Navigate to a specific page
  void onChange(int index) {
    if (index < 0 || index >= 5) {
      log('Invalid page index: $index');
      return;
    }

    if (currentIndex.value == index) {
      log('Already on page $index');
      return;
    }

    _changePage(index);
  }

  /// Go back to the previous page
  void gotoPreviousPage() {
    final prevPage = _box.read(_previousPageKey) as int? ?? 0;

    // Don't go back to post ad page (index 2)
    if (prevPage == 2) {
      _changePage(0); // Go to home instead
    } else {
      _changePage(prevPage);
    }
  }

  /// Go to home page
  void goToHome() {
    _changePage(0);
  }

  /// Go to chats page
  void goToChats() {
    _changePage(2);
  }

  void _changePage(int index, {bool saveToStorage = true}) {
    try {
      if (saveToStorage) {
        // Save current page as previous before changing
        previousIndex.value = currentIndex.value;
        _box.write(_previousPageKey, currentIndex.value);
        _box.write(_currentPageKey, index);
      }

      currentIndex.value = index;

      // Reset unread count when navigating to chats
      if (index == 2) {
        resetUnreadCount();
      }

      log('Navigated to page $index');
    } catch (e) {
      log('Navigation error: $e');
    }
  }

  // === CHAT METHODS ===

  void _handleChatRoomsUpdate(QuerySnapshot snapshot) {
    try {
      final String currentUserId = _auth.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) return;

      int totalUnread = 0;

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final unreadCount =
              data['unreadCount'] as Map<String, dynamic>? ?? {};
          final userUnreadCount = unreadCount[currentUserId] as int? ?? 0;
          totalUnread += userUnreadCount;
        } catch (e) {
          log('Error processing chat room ${doc.id}: $e');
        }
      }

      unreadMessagesCount.value = totalUnread;
      log('Updated unread messages count: $totalUnread');
    } catch (e) {
      log('Error handling chat rooms update: $e');
    }
  }

  /// Reset unread count (called when user opens chat list)
  void resetUnreadCount() {
    // Don't reset the actual Firebase count here
    // This will be handled by ChatListController
    log('Reset unread count for UI');
  }

  void _resetChatState() {
    unreadMessagesCount.value = 0;
    isChatInitialized.value = false;
    log('Chat state reset');
  }

  // === UTILITY METHODS ===

  /// Check if currently on a specific page
  bool isCurrentPage(int index) => currentIndex.value == index;

  /// Check if chat functionality is available
  bool get isChatAvailable =>
      _auth.currentUser != null && isChatInitialized.value;

  /// Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // === CLEANUP METHODS ===

  void _disposeChatListener() {
    _chatSubscription?.cancel();
    _chatSubscription = null;
    log('Chat listener disposed');
  }

  void _disposeSubscriptions() {
    try {
      _keyboardSubscription.cancel();
      _disposeChatListener();
      _authSubscription?.cancel();
      log('All subscriptions disposed');
    } catch (e) {
      log('Error disposing subscriptions: $e');
    }
  }

  void _cleanupStorage() {
    try {
      // Only clear temporary data, keep navigation state
      // _box.erase(); // Don't erase everything
      log('Storage cleaned up');
    } catch (e) {
      log('Storage cleanup error: $e');
    }
  }

  // === DEBUG METHODS ===

  void debugPrintState() {
    log('''
ScreenController State:
- Current Index: ${currentIndex.value}
- Previous Index: ${previousIndex.value}
- Keyboard Visible: ${isKeyboardVisible.value}
- Unread Messages: ${unreadMessagesCount.value}
- Chat Initialized: ${isChatInitialized.value}
- User Authenticated: $isAuthenticated
- Current User ID: $currentUserId
    ''');
  }
}
