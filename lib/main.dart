import 'package:diu/Constant/firebase_options.dart';
import 'package:diu/auth/login/isLogin.dart';
import 'package:diu/auth/login/login.dart';
import 'package:diu/pages/home_page/Bus_Schedule/busSchedule.dart';
import 'package:diu/pages/home_page/Cafeteria/cafeteria.dart';
import 'package:diu/pages/home_page/Class_Schedule/classSchedule.dart';
import 'package:diu/pages/home_page/Emergency/emergency.dart';
import 'package:diu/pages/home_page/Lost_Item/lostItem.dart';
import 'package:diu/pages/home_page/askBot/askBot.dart';
import 'package:diu/pages/home_page/chat/chat.dart';
import 'package:diu/pages/home_page/pure_home_page/home_page.dart';
import 'package:diu/pages/main_navigation.dart';
import 'package:diu/pages/notifications/notifications.dart';
import 'package:diu/utils/firebase_project_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

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
          home: IsLogin()),
    );
  }
}
