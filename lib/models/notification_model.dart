import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'found_item', 'emergency', etc.
  final String? relatedItemId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.relatedItemId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'timestamp':
          timestamp, // Send DateTime directly, Firestore will convert it
      'isRead': isRead,
      'type': type,
      'relatedItemId': relatedItemId,
    };
  }

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      // Convert Firestore Timestamp to DateTime
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? '',
      relatedItemId: map['relatedItemId'],
    );
  }
}
