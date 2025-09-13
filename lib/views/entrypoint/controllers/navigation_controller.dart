// lib/views/entrypoint/controllers/navigation_controller.dart
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/routes/app_route_names.dart';

enum NavigationState { home, categories, chats, profile, postAd }

class NavigationController extends GetxController {
  // Core State
  final Rx<NavigationState> currentState = NavigationState.home.obs;
  final RxInt currentIndex = 0.obs;
  final RxList<NavigationState> navigationHistory = <NavigationState>[].obs;

  // UI State
  final RxBool isKeyboardVisible = false.obs;
  final RxBool isNavigating = false.obs;
  final RxBool canPop = false.obs;

  // Chat State
  final RxInt unreadMessagesCount = 0.obs;
  final RxBool isChatEnabled = false.obs;

  final RxBool isNavigatingBack = false.obs;
  final RxInt previousIndex = 0.obs;

  // Services
  final GetStorage _storage = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Subscriptions
  StreamSubscription<bool>? _keyboardSubscription;
  StreamSubscription<QuerySnapshot>? _chatSubscription;
  StreamSubscription<User?>? _authSubscription;

  // Constants
  static const String _currentStateKey = 'current_navigation_state';
  static const String _historyKey = 'navigation_history';

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _disposeSubscriptions();
    super.onClose();
  }

  // === INITIALIZATION ===

  void _initializeController() {
    _initializeStorage();
    _initializeKeyboardListener();
    _initializeAuthListener();
    _restoreNavigationState();
  }

  void _initializeStorage() {
    _storage.writeIfNull(_currentStateKey, NavigationState.home.index);
    _storage.writeIfNull(_historyKey, <int>[]);
  }

  void _initializeKeyboardListener() {
    final keyboardController = KeyboardVisibilityController();
    _keyboardSubscription = keyboardController.onChange.listen((isVisible) {
      isKeyboardVisible.value = isVisible;
      log('Keyboard visibility: $isVisible');
    }, onError: (error) => log('Keyboard listener error: $error'));
  }

  void _initializeAuthListener() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _initializeChatListener();
      } else {
        _resetChatState();
      }
    }, onError: (error) => log('Auth listener error: $error'));
  }

  void _initializeChatListener() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _chatSubscription = _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .listen(
          (snapshot) => _updateUnreadCount(snapshot, userId),
          onError: (error) => log('Chat listener error: $error'),
        );

    isChatEnabled.value = true;
  }

  void _updateUnreadCount(QuerySnapshot snapshot, String userId) {
    int totalUnread = 0;

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final unreadCount = data['unreadCount'] as Map<String, dynamic>? ?? {};
        totalUnread += (unreadCount[userId] as int? ?? 0);
      } catch (e) {
        log('Error processing unread count: $e');
      }
    }

    unreadMessagesCount.value = totalUnread;
  }

  void _restoreNavigationState() {
    try {
      final savedStateIndex = _storage.read(_currentStateKey) as int? ?? 0;
      final savedHistory = _storage.read(_historyKey) as List<dynamic>? ?? [];

      currentState.value = NavigationState.values[savedStateIndex];
      currentIndex.value = savedStateIndex;

      navigationHistory.value = savedHistory
          .map((index) => NavigationState.values[index as int])
          .toList();

      _updateCanPop();
    } catch (e) {
      log('Error restoring navigation state: $e');
      _resetToHome();
    }
  }

  // === NAVIGATION METHODS ===

  Future<void> navigateToPage(int index) async {
    if (index < 0 || index >= NavigationState.values.length) return;
    if (currentIndex.value == index) return;

    isNavigating.value = true;
    HapticFeedback.lightImpact();

    try {
      final newState = NavigationState.values[index];
      await _performNavigation(newState, index);
    } catch (e) {
      log('Navigation error: $e');
      Get.snackbar('Error', 'Navigation failed');
    } finally {
      isNavigating.value = false;
      Future.delayed(const Duration(milliseconds: 500), () {
        isNavigatingBack.value = false;
      });
    }
  }

  Future<void> _performNavigation(NavigationState newState, int index) async {
    // Add current state to history if it's different
    if (currentState.value != newState &&
        !navigationHistory.contains(currentState.value)) {
      navigationHistory.add(currentState.value);

      // Limit history size
      if (navigationHistory.length > 10) {
        navigationHistory.removeAt(0);
      }
    }

    // Update state
    currentState.value = newState;
    currentIndex.value = index;

    // Save to storage
    _saveNavigationState();

    // Handle specific navigation logic
    await _handleStateSpecificLogic(newState);

    // Update UI state
    _updateCanPop();

    log('Navigated to: $newState (index: $index)');
  }

  Future<void> _handleStateSpecificLogic(NavigationState state) async {
    switch (state) {
      case NavigationState.chats:
        if (isChatEnabled.value) {
          // Mark messages as read when opening chats
          Future.delayed(const Duration(milliseconds: 500), () {
            // This will be handled by ChatListController
          });
        }
        break;
      case NavigationState.home:
        // Refresh home data if needed
        break;
      case NavigationState.categories:
        // Preload categories if needed
        break;
      case NavigationState.profile:
        // Check auth state
        break;
      default:
        break;
    }
  }

  void showPostAdOptions() {
    HapticFeedback.mediumImpact();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Create New Listing',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to sell your item',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            _buildPostOption(
              icon: Icons.camera_alt,
              title: 'Take Photo & Sell',
              subtitle: 'Quick listing with camera',
              onTap: () {
                Get.back();
                _navigateToPostAd(useCamera: true);
              },
            ),
            const SizedBox(height: 16),
            _buildPostOption(
              icon: Icons.edit,
              title: 'Create Detailed Listing',
              subtitle: 'Add photos and descriptions',
              onTap: () {
                Get.back();
                _navigateToPostAd(useCamera: false);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPostOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _navigateToPostAd({required bool useCamera}) {
    if (useCamera) {
      Get.toNamed(AppRouteNames.postAdFormPage);
    } else {
      Get.toNamed(AppRouteNames.postAdFormPage);
    }
  }

  // === NAVIGATION HISTORY ===

  // Update the goBack method
  bool goBack() {
    if (!canPop.value || navigationHistory.isEmpty) return false;

    isNavigatingBack.value = true;
    previousIndex.value = currentIndex.value;

    HapticFeedback.lightImpact();
    final previousState = navigationHistory.removeLast();
    final prevIndex = NavigationState.values.indexOf(previousState);

    currentState.value = previousState;
    currentIndex.value = prevIndex;

    _saveNavigationState();
    _updateCanPop();

    log('Navigated back to: $previousState');
    return true;
  }

  void _updateCanPop() {
    canPop.value =
        navigationHistory.isNotEmpty &&
        currentState.value != NavigationState.home;
  }

  void clearHistory() {
    navigationHistory.clear();
    _updateCanPop();
    _saveNavigationState();
  }

  void _resetToHome() {
    currentState.value = NavigationState.home;
    currentIndex.value = 0;
    navigationHistory.clear();
    _updateCanPop();
    _saveNavigationState();
  }

  // === UTILITY METHODS ===

  void _saveNavigationState() {
    _storage.write(_currentStateKey, currentState.value.index);
    _storage.write(
      _historyKey,
      navigationHistory.map((state) => state.index).toList(),
    );
  }

  bool get isAuthenticated => _auth.currentUser != null;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // === CLEANUP ===

  void _resetChatState() {
    unreadMessagesCount.value = 0;
    isChatEnabled.value = false;
    _chatSubscription?.cancel();
    _chatSubscription = null;
  }

  void _disposeSubscriptions() {
    _keyboardSubscription?.cancel();
    _chatSubscription?.cancel();
    _authSubscription?.cancel();
  }
}
