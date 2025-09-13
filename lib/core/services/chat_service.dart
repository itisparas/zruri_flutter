// lib/core/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zruri/models/chat_message_model.dart';
import 'package:zruri/models/chat_room_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Create or get existing chat room
  Future<String> createOrGetChatRoom({
    required String otherUserId,
    String? adId,
    String? adTitle,
  }) async {
    try {
      // Create a consistent chat room ID
      List<String> ids = [currentUserId, otherUserId];
      ids.sort();
      String chatRoomId = ids.join('_');

      DocumentSnapshot chatRoom = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (!chatRoom.exists) {
        // Create new chat room
        ChatRoomModel newChatRoom = ChatRoomModel(
          id: chatRoomId,
          participants: [currentUserId, otherUserId],
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          lastMessageSenderId: '',
          unreadCount: {currentUserId: 0, otherUserId: 0},
          adId: adId,
          adTitle: adTitle,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .set(newChatRoom.toFirestore());
      }

      return chatRoomId;
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }

  // Send message
  Future<void> sendMessage({
    required String chatRoomId,
    required String receiverId,
    required String message,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? replyToMessageId,
  }) async {
    try {
      ChatMessageModel newMessage = ChatMessageModel(
        id: '',
        senderId: currentUserId,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        type: type,
        imageUrl: imageUrl,
        replyToMessageId: replyToMessageId,
      );

      // Add message to subcollection
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toFirestore());

      // Update chat room with last message
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': type == MessageType.image ? '📷 Image' : message,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'lastMessageSenderId': currentUserId,
        'unreadCount.$receiverId': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages stream
  Stream<List<ChatMessageModel>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId, String senderId) async {
    try {
      WriteBatch batch = _firestore.batch();

      QuerySnapshot unreadMessages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isEqualTo: senderId)
          .where('isRead', isEqualTo: false)
          .get();

      for (DocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Reset unread count
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'unreadCount.$currentUserId': 0,
      });
    } catch (e) {
      print('Failed to mark messages as read: $e');
    }
  }

  // Get chat room info
  Future<ChatRoomModel?> getChatRoom(String chatRoomId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (doc.exists) {
        return ChatRoomModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete message
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}
