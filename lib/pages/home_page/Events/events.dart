import 'package:flutter/material.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'event_details.dart';

class Events extends StatelessWidget {
  const Events({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildEventsList(context),
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
            "Events",
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

  Widget _buildEventsList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildEventCard(
          context,
          "Tech Fest 2024",
          "A grand technology festival featuring workshops, competitions, and exhibitions.",
          "assets/banner/events/event${index + 1}.jpg",
          "March 15, 2024",
          "DIU Campus",
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, String title, String description,
      String imagePath, String date, String venue) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetails(
              title: title,
              imagePath: imagePath,
              date: date,
              venue: venue,
            ),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                imagePath,
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Coloris.text_color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Coloris.text_color.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16.sp, color: Color(0xff6686F6)),
                      SizedBox(width: 4.w),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xff6686F6),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Icon(Icons.location_on,
                          size: 16.sp, color: Color(0xff6686F6)),
                      SizedBox(width: 4.w),
                      Text(
                        venue,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xff6686F6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
