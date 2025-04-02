import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String senderUserId;
  final String text;
  final DateTime timestamp;
  final bool isEdited;

  Message({
    required this.senderId,
    required this.senderName,
    required this.senderUserId,
    required this.text,
    required this.timestamp,
    this.isEdited = false,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'],
      senderName: data['senderName'],
      senderUserId: data['senderUserId'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isEdited: data['isEdited'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderUserId': senderUserId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isEdited': isEdited,
    };
  }
}
