import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:diu/pages/profile/personalInformation.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildProfileInfo(),
          _buildProfileOptions(),
          SizedBox(height: 90.h),
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
    if (isLoading) {
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
              backgroundColor: Colors.grey[200],
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: 15.h),
            Container(
              width: 150.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 5.h),
            Container(
              width: 80.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    final String fullName = userData != null
        ? "${userData!['firstName'] ?? ''} ${userData!['lastName'] ?? ''}"
        : "User";
    final String batchNo = userData != null ? userData!['batchNo'] ?? "" : "";
    final String deptName = userData != null ? userData!['deptName'] ?? "" : "";
    final String? profilePicture = userData?['profilePicture'];

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
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
            backgroundColor: Colors.grey[200],
            child: profilePicture != null && profilePicture.isNotEmpty
                ? ClipOval(
                    child: Image.memory(
                      base64Decode(profilePicture),
                      fit: BoxFit.cover,
                      width: 100.r,
                      height: 100.r,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported_outlined,
                        size: 40.r,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Icon(
                    Icons.image_not_supported_outlined,
                    size: 40.r,
                    color: Colors.grey[400],
                  ),
          ),
          SizedBox(height: 15.h),
          Text(
            fullName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Coloris.text_color,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            batchNo,
            style: TextStyle(
              fontSize: 16.sp,
              color: Coloris.text_color.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            "Department of $deptName",
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
        onTap: () {
          if (isLogout) {
            FirebaseAuth.instance.signOut();
          } else if (title == "Personal Information") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalInformation(),
              ),
            );
          }
        },
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
