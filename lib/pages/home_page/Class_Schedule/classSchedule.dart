import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClassSchedule extends StatefulWidget {
  const ClassSchedule({super.key});

  @override
  State<ClassSchedule> createState() => _ClassScheduleState();
}

class _ClassScheduleState extends State<ClassSchedule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildClassSchedule(),
                  _buildFacultyContact(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullRoutine(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Coloris.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Full Class Routine",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Coloris.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Coloris.white,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      'https://i.ibb.co.com/1tBxF1YC/Whats-App-Image-2025-03-07-at-09-19-43-03ef2d1a.jpg',
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xff6686F6),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Failed to load routine',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Coloris.text_color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            "Class Schedule",
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

  Widget _buildClassSchedule() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(15.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Classes",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff6686F6),
                ),
              ),
              ElevatedButton(
                onPressed: () => _showFullRoutine(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6686F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View Routine',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          _buildClassCard(
            subject: "Software Engineering",
            time: "09:30 AM - 11:00 AM",
            room: "Room 401",
            faculty: "Mahbubur Rahman",
          ),
          SizedBox(height: 15.h),
          _buildClassCard(
            subject: "Database Management",
            time: "11:30 AM - 01:00 PM",
            room: "Room 402",
            faculty: "Aminur Raj",
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard({
    required String subject,
    required String time,
    required String room,
    required String faculty,
  }) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff6686F6).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Coloris.text_color,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            time,
            style: TextStyle(
              fontSize: 14.sp,
              color: Coloris.text_color.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                room,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Coloris.text_color,
                ),
              ),
              Text(
                faculty,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xff6686F6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyContact() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(15.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Faculty Contact",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff6686F6),
            ),
          ),
          SizedBox(height: 15.h),
          _buildFacultyCard(
            name: "Dr. John Doe",
            email: "john.doe@university.edu",
            phone: "+880 1234567890",
          ),
          SizedBox(height: 15.h),
          _buildFacultyCard(
            name: "Dr. Jane Smith",
            email: "jane.smith@university.edu",
            phone: "+880 1234567891",
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyCard({
    required String name,
    required String email,
    required String phone,
  }) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff6686F6).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Coloris.text_color,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Coloris.text_color.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Coloris.text_color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Add phone call functionality here
            },
            icon: Icon(
              Icons.call,
              color: const Color(0xff6686F6),
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}
