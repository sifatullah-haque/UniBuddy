import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for clipboard functionality
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diu/models/emergency_alert.dart';

class Emergency extends StatefulWidget {
  const Emergency({super.key});

  @override
  _EmergencyState createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController(); // Add contact controller
  bool _isLoading = false;

  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xff6686F6)),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Creating emergency alert...',
                      style: TextStyle(
                        color: Color(0xff6686F6),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _createAlert() async {
    if (!mounted) return;

    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    _showLoadingOverlay(); // Show loading overlay

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final alert = EmergencyAlert(
        id: '',
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        contact: _contactController.text, // Add contact to the model
        timestamp: DateTime.now(),
        userId: user.uid,
        userEmail: user.email ?? 'Unknown',
      );

      // Add to Firestore
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('emergencyAlerts')
          .add(alert.toMap())
          .timeout(const Duration(seconds: 10),
              onTimeout: () =>
                  throw Exception('Connection timeout. Please try again.'));

      // Send notifications to all users
      await _sendNotificationToAllUsers(
        title: 'EMERGENCY ALERT',
        message: '${_titleController.text} at ${_locationController.text}',
        type: 'emergency',
        relatedItemId: docRef.id,
      );

      if (!mounted) return;

      // Clear the text fields
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _contactController.clear(); // Clear contact field

      Navigator.pop(context); // Close loading overlay
      Navigator.pop(context); // Close dialog box

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency alert created successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // Close loading overlay

      String errorMessage = 'Error creating alert';
      if (e.toString().contains('permission-denied')) {
        errorMessage =
            'Permission denied. Please check your account permissions.';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Add this new method to send notifications to all users
  Future<void> _sendNotificationToAllUsers({
    required String title,
    required String message,
    required String type,
    required String relatedItemId,
  }) async {
    try {
      // Get all users
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Create batch to handle multiple writes efficiently
      final batch = FirebaseFirestore.instance.batch();

      // Create a notification for each user
      for (var userDoc in usersSnapshot.docs) {
        final notificationRef =
            FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': userDoc.id,
          'title': title,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': type,
          'relatedItemId': relatedItemId,
        });
      }

      // Commit the batch
      await batch.commit();
      print('Notifications sent to all users successfully');
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  void _showCreateEmergencyDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String emergencyOf = '';
    String contactNumber = '';

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        emergencyOf = '${userData['firstName']} ${userData['lastName']}';
        contactNumber = userData['phoneNo'] ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
    }

    _contactController.text = contactNumber;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final bool isKeyboardVisible =
                MediaQuery.of(context).viewInsets.bottom > 0;
            final double screenHeight = MediaQuery.of(context).size.height;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: isKeyboardVisible
                      ? screenHeight * 0.5
                      : screenHeight * 0.6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Custom header
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 15.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Create Emergency Alert',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    // Form content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormField(
                                controller:
                                    TextEditingController(text: emergencyOf),
                                labelText: 'Emergency Of',
                                enabled: false,
                              ),
                              SizedBox(height: 12.h),
                              _buildFormField(
                                controller: _contactController,
                                labelText: 'Contact Number',
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: 12.h),
                              _buildFormField(
                                controller: _locationController,
                                labelText: 'Location',
                              ),
                              SizedBox(height: 12.h),
                              _buildFormField(
                                controller: _titleController,
                                labelText: 'Title',
                              ),
                              SizedBox(height: 12.h),
                              _buildFormField(
                                controller: _descriptionController,
                                labelText: 'Description',
                                maxLines: 3,
                              ),
                              SizedBox(height: 15.h), // Reduced spacing
                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    bool enabled = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14.sp,
        color: enabled ? Coloris.text_color : Colors.grey[700],
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14.sp,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xff6686F6), width: 1.5),
        ),
        filled: !enabled,
        fillColor: enabled ? Colors.transparent : Colors.grey[100],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _createAlert,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading
                ? [Colors.grey, Colors.grey.shade400]
                : [Color(0xff6686F6), Color(0xff60BBEF)],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Color(0xff6686F6).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Create Emergency Alert",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _handleCardTap(EmergencyAlert alert) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid == alert.userId) {
      _showDeleteConfirmation(alert);
    }
  }

  void _showDeleteConfirmation(EmergencyAlert alert) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Delete Emergency Alert'),
        content: Text('Are you sure you want to delete this emergency alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Close dialog first
              Navigator.pop(dialogContext);

              // Then perform the delete operation
              FirebaseFirestore.instance
                  .collection('emergencyAlerts')
                  .doc(alert.id)
                  .delete()
                  .then((_) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                      content: Text('Emergency alert deleted successfully')),
                );
              }).catchError((error) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error deleting alert: $error')),
                );
              });
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
          onPressed:
              _showCreateEmergencyDialog, // Updated to call the new dialog
          label: Text(
            'Create Emergency Alert',
            style: TextStyle(
              color: Coloris.white,
              fontSize: 14.sp,
            ),
          ),
          icon: Icon(Icons.add_alert, color: Coloris.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 20.h),
          Expanded(
            child: _buildAlertList(),
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
            "Emergency Alerts",
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

  Widget _buildAlertList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emergencyAlerts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final alerts = snapshot.data!.docs
            .map((doc) => EmergencyAlert.fromMap(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: alerts.length,
          itemBuilder: (context, index) => _buildAlertCard(alerts[index]),
        );
      },
    );
  }

  Widget _buildAlertCard(EmergencyAlert alert) {
    return GestureDetector(
      onTap: () => _handleCardTap(alert),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
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
              children: [
                Icon(Icons.emergency,
                    color: Coloris.primary_color, size: 24.sp),
                SizedBox(width: 10.w),
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Coloris.primary_color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              alert.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Coloris.text_color.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Contact: ${alert.contact}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Coloris.text_color,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _copyToClipboard(alert.contact),
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      Icons.copy,
                      color: Coloris.primary_color,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Location: ${alert.location}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Coloris.text_color,
                  ),
                ),
                Text(
                  _getTimeAgo(alert.timestamp),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Coloris.text_color.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Add this new method to handle copying to clipboard
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Contact number copied to clipboard"),
          backgroundColor: Coloris.primary_color,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
