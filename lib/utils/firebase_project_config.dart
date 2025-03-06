import 'package:firebase_core/firebase_core.dart';

void checkFirebaseConfig() {
  FirebaseOptions options = Firebase.app().options;
  print('Connected Firebase Project Details:');
  print('Project ID: ${options.projectId}');
  print('API Key: ${options.apiKey}');
  print('App ID: ${options.appId}');
  print('Messaging Sender ID: ${options.messagingSenderId}');
}
