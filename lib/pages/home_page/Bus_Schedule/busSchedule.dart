import 'dart:async'; // Add this import
import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimerWidget extends StatefulWidget {
  final DateTime lastRequestTime;

  const TimerWidget({super.key, required this.lastRequestTime});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  Duration? timeLeft;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Calculate initial time left
    final difference = DateTime.now().difference(widget.lastRequestTime);
    timeLeft = Duration(minutes: 30) - difference;

    // Update timer every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final newDifference = DateTime.now().difference(widget.lastRequestTime);
      if (newDifference.inMinutes >= 30) {
        timer.cancel();
        if (mounted) {
          setState(() {
            timeLeft = Duration.zero;
          });
        }
      } else {
        setState(() {
          timeLeft = Duration(minutes: 30) - newDifference;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (timeLeft == null || timeLeft!.inSeconds <= 0) return SizedBox.shrink();

    return Center(
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'You can send another pickup request in: ${timeLeft!.inMinutes}m ${timeLeft!.inSeconds % 60}s',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class BusSchedule extends StatefulWidget {
  const BusSchedule({super.key});

  @override
  State<BusSchedule> createState() => _BusScheduleState();
}

class _BusScheduleState extends State<BusSchedule> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildScheduleContent(),
          ),
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
            "Bus Schedule",
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

  Widget _buildScheduleContent() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('bus_schedules').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Check if there are any documents
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          // Create initial document if it doesn't exist
          FirebaseFirestore.instance
              .collection('bus_schedules')
              .doc('current')
              .set({
            'notun_bazar_count': 0,
            'campus_count': 0,
            'created_at': FieldValue.serverTimestamp(),
          }).catchError((error) {
            print('Error creating initial bus schedule: $error');
          });

          // Return default values while document is being created
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildRouteCard(),
                SizedBox(height: 20.h),
                _buildLocationCards(context, 0, 0),
                SizedBox(height: 20.h),
                _buildScheduleCards(),
              ],
            ),
          );
        }

        // Get the current schedule document
        final scheduleDoc = snapshot.data?.docs.first;
        final notunBazarCount = scheduleDoc?['notun_bazar_count'] ?? 0;
        final campusCount = scheduleDoc?['campus_count'] ?? 0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _buildRouteCard(),
              SizedBox(height: 20.h),
              _buildLocationCards(context, notunBazarCount, campusCount),
              SizedBox(height: 20.h),
              _buildScheduleCards(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteCard() {
    return Container(
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
          Text(
            "Current Route",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff6686F6),
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.location_on, color: Color(0xff6686F6)),
                    SizedBox(height: 5.h),
                    Text(
                      "Notun Bazar",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: Color(0xff6686F6),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.school, color: Color(0xff6686F6)),
                    SizedBox(height: 5.h),
                    Text(
                      "DIU Campus",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCards(
      BuildContext context, int notunBazarCount, int campusCount) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Container();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bus_schedules_requests')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        bool canRequest = true;
        String? lastRequestType;
        DateTime? lastRequestTime;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['lastRequestTime'] != null) {
            lastRequestTime = (data['lastRequestTime'] as Timestamp).toDate();
            lastRequestType = data['requestType'] as String?;

            final difference = DateTime.now().difference(lastRequestTime);
            if (difference.inMinutes < 30) {
              canRequest = false;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Send Pickup Request",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xff6686F6),
              ),
            ),
            SizedBox(height: 15.h),
            if (!canRequest && lastRequestTime != null) ...[
              TimerWidget(lastRequestTime: lastRequestTime),
              SizedBox(height: 15.h),
            ],
            Row(
              children: [
                Expanded(
                  child: _buildLocationCard(
                    context,
                    "Notun Bazar",
                    notunBazarCount,
                    Icons.location_on,
                    'notun_bazar',
                    canRequest && lastRequestType != 'campus',
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: _buildLocationCard(
                    context,
                    "DIU Campus",
                    campusCount,
                    Icons.school,
                    'campus',
                    canRequest && lastRequestType != 'notun_bazar',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    String location,
    int count,
    IconData icon,
    String voteType,
    bool enabled,
  ) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: enabled ? Coloris.white : Colors.grey.shade100,
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
          Icon(icon,
              color: enabled ? Color(0xff6686F6) : Colors.grey, size: 30),
          SizedBox(height: 10.h),
          Text(
            location,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: enabled ? Coloris.text_color : Colors.grey,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            "$count requests",
            style: TextStyle(
              fontSize: 12.sp,
              color:
                  (enabled ? Coloris.text_color : Colors.grey).withOpacity(0.7),
            ),
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: enabled ? () => _handleVote(context, voteType) : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: enabled
                    ? Color(0xff6686F6).withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                enabled ? "Tap to Request" : "Not Available",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: enabled ? Color(0xff6686F6) : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Schedule",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xff6686F6),
          ),
        ),
        SizedBox(height: 15.h),
        _buildTimeCard("Morning", "7:30 AM", "8:30 AM"),
        SizedBox(height: 15.h),
        _buildTimeCard("Evening", "5:00 PM", "6:00 PM"),
      ],
    );
  }

  Widget _buildTimeCard(String period, String startTime, String endTime) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Color(0xff6686F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              period == "Morning" ? Icons.wb_sunny : Icons.nights_stay,
              color: Color(0xff6686F6),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$period Schedule",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Coloris.text_color,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  "Departure: $startTime",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Coloris.text_color.withOpacity(0.7),
                  ),
                ),
                Text(
                  "Arrival: $endTime",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Coloris.text_color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleVote(BuildContext context, String voteType) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to request pickup')),
        );
        return;
      }

      final userRequestRef = FirebaseFirestore.instance
          .collection('bus_schedules_requests')
          .doc(user.uid);

      final scheduleRef =
          FirebaseFirestore.instance.collection('bus_schedules').doc('current');

      // Use a batch to update both documents
      final batch = FirebaseFirestore.instance.batch();

      // Update the request tracking document
      batch.set(userRequestRef, {
        'lastRequestTime': FieldValue.serverTimestamp(),
        'requestType': voteType,
        'userId': user.uid,
      });

      // Update the count
      batch.update(scheduleRef, {
        '${voteType}_count': FieldValue.increment(1),
      });

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pickup request submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: ${e.toString()}')),
      );
    }
  }
}
