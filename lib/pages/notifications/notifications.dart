import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildNotificationList(),
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
            "Notifications",
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

  Widget _buildNotificationList() {
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Please login to view notifications',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user!.uid)
          // Temporarily remove ordering until index is created
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.red),
                SizedBox(height: 10),
                Text(
                  'Error loading notifications\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[600]),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Coloris.primary_color),
            ),
          );
        }

        final notifications = snapshot.data!.docs.map((doc) {
          return NotificationModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        // Sort notifications locally until index is created
        notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 50, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  'No notifications yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          itemCount: notifications.length,
          itemBuilder: (context, index) =>
              _buildNotificationItem(notifications[index]),
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'found_item':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'emergency':
        iconData = Icons.warning;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Coloris.primary_color;
    }

    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        decoration: BoxDecoration(
          color: notification.isRead ? Coloris.white : const Color(0xffEEF3FF),
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
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Coloris.text_color,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Coloris.text_color.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      timeago.format(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Coloris.text_color.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 10.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Coloris.primary_color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    // Mark as read
    if (!notification.isRead) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notification.id)
          .update({'isRead': true});
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case 'found_item':
        if (notification.relatedItemId != null) {
          // Navigate to lost item details
          // TODO: Implement navigation to lost item details
        }
        break;
      case 'emergency':
        if (notification.relatedItemId != null) {
          // Navigate to emergency alert details
          // TODO: Implement navigation to emergency details
        }
        break;
    }
  }
}
