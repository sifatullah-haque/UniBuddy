import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diu/pages/home_page/Class_Schedule/CreateClassSchedule.dart';
import 'dart:convert';

class ClassSchedule extends StatefulWidget {
  const ClassSchedule({super.key});

  @override
  State<ClassSchedule> createState() => _ClassScheduleState();
}

class _ClassScheduleState extends State<ClassSchedule> {
  String? _selectedRoutineUrl;

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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('fullRoutines')
                        .orderBy('uploadedAt', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error loading routine'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text('No routine uploaded yet'),
                        );
                      }

                      final routineData = snapshot.data!.docs.first.data()
                          as Map<String, dynamic>;
                      final imageBase64 = routineData['imageBase64'] as String?;

                      if (imageBase64 == null || imageBase64.isEmpty) {
                        return Center(
                          child: Text('No routine image available'),
                        );
                      }

                      return InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.memory(
                          base64Decode(imageBase64),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text('Failed to load routine'),
                            );
                          },
                        ),
                      );
                    },
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
                "Classes Today",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff6686F6),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () => _showFullRoutine(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('View Routine'),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('classSchedules')
                .where('day', isEqualTo: _getCurrentDay())
                .orderBy('startTime')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // Check specifically for the missing index error
                if (snapshot.error.toString().contains('FAILED_PRECONDITION')) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        children: [
                          Text(
                            'Setting up the database...',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Coloris.text_color.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  );
                }
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final schedules = snapshot.data!.docs;
              if (schedules.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      'You don\'t have any classes today',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Coloris.text_color.withOpacity(0.7),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: schedules.map((schedule) {
                  final data = schedule.data() as Map<String, dynamic>;
                  return _buildClassCard(
                    subject: data['subject'] ?? '',
                    time: '${data['startTime']} - ${data['endTime']}',
                    room: data['room'] ?? '',
                    faculty: data['faculty'] ?? '',
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getCurrentDay() {
    switch (DateTime.now().weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('facultyContacts')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final contacts = snapshot.data!.docs;
              if (contacts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      'No faculty contacts available',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Coloris.text_color.withOpacity(0.7),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: contacts.map((contact) {
                  final data = contact.data() as Map<String, dynamic>;
                  return Column(
                    children: [
                      _buildFacultyCard(
                        name: data['name'] ?? '',
                        email: data['email'] ?? '',
                        phone: data['phone'] ?? '',
                      ),
                      SizedBox(height: 15.h),
                    ],
                  );
                }).toList(),
              );
            },
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
