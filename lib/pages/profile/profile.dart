import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildProfileInfo(),
          _buildProfileOptions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120.h,
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
        child: Center(
          child: Text(
            "Profile",
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w600,
              color: Coloris.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Coloris.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundImage: const AssetImage("assets/avatars/sifat.jpg"),
          ),
          SizedBox(height: 15.h),
          Text(
            "Sifatullah Haque Sajeeb",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Coloris.text_color,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            "D-78(A)",
            style: TextStyle(
              fontSize: 16.sp,
              color: Coloris.text_color.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            "Department of CSE",
            style: TextStyle(
              fontSize: 16.sp,
              color: Coloris.text_color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView(
          children: [
            _buildOptionTile(
              icon: Icons.person_outline,
              title: "Personal Information",
            ),
            _buildOptionTile(
              icon: Icons.school_outlined,
              title: "Academic Details",
            ),
            _buildOptionTile(
              icon: Icons.receipt_long_outlined,
              title: "Results",
            ),
            _buildOptionTile(
              icon: Icons.settings_outlined,
              title: "Settings",
            ),
            _buildOptionTile(
              icon: Icons.help_outline,
              title: "Help & Support",
            ),
            _buildOptionTile(
              icon: Icons.logout,
              title: "Logout",
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Coloris.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : const Color(0xff6686F6),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: isLogout ? Colors.red : Coloris.text_color,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18.sp,
          color: isLogout ? Colors.red : Coloris.text_color.withOpacity(0.5),
        ),
      ),
    );
  }
}
