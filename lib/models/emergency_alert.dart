import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyAlert {
  final String id;
  final String title;
  final String description;
  final String location;
  final String contact; // Add new contact field
  final DateTime timestamp;
  final String userId;
  final String userEmail;

  EmergencyAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.userId,
    this.userEmail = 'Unknown',
    this.contact = '', // Initialize with default empty string
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'contact': contact, // Include contact in map
      'timestamp': timestamp,
      'userId': userId,
      'userEmail': userEmail,
    };
  }

  factory EmergencyAlert.fromMap(String id, Map<String, dynamic> map) {
    return EmergencyAlert(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      contact: map['contact'] ?? '', // Parse contact from map
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? 'Unknown',
    );
  }
}
