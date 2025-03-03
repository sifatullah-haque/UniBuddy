import 'package:cloud_firestore/cloud_firestore.dart';

class firestoreService {
  final CollectionReference VolunteerCollection =
      FirebaseFirestore.instance.collection('Volunteer');
  final CollectionReference IdeaCollection =
      FirebaseFirestore.instance.collection("Ideas");

  final CollectionReference SupportCollection =
      FirebaseFirestore.instance.collection("Supports");

  //create: add a new volunteer
  Future<void> addVolunteer(
    String name,
    String email,
    String batch,
    String roll,
    String reg,
    String semester,
    String phone,
  ) {
    return VolunteerCollection.add({
      'name': name,
      'email': email,
      'batch': batch,
      'roll': roll,
      'reg': reg,
      'semester': semester,
      'phone': phone,
    });
  }

  //create: add a new idea

  Future<void> addIdea(
    String name,
    String batch,
    String roll,
    String idea,
    String mobile,
  ) {
    return IdeaCollection.add({
      'name': name,
      'mobile': mobile,
      'batch': batch,
      'roll': roll,
      'idea': idea,
    });
  }

  Future<void> addSupport(
    String name,
    String phone,
    String batch,
    String roll,
    String message,
  ) {
    return SupportCollection.add({
      'name': name,
      'mobile': phone,
      'batch': batch,
      'roll': roll,
      'message': message,
    });
  }
}
