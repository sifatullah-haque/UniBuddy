import 'package:diu/Constant/firebase_options.dart';

import 'package:diu/auth/login/isLogin.dart';
import 'package:diu/pages/home_page/Idea/Idea.dart';
import 'package:diu/pages/home_page/Support/Support.dart';
import 'package:diu/pages/home_page/Volunteer/volunteer.dart';
import 'package:diu/pages/home_page/pure_home_page/buttonNavigator.dart';
import 'package:diu/pages/home_page/pure_home_page/home_page.dart';
import 'package:diu/pages/main_navigation.dart';
import 'package:diu/willDeleteLater/test.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(428, 926.3),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
          theme: ThemeData(
            fontFamily: "Poppins",
          ),
          debugShowCheckedModeBanner: false,
          home: MainNavigation()),
    );
  }
}
