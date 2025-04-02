import 'package:flutter/material.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:diu/pages/home_page/Events/event_register.dart';

class EventDetails extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventDetails({
    Key? key,
    required this.eventId,
    required this.eventData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventBanner(context),
            _buildEventContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBanner(BuildContext context) {
    return Stack(
      children: [
        eventData['imageBase64'] != null
            ? Image.memory(
                base64Decode(eventData['imageBase64']),
                height: 300.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300.h,
                  color: Colors.grey[300],
                  child: Icon(Icons.error),
                ),
              )
            : Container(
                height: 300.h,
                color: Colors.grey[300],
                child: Icon(Icons.image),
              ),
        Positioned(
          top: 40.h,
          left: 10.w,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Container(
          height: 300.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20.h,
          left: 20.w,
          right: 20.w,
          child: Text(
            eventData['title'] ?? 'Event Title',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventContent(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('eventRegistrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        bool isRegistered = false;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          isRegistered = true;
        }

        final date = eventData['date'] != null
            ? DateTime.parse(eventData['date']).toString().split(' ')[0]
            : 'Date not set';
        final time = eventData['time'] ?? 'Time not set';
        final venue = eventData['venue'] ?? 'Venue not set';
        final description =
            eventData['description'] ?? 'No description available';
        final isFree = eventData['isFree'] ?? true;
        final amount = eventData['amount']?.toString() ?? '0';
        final paymentMethods = eventData['paymentMethods'] ?? [];
        final paymentNumber = eventData['paymentNumber'] ?? '';

        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.calendar_today, "Date", date),
              SizedBox(height: 15.h),
              _buildInfoRow(Icons.location_on, "Venue", venue),
              SizedBox(height: 15.h),
              _buildInfoRow(Icons.access_time, "Time", time),
              if (!isFree) ...[
                SizedBox(height: 15.h),
                _buildInfoRow(Icons.money, "Entry Fee", "$amount Tk"),
                SizedBox(height: 15.h),
                _buildInfoRow(Icons.payment, "Payment Methods",
                    paymentMethods.join(", ")),
                if (paymentNumber.isNotEmpty) ...[
                  SizedBox(height: 15.h),
                  _buildInfoRow(Icons.phone, "Payment Number", paymentNumber),
                ],
              ],
              SizedBox(height: 25.h),
              Text(
                "About Event",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Coloris.text_color,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Coloris.text_color.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 25.h),
              _buildRegisterButton(context, isRegistered),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xff6686F6), size: 24.sp),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Coloris.text_color.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Coloris.text_color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context, bool isRegistered) {
    return GestureDetector(
      onTap: isRegistered
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventRegister(
                    eventId: eventId,
                    eventData: eventData,
                  ),
                ),
              );
            },
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isRegistered
                ? [Colors.grey, Colors.grey.shade600]
                : [Color(0xff6686F6), Color(0xff60BBEF)],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            isRegistered ? "Already Registered" : "Register Now",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
