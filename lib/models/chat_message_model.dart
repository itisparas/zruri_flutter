// lib/models/chat_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;
  final bool isRead;
  final String? replyToMessageId;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.type = MessageType.text,
    this.imageUrl,
    this.isRead = false,
    this.replyToMessageId,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => MessageType.text,
      ),
      imageUrl: data['imageUrl'],
      isRead: data['isRead'] ?? false,
      replyToMessageId: data['replyToMessageId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'replyToMessageId': replyToMessageId,
    };
  }
}

enum MessageType { text, image, system }
