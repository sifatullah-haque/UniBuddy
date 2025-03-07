import 'package:flutter/material.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventDetails extends StatelessWidget {
  final String title;
  final String imagePath;
  final String date;
  final String venue;

  const EventDetails({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.date,
    required this.venue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventBanner(context),
            _buildEventContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBanner(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          imagePath,
          height: 300.h,
          width: double.infinity,
          fit: BoxFit.cover,
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
            title,
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

  Widget _buildEventContent() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.calendar_today, "Date", date),
          SizedBox(height: 15.h),
          _buildInfoRow(Icons.location_on, "Venue", venue),
          SizedBox(height: 15.h),
          _buildInfoRow(Icons.access_time, "Time", "10:00 AM - 5:00 PM"),
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
            "Join us for an exciting event featuring workshops, competitions, and exhibitions. Network with industry professionals and showcase your talents. Don't miss this opportunity to be part of something amazing!",
            style: TextStyle(
              fontSize: 16.sp,
              color: Coloris.text_color.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: 25.h),
          _buildRegisterButton(),
        ],
      ),
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

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff6686F6), Color(0xff60BBEF)],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          "Register Now",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
