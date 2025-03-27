// import 'package:diu/auth/login/login.dart';
// import 'package:diu/auth/register/register.dart';
// import 'package:flutter/material.dart';

// class AuthPage extends StatefulWidget {
//   const AuthPage({super.key});

//   @override
//   State<AuthPage> createState() => _AuthPageState();
// }

// class _AuthPageState extends State<AuthPage> {
//   bool showLogin = true;

//   void toggleScreen(bool showLogin, [String? message]) {
//     setState(() {
//       this.showLogin = showLogin;
//     });

//     if (message != null && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (showLogin) {
//       return LoginPage(
//         onRegisterClick: () => toggleScreen(false),
//       );
//     } else {
//       return RegisterPage(
//         onRegistrationComplete: () => toggleScreen(
//           true,
//           'Please verify your email to login',
//         ),
//       );
//     }
//   }
// }
