// lib/views/chats/chat_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zruri/controllers/chat_list_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/models/chat_room_model.dart';
import 'package:zruri/views/entrypoint/controllers/navigation_controller.dart';
import 'package:zruri/views/entrypoint/controllers/screen_controller.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});
  final ScreenController screenController = Get.put(
    ScreenController(),
    permanent: true,
  );

  final NavigationController navigationController =
      Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    final ChatListController controller = Get.put(ChatListController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            navigationController.goBack();
          },
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.chatRooms.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshChats,
          child: ListView.builder(
            itemCount: controller.chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = controller.chatRooms[index];
              return _buildChatRoomTile(chatRoom, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with sellers by\nvisiting product listings',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              navigationController.navigateToPage(1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomTile(
    ChatRoomModel chatRoom,
    ChatListController controller,
  ) {
    final otherUserId = chatRoom.participants.firstWhere(
      (id) => id != controller.currentUserId,
    );
    final unreadCount = chatRoom.unreadCount[controller.currentUserId] ?? 0;
    final isUnread = unreadCount > 0;

    return Obx(() {
      final otherUser = controller.getUserInfo(otherUserId);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withOpacity(0.3)
                : Colors.grey[200]!,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  otherUser['displayname']?.substring(0, 1).toUpperCase() ??
                      'U',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (isUnread)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  otherUser['displayname'] ?? 'Unknown User',
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                _formatTime(chatRoom.lastMessageTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (chatRoom.adTitle != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chatRoom.adTitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  if (chatRoom.lastMessageSenderId == controller.currentUserId)
                    Icon(Icons.reply, size: 14, color: Colors.grey[600]),
                  Expanded(
                    child: Text(
                      chatRoom.lastMessage.isEmpty
                          ? 'No messages yet'
                          : chatRoom.lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          onTap: () {
            Get.toNamed(
              '/chat',
              arguments: {
                'sellerId': otherUserId,
                'sellerName': otherUser['displayname'] ?? 'User',
                'adId': chatRoom.adId,
                'adTitle': chatRoom.adTitle,
                'existingChatRoomId': chatRoom.id,
              },
            );
          },
          onLongPress: () {
            _showChatOptions(chatRoom, controller);
          },
        ),
      );
    });
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  void _showChatOptions(ChatRoomModel chatRoom, ChatListController controller) {
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
            if (chatRoom.adId != null)
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View Ad'),
                onTap: () {
                  Get.toNamed(
                    '${AppRouteNames.adPageMainRoute}${chatRoom?.adId}',
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Chat',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(chatRoom, controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    ChatRoomModel chatRoom,
    ChatListController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
          'Are you sure you want to delete this conversation?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteChat(chatRoom.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
