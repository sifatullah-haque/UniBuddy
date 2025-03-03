import 'package:diu/auth/auth_page.dart';
import 'package:diu/pages/home_page/pure_home_page/home_page.dart';
import 'package:diu/willDeleteLater/home.dart';
import 'package:diu/willDeleteLater/test.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IsLogin extends StatelessWidget {
  const IsLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePageTest();
          } else {
            return AuthPage();
          }
        },
      ),
    );
  }
}
