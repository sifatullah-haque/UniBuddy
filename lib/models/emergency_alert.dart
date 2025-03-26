import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyAlert {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime timestamp;
  final String userId;

  EmergencyAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'userId': userId,
    };
  }

  static EmergencyAlert fromMap(String id, Map<String, dynamic> map) {
    return EmergencyAlert(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }
}
