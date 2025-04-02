import 'package:diu/Constant/color_is.dart';
import 'package:diu/pages/Specific_Club/DIU_CPC/diu_cpc.dart';
import 'package:diu/pages/home_page/Events/event_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class IconsAndEventScroll extends StatelessWidget {
  const IconsAndEventScroll({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "University Clubs",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          SizedBox(
            height: 6.h,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DiuCpc()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 55.h,
                    backgroundColor: Colors.transparent,
                    child: Image.asset("assets/logos/CPC.png"),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showNotMemberDialog(context),
                  child: CircleAvatar(
                    radius: 55.h,
                    backgroundColor: Colors.transparent,
                    child: Image.asset("assets/logos/CDS.png"),
                  ),
                ),
                SizedBox(
                  width: 7.w,
                ),
                GestureDetector(
                  onTap: () => _showNotMemberDialog(context),
                  child: CircleAvatar(
                    radius: 45.h,
                    backgroundColor: Colors.transparent,
                    child: Image.asset("assets/logos/FPC.png"),
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                GestureDetector(
                  onTap: () => _showNotMemberDialog(context),
                  child: CircleAvatar(
                    radius: 45.h,
                    backgroundColor: Colors.transparent,
                    child: Image.asset("assets/logos/DIU.png"),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          const Text(
            "Upcoming Events",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 6.0),
          _buildUpcomingEvents(),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('date',
              isGreaterThanOrEqualTo:
                  DateTime.now().toIso8601String()) // Only future events
          .orderBy('date', descending: false) // Sort by date ascending
          .limit(5) // Keep the limit
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final events = snapshot.data?.docs ?? [];

        if (events.isEmpty) {
          return const Center(
            child: Text('No upcoming events'),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: events.map((event) {
              final eventData = event.data() as Map<String, dynamic>;
              return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: _roundedImageContainer(
                  context,
                  event.id,
                  eventData,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _roundedImageContainer(
    BuildContext context,
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
        height: 85.0,
        width: 135.0,
        decoration: BoxDecoration(
          color: Coloris.primary_color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: eventData['imageBase64'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.memory(
                  base64Decode(eventData['imageBase64']),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.error),
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.image),
              ),
      ),
    );
  }

  void _showNotMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.amber,
              ),
              SizedBox(height: 16),
              Text(
                "This club is not a member of this app yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "We're working on adding more clubs to the app. Please check back later.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
