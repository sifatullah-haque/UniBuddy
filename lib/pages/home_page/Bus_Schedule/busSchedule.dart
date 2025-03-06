import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeline_tile/timeline_tile.dart';

class BusSchedule extends StatelessWidget {
  const BusSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildAreaSelector(),
          Expanded(
            child: _buildTimelineView(),
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

  Widget _buildAreaSelector() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: "Dhanmondi",
          items: ["Dhanmondi", "Uttara", "Mirpur", "Mohammadpur"]
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Coloris.text_color,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {},
        ),
      ),
    );
  }

  Widget _buildTimelineView() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        // Morning Schedule Header
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Text(
            "Morning Schedule",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff6686F6),
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // Morning Timeline
        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.05, // Moved more to left
          isFirst: true,
          beforeLineStyle: LineStyle(
            color: const Color(0xff6686F6).withOpacity(0.3),
            thickness: 2,
          ),
          indicatorStyle: IndicatorStyle(
            width: 20,
            height: 20,
            indicator: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                ),
              ),
            ),
          ),
          endChild: Padding(
            padding: EdgeInsets.only(left: 15.w, bottom: 25.h, right: 5.w),
            child: _buildScheduleCard(
              title: "Pick Up",
              location: "Dhanmondi Road 27",
              time: "7:30 AM",
              driverContact: "+880 1234567890",
            ),
          ),
        ),

        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.05, // Moved more to left
          isLast: true,
          beforeLineStyle: LineStyle(
            color: const Color(0xff6686F6).withOpacity(0.3),
            thickness: 2,
          ),
          indicatorStyle: IndicatorStyle(
            width: 20,
            height: 20,
            indicator: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                ),
              ),
            ),
          ),
          endChild: Padding(
            padding: EdgeInsets.only(left: 15.w, right: 5.w),
            child: _buildScheduleCard(
              title: "Drop Off",
              location: "DIU Campus",
              time: "8:30 AM",
            ),
          ),
        ),

        // Divider with more space
        SizedBox(height: 50.h),

        // Evening Schedule Header
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Text(
            "Evening Schedule",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff6686F6),
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // Evening Timeline (with same spacing adjustments)
        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.05, // Moved more to left
          isFirst: true,
          beforeLineStyle: LineStyle(
            color: const Color(0xff6686F6).withOpacity(0.3),
            thickness: 2,
          ),
          indicatorStyle: IndicatorStyle(
            width: 20,
            height: 20,
            indicator: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                ),
              ),
            ),
          ),
          endChild: Padding(
            padding: EdgeInsets.only(left: 15.w, bottom: 25.h, right: 5.w),
            child: _buildScheduleCard(
              title: "Pick Up",
              location: "DIU Campus",
              time: "5:00 PM",
              driverContact: "+880 1234567890",
            ),
          ),
        ),

        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.05, // Moved more to left
          isLast: true,
          beforeLineStyle: LineStyle(
            color: const Color(0xff6686F6).withOpacity(0.3),
            thickness: 2,
          ),
          indicatorStyle: IndicatorStyle(
            width: 20,
            height: 20,
            indicator: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                ),
              ),
            ),
          ),
          endChild: Padding(
            padding: EdgeInsets.only(left: 15.w, right: 5.w),
            child: _buildScheduleCard(
              title: "Drop Off",
              location: "Dhanmondi Road 27",
              time: "6:00 PM",
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildScheduleCard({
    required String title,
    required String location,
    required String time,
    String? driverContact,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff6686F6),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            location,
            style: TextStyle(
              fontSize: 14.sp,
              color: Coloris.text_color,
            ),
          ),
          if (driverContact != null) ...[
            SizedBox(height: 5.h),
            Text(
              "Driver: $driverContact",
              style: TextStyle(
                fontSize: 14.sp,
                color: Coloris.text_color.withOpacity(0.7),
              ),
            ),
          ],
          SizedBox(height: 5.h),
          Text(
            time,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Coloris.text_color,
            ),
          ),
        ],
      ),
    );
  }
}
