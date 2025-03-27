import 'package:diu/Constant/color_is.dart';
import 'package:diu/pages/home_page/askBot/askBot.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'gridview_with_icons.dart';
import 'icon_and_event_scroll.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userData = doc.data();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

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
          height: 200.h,
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
          height: 18.h,
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 40.0,
          backgroundImage: AssetImage("assets/avatars/sifat.jpg"),
        ),
        SizedBox(width: 20.w),
        isLoading ? _buildLoadingInfo() : _buildUserInfo(),
      ],
    );
  }

  Widget _buildLoadingInfo() {
    return Column(
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
        Container(
          width: 150.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 10.sp),
        Container(
          width: 80.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    final String fullName = userData != null
        ? "${userData!['firstName'] ?? ''} ${userData!['lastName'] ?? ''}"
        : "User";

    final String batchNo = userData != null ? userData!['batchNo'] ?? "" : "";

    final String userId = userData != null ? userData!['userId'] ?? "" : "";

    return Column(
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
          fullName,
          style: TextStyle(
            color: Coloris.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5.sp),
        Row(
          children: [
            Text(
              userId.isNotEmpty ? userId : "($batchNo)",
              style: TextStyle(
                color: Coloris.white,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              batchNo.isNotEmpty ? "($batchNo)" : "",
              style: TextStyle(
                color: Coloris.white,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
          ],
        )
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
    return ScreenUtil().screenHeight * 0.19;
  }

  double _calculateContainerSidePosition(BuildContext context) {
    // Calculate the side padding to center the container with 56% width
    // This means the container will take up 44% of screen width (100% - 2*28%)
    return ScreenUtil().screenWidth * 0.28;
  }
}
