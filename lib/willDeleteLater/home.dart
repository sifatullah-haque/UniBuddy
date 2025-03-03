import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/pages/home_page/pure_home_page/gridview_with_icons.dart';
import 'package:diu/pages/home_page/pure_home_page/icon_and_event_scroll.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePageTest extends StatefulWidget {
  HomePageTest({Key? key}) : super(key: key);

  @override
  State<HomePageTest> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageTest> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Coloris.backgroundColor,
        //
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    _buildHeader(userData['firstName'], userData['lastName']),
                    Positioned(
                      top: _calculateContainerTopPosition(context),
                      left: _calculateContainerMiddlePosition(context),
                      right: _calculateContainerMiddlePosition(context),
                      child: _buildRedContainer(),
                    ),
                  ],
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Center(
              child: Text("Error Loading Data. Try Again"),
            );
          },
        ));
  }

  Widget _buildHeader(String firstName, String lastName) {
    return Column(
      children: [
        Container(
          height: 280.h,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
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
                  _buildAvatarAndUserInfo(firstName, lastName),
                  SizedBox(height: 15.h),
                  _buildCurrentStreakContainer(),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
        const GridviewWithIcons(),
        const IconsAndEventScroll(),
      ],
    );
  }

  Widget _buildAvatarAndUserInfo(String firstName, String lastName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 45.0,
          backgroundImage: AssetImage("assets/avatars/sifat.jpg"),
        ),
        SizedBox(width: 20.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello !",
              style: TextStyle(
                color: Coloris.white,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 5.sp),
            Text(
              "$firstName $lastName",
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

  Widget _buildCurrentStreakContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Coloris.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
        child: GestureDetector(
          onTap: () {
            FirebaseAuth.instance.signOut();
          },
          child: Text("Current Streak"),
        ),
      ),
    );
  }

  Widget _buildRedContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Coloris.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      alignment: Alignment.center,
      height: 55.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/Icons/common/Fire.png",
            height: 40.h,
          ),
          const SizedBox(
            width: 10.0,
          ),
          const Text(
            "15 Days",
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 18.0, color: Colors.red),
          )
        ],
      ),
    );
  }

  double _calculateContainerTopPosition(BuildContext context) {
    // Calculate the top position dynamically based on screen height
    return ScreenUtil().screenHeight * 0.27;
  }

  double _calculateContainerMiddlePosition(BuildContext context) {
    // Calculate the top position dynamically based on screen width
    return ScreenUtil().screenWidth * 0.22;
  }
}
