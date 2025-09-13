// lib/models/chat_room_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, int> unreadCount;
  final String? adId;
  final String? adTitle;
  final DateTime createdAt;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.unreadCount,
    this.adId,
    this.adTitle,
    required this.createdAt,
  });

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      adId: data['adId'],
      adTitle: data['adTitle'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'adId': adId,
      'adTitle': adTitle,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
