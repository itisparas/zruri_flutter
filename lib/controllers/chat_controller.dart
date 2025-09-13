// lib/controllers/chat_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zruri/core/services/chat_service.dart';
import 'package:zruri/core/services/firebase_storage_service.dart';
import 'package:zruri/models/chat_message_model.dart';
import 'package:zruri/models/chat_room_model.dart';

class ChatController extends GetxController {
  final ChatService chatService = ChatService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Observables
  final RxString chatRoomId = ''.obs;
  final RxString otherUserId = ''.obs;
  final RxString otherUserName = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isTyping = false.obs;
  final Rx<ChatRoomModel?> chatRoom = Rx<ChatRoomModel?>(null);
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final Rx<ChatMessageModel?> replyToMessage = Rx<ChatMessageModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  void _initializeChat() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      otherUserId.value = arguments['sellerId'] ?? '';
      otherUserName.value = arguments['sellerName'] ?? 'User';

      _createChatRoom(adId: arguments['adId'], adTitle: arguments['adTitle']);
    }
  }

  Future<void> _createChatRoom({String? adId, String? adTitle}) async {
    try {
      isLoading.value = true;
      chatRoomId.value = await chatService.createOrGetChatRoom(
        otherUserId: otherUserId.value,
        adId: adId,
        adTitle: adTitle,
      );

      // Load chat room info
      chatRoom.value = await chatService.getChatRoom(chatRoomId.value);

      // Listen to messages
      _listenToMessages();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create chat room');
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToMessages() {
    chatService.getMessages(chatRoomId.value).listen((messageList) {
      messages.value = messageList;
      _markMessagesAsRead();
    });
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    try {
      isSending.value = true;
      await chatService.sendMessage(
        chatRoomId: chatRoomId.value,
        receiverId: otherUserId.value,
        message: messageController.text.trim(),
        replyToMessageId: replyToMessage.value?.id,
      );

      messageController.clear();
      replyToMessage.value = null;
      _scrollToBottom();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendImageMessage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        isSending.value = true;

        // Upload image to Firebase Storage
        String? imageUrl = await _storageService.uploadImage(
          file: File(image.path),
          filePath:
              'chat_images/${DateTime.now().millisecondsSinceEpoch}.${image.path.split('.').last}',
        );

        if (imageUrl != null) {
          await chatService.sendMessage(
            chatRoomId: chatRoomId.value,
            receiverId: otherUserId.value,
            message: '',
            type: MessageType.image,
            imageUrl: imageUrl,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send image');
    } finally {
      isSending.value = false;
    }
  }

  void replyToMessageAction(ChatMessageModel message) {
    replyToMessage.value = message;
  }

  void cancelReply() {
    replyToMessage.value = null;
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await chatService.deleteMessage(chatRoomId.value, messageId);
      Get.snackbar('Success', 'Message deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete message');
    }
  }

  void _markMessagesAsRead() {
    if (messages.isNotEmpty) {
      chatService.markMessagesAsRead(chatRoomId.value, otherUserId.value);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
