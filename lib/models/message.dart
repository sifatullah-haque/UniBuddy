import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String senderUserId; // Add this field
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.senderName,
    required this.senderUserId, // Add this parameter
    required this.text,
    required this.timestamp,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Message(
      senderId: data['senderId'],
      senderName: data['senderName'],
      senderUserId: data['senderUserId'], // Add this field
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderUserId': senderUserId, // Add this field
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
