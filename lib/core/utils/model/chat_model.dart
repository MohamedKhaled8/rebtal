import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final String userId;
  final String ownerId;
  final String chaletId;
  final String chaletName;
  final String userName;
  final String ownerName;
  final DateTime createdAt;
  final DateTime lastMessageTime;
  final bool isActive;
  final String status; // 'pending', 'approved', 'completed'

  const ChatModel({
    required this.chatId,
    required this.userId,
    required this.ownerId,
    required this.chaletId,
    required this.chaletName,
    required this.userName,
    required this.ownerName,
    required this.createdAt,
    required this.lastMessageTime,
    required this.isActive,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'chatId': chatId,
      'userId': userId,
      'chaletId': chaletId,
      'chaletName': chaletName,
      'userName': userName,
      'ownerName': ownerName,
      // Store Firestore Timestamps to make queries and ordering work correctly
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'isActive': isActive,
      'status': status,
    };

    if (ownerId.trim().isNotEmpty) {
      map['ownerId'] = ownerId;
      map['merchantId'] = ownerId; // alias
    }

    return map;
  }

  factory ChatModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return ChatModel(
      chatId: documentId ?? map['chatId'] ?? '',
      userId: map['userId'] ?? '',
      ownerId: map['ownerId'] ?? map['merchantId'] ?? '',
      chaletId: map['chaletId'] ?? '',
      chaletName: map['chaletName'] ?? '',
      userName: map['userName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      createdAt: parseDate(map['createdAt']),
      lastMessageTime: parseDate(map['lastMessageTime']),
      isActive: map['isActive'] ?? true,
      status: map['status'] ?? 'pending',
    );
  }
}

class MessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return MessageModel(
      messageId: map['messageId'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: parseDate(map['timestamp']),
      isRead: map['isRead'] ?? false,
    );
  }
}
