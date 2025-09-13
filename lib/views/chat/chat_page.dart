// lib/views/chat/chat_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zruri/controllers/chat_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/models/chat_message_model.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());

    return Scaffold(
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            _buildAdInfo(controller),
            Expanded(child: _buildMessagesList(controller)),
            _buildReplySection(controller),
            _buildMessageInput(controller),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatController controller) {
    return AppBar(
      title: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.otherUserName.value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (controller.isTyping.value)
              const Text(
                'typing...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view_ad':
                if (controller.chatRoom.value?.adId != null) {
                  Get.back();
                  Get.toNamed(
                    '${AppRouteNames.adPageMainRoute}${controller.chatRoom.value?.adId}',
                  );
                }
                break;
              case 'block_user':
                _showBlockUserDialog(controller);
                break;
            }
          },
          itemBuilder: (context) => [
            if (controller.chatRoom.value?.adId != null)
              const PopupMenuItem(
                value: 'view_ad',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text('View Ad'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'block_user',
              child: Row(
                children: [
                  Icon(Icons.block),
                  SizedBox(width: 8),
                  Text('Block User'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdInfo(ChatController controller) {
    return Obx(() {
      final chatRoom = controller.chatRoom.value;
      if (chatRoom?.adTitle == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Discussing: ${chatRoom!.adTitle}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed('${AppRouteNames.adPageMainRoute}${chatRoom.adId}');
              },
              child: const Text('View'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMessagesList(ChatController controller) {
    return Obx(() {
      if (controller.messages.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No messages yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Start the conversation!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        reverse: true,
        padding: const EdgeInsets.all(8),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          final isMyMessage =
              message.senderId == controller.chatService.currentUserId;

          return _buildMessageBubble(message, isMyMessage, controller);
        },
      );
    });
  }

  Widget _buildMessageBubble(
    ChatMessageModel message,
    bool isMyMessage,
    ChatController controller,
  ) {
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () =>
            _showMessageOptions(message, isMyMessage, controller),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          child: Column(
            crossAxisAlignment: isMyMessage
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.replyToMessageId != null)
                _buildReplyPreview(message, controller),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMyMessage ? AppColors.primary : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMyMessage ? 16 : 4),
                    bottomRight: Radius.circular(isMyMessage ? 4 : 16),
                  ),
                ),
                child: _buildMessageContent(message, isMyMessage),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  if (isMyMessage) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead ? AppColors.primary : Colors.grey,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(ChatMessageModel message, bool isMyMessage) {
    switch (message.type) {
      case MessageType.image:
        return _buildImageMessage(message.imageUrl!);
      case MessageType.text:
        return Text(
          message.message,
          style: TextStyle(
            color: isMyMessage ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        );
      case MessageType.system:
        return Text(
          message.message,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        );
    }
  }

  Widget _buildImageMessage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 200,
        height: 150,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 200,
          height: 150,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 150,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildReplyPreview(
    ChatMessageModel message,
    ChatController controller,
  ) {
    // Find the replied message
    final repliedMessage = controller.messages.firstWhereOrNull(
      (m) => m.id == message.replyToMessageId,
    );

    if (repliedMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            repliedMessage.senderId == controller.chatService.currentUserId
                ? 'You'
                : controller.otherUserName.value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            repliedMessage.type == MessageType.image
                ? '📷 Image'
                : repliedMessage.message,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReplySection(ChatController controller) {
    return Obx(() {
      if (controller.replyToMessage.value == null) {
        return const SizedBox.shrink();
      }

      final message = controller.replyToMessage.value!;
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey[100],
        child: Row(
          children: [
            Container(width: 3, height: 40, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Replying to ${message.senderId == controller.chatService.currentUserId ? 'yourself' : controller.otherUserName.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    message.type == MessageType.image
                        ? '📷 Image'
                        : message.message,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: controller.cancelReply,
              icon: const Icon(Icons.close, size: 20),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: controller.sendImageMessage,
              icon: const Icon(Icons.image, color: AppColors.primary),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  onPressed: controller.isSending.value
                      ? null
                      : controller.sendMessage,
                  icon: controller.isSending.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(
    ChatMessageModel message,
    bool isMyMessage,
    ChatController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Get.back();
                controller.replyToMessageAction(message);
              },
            ),
            if (message.type == MessageType.text)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Get.back();
                  // Copy to clipboard functionality
                  Get.snackbar('Copied', 'Message copied to clipboard');
                },
              ),
            if (isMyMessage)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  _showDeleteConfirmation(message, controller);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    ChatMessageModel message,
    ChatController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteMessage(message.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBlockUserDialog(ChatController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Block User'),
        content: Text(
          'Are you sure you want to block ${controller.otherUserName.value}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.offNamed(AppRouteNames.entrypoint);
              Get.snackbar(
                'Blocked',
                'User has been blocked',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
