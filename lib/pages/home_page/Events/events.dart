import 'package:diu/pages/home_page/Events/create_events.dart';
import 'package:flutter/material.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'event_details.dart';

class Events extends StatelessWidget {
  const Events({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xff6686F6), Color(0xff60BBEF)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateEvent()),
            );
          },
          label: Text(
            'Create Event',
            style: TextStyle(
              color: Coloris.white,
              fontSize: 14.sp,
            ),
          ),
          icon: Icon(Icons.add, color: Coloris.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!.docs;

        if (events.isEmpty) {
          return Center(child: Text('No events found'));
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;
            return _buildEventCard(
              context,
              event['title'] ?? 'Untitled Event',
              event['description'] ?? 'No description available',
              event['imageUrl'] ?? '',
              event['date'] != null
                  ? DateTime.parse(event['date']).toString().split(' ')[0]
                  : 'Date not set',
              event['venue'] ?? 'Venue not set',
              events[index].id,
              event,
            );
          },
        );
      },
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    String title,
    String description,
    String imageUrl,
    String date,
    String venue,
    String eventId,
    Map<String, dynamic> eventData,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetails(
              eventId: eventId,
              eventData: eventData,
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
              child: eventData['imageBase64'] != null
                  ? Image.memory(
                      base64Decode(eventData['imageBase64']),
                      height: 150.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150.h,
                        color: Colors.grey[300],
                        child: Icon(Icons.error),
                      ),
                    )
                  : Container(
                      height: 150.h,
                      color: Colors.grey[300],
                      child: Icon(Icons.image),
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
