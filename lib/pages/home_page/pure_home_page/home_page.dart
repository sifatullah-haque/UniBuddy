import 'package:diu/Constant/color_is.dart';
import 'package:diu/pages/home_page/askBot/askBot.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'gridview_with_icons.dart';
import 'icon_and_event_scroll.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Coloris.backgroundColor,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            _buildHeader(),
            Positioned(
              top: _calculateContainerTopPosition(context),
              left: _calculateContainerSidePosition(context),
              right: _calculateContainerSidePosition(context),
              child: _buildRedContainer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 220.h,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0),
            ),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xff6686F6), Color(0xff60BBEF)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  _buildAvatarAndUserInfo(),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
        const GridviewWithIcons(),
        SizedBox(
          height: 20.h,
        ),
        const IconsAndEventScroll(),
      ],
    );
  }

  Widget _buildAvatarAndUserInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 45.0,
          backgroundImage: AssetImage("assets/avatars/sifat.jpg"),
        ),
        SizedBox(width: 20.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello ! ",
              style: TextStyle(
                color: Coloris.white,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 5.sp),
            Text(
              "Sifatullah Haque Sajeeb",
              style: TextStyle(
                color: Coloris.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 5.sp),
            const Text(
              "D-78(A)",
              style: TextStyle(
                color: Coloris.white,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildRedContainer() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AskBot()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Coloris.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        alignment: Alignment.center,
        height: 55.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              color: Coloris.primary_color,
              size: 25.0,
            ),
            const SizedBox(
              width: 10.0,
            ),
            const Text(
              "Ask Bot",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                  color: Coloris.primary_color),
            )
          ],
        ),
      ),
    );
  }

  double _calculateContainerTopPosition(BuildContext context) {
    return ScreenUtil().screenHeight * 0.20;
  }

  double _calculateContainerSidePosition(BuildContext context) {
    // Calculate the side padding to center the container with 56% width
    // This means the container will take up 44% of screen width (100% - 2*28%)
    return ScreenUtil().screenWidth * 0.28;
  }
}
