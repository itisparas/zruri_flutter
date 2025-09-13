// lib/controllers/chat_list_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zruri/models/chat_room_model.dart';

class ChatListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxMap<String, Map<String, dynamic>> userInfoCache =
      <String, Map<String, dynamic>>{}.obs;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _listenToChatRooms();
  }

  void _listenToChatRooms() {
    if (currentUserId.isEmpty) return;

    _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen((snapshot) {
          chatRooms.value = snapshot.docs
              .map((doc) => ChatRoomModel.fromFirestore(doc))
              .toList();

          // Preload user info for all participants
          _preloadUserInfo();
          isLoading.value = false;
        });
  }

  void _preloadUserInfo() {
    Set<String> userIds = {};
    for (var chatRoom in chatRooms) {
      userIds.addAll(chatRoom.participants);
    }
    userIds.remove(currentUserId);

    for (String userId in userIds) {
      if (!userInfoCache.containsKey(userId)) {
        _loadUserInfo(userId);
      }
    }
  }

  Future<void> _loadUserInfo(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        userInfoCache[userId] = userDoc.data() as Map<String, dynamic>;
      } else {
        userInfoCache[userId] = {'displayname': 'Unknown User'};
      }
    } catch (e) {
      userInfoCache[userId] = {'displayname': 'Unknown User'};
    }
  }

  Map<String, dynamic> getUserInfo(String userId) {
    return userInfoCache[userId] ?? {'displayname': 'Loading...'};
  }

  Future<void> refreshChats() async {
    isLoading.value = true;
    // The stream will automatically update
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;
  }

  Future<void> deleteChat(String chatRoomId) async {
    try {
      // Delete all messages in the chat room
      QuerySnapshot messages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat room
      batch.delete(_firestore.collection('chatRooms').doc(chatRoomId));

      await batch.commit();

      Get.snackbar('Success', 'Chat deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete chat');
    }
  }
}
