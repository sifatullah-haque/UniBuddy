class LostItemModel {
  final String id;
  final String title;
  final String location;
  final String contact;
  final String description;
  final DateTime createdAt;
  final bool isFound;
  final String userId;
  final String lostBy; // New field
  final String batchName; // New field
  final DateTime dateLost; // New field
  final String? imageBase64; // Add this field instead of imageUrl

  LostItemModel({
    required this.id,
    required this.title,
    required this.location,
    required this.contact,
    required this.description,
    required this.createdAt,
    required this.userId,
    required this.lostBy,
    required this.batchName,
    required this.dateLost,
    this.imageBase64, // Replace imageUrl with this
    this.isFound = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'contact': contact,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isFound': isFound,
      'userId': userId,
      'lostBy': lostBy,
      'batchName': batchName,
      'dateLost': dateLost.toIso8601String(),
      'imageBase64': imageBase64, // Replace imageUrl with this
    };
  }

  factory LostItemModel.fromMap(String id, Map<String, dynamic> map) {
    return LostItemModel(
      id: id,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      contact: map['contact'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      isFound: map['isFound'] ?? false,
      userId: map['userId'] ?? '',
      lostBy: map['lostBy'] ?? '',
      batchName: map['batchName'] ?? '',
      dateLost: DateTime.parse(map['dateLost'] as String),
      imageBase64: map['imageBase64'], // Replace imageUrl with this
    );
  }
}
