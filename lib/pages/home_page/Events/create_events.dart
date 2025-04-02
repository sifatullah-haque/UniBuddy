import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isFree = true;
  List<String> _selectedPaymentMethods = [];

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _amountController = TextEditingController();
  final _paymentNumberController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Payment methods
  final List<String> _paymentMethods = ['Bkash', 'Nagad', 'Rocket'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _amountController.dispose();
    _paymentNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 365 * 2)), // 2 years from now
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final status = await Permission.storage.request();
      final cameraStatus = await Permission.camera.request();

      if (status.isDenied || cameraStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied to access photos')),
        );
        return;
      }

      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _getImageBase64() async {
    if (_selectedImage == null) return null;
    try {
      final bytes = await _selectedImage!.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image: $e');
      return null;
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    try {
      final base64Image = await _getImageBase64();
      if (base64Image == null) throw Exception('Failed to convert image');
      return base64Image;
    } catch (e) {
      print('Error processing image: $e');
      return null;
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an event banner')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final imageBase64 = await _getImageBase64();
      if (imageBase64 == null) throw Exception('Failed to process image');

      final eventData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'venue': _venueController.text,
        'date': _selectedDate?.toIso8601String(),
        'time': _timeController.text,
        'imageBase64': imageBase64, // Store as base64 instead of URL
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'isFree': _isFree,
        if (!_isFree)
          ...({
            'amount': double.parse(_amountController.text),
            'paymentMethods': _selectedPaymentMethods,
            'paymentNumber': _paymentNumberController.text,
          }),
      };

      // Add the event to Firestore and get the reference
      DocumentReference eventRef =
          await FirebaseFirestore.instance.collection('events').add(eventData);

      // Send notifications to all users
      await _sendEventNotificationToAllUsers(
        eventId: eventRef.id,
        eventTitle: _titleController.text,
        eventDate: _selectedDate?.toString().split(' ')[0] ?? 'Not set',
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event created successfully'),
          backgroundColor: Color(0xff6686F6),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating event: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendEventNotificationToAllUsers({
    required String eventId,
    required String eventTitle,
    required String eventDate,
  }) async {
    try {
      // Get all users
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Create batch write
      final batch = FirebaseFirestore.instance.batch();

      // Create notification for each user
      for (var userDoc in usersSnapshot.docs) {
        final notificationRef =
            FirebaseFirestore.instance.collection('notifications').doc();

        batch.set(notificationRef, {
          'userId': userDoc.id,
          'title': 'New Event: $eventTitle',
          'message':
              'A new event has been scheduled for $eventDate. Register now!',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'event',
          'relatedItemId': eventId,
          'icon': 'event', // For custom notification icon
        });
      }

      // Commit the batch
      await batch.commit();
      print('Event notifications sent to all users');
    } catch (e) {
      print('Error sending event notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildForm(),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xff6686F6),
                ),
              ),
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
            "Create Event",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: Coloris.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            SizedBox(height: 20.h),
            _buildInputField(
                _titleController, "Event Title", "Enter event title"),
            _buildInputField(_descriptionController, "Description",
                "Enter event description",
                maxLines: 3),
            _buildInputField(_venueController, "Venue", "Enter event venue"),
            _buildDateTimePickers(),
            _buildEventTypeSection(),
            if (!_isFree) ..._buildPaymentFields(),
            SizedBox(height: 20.h),
            _buildSubmitButton(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate,
                      size: 50.sp, color: Colors.grey),
                  SizedBox(height: 10.h),
                  Text(
                    "Add Event Banner",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Coloris.text_color.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: _buildTimePicker(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date",
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: Coloris.text_color.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 20.sp, color: Color(0xff6686F6)),
                  SizedBox(width: 8.w),
                  Text(
                    _selectedDate != null
                        ? _dateController.text
                        : "Select Date",
                    style: TextStyle(
                      color: _selectedDate != null
                          ? Coloris.text_color
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Time",
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: Coloris.text_color.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time,
                      size: 20.sp, color: Color(0xff6686F6)),
                  SizedBox(width: 8.w),
                  Text(
                    _selectedTime != null
                        ? _timeController.text
                        : "Select Time",
                    style: TextStyle(
                      color: _selectedTime != null
                          ? Coloris.text_color
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Is this a free event?",
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildEventTypeButton(true, "Yes"),
              SizedBox(width: 15.w),
              _buildEventTypeButton(false, "No"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeButton(bool isFree, String label) {
    final isSelected = this._isFree == isFree;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => this._isFree = isFree),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                  )
                : null,
            color: isSelected ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPaymentFields() {
    return [
      _buildInputField(_amountController, "Amount", "Enter amount to be paid",
          maxLines: 1),
      _buildPaymentMethodsSelector(),
      _buildInputField(
          _paymentNumberController, "Payment Number", "Enter payment number",
          maxLines: 1),
    ];
  }

  Widget _buildPaymentMethodsSelector() {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Methods",
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 10.w,
            children: _paymentMethods.map((method) {
              final isSelected = _selectedPaymentMethods.contains(method);
              return FilterChip(
                label: Text(method),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPaymentMethods.add(method);
                    } else {
                      _selectedPaymentMethods.remove(method);
                    }
                  });
                },
                selectedColor: Color(0xff6686F6),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _createEvent,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6686F6), Color(0xff60BBEF)],
          ),
          borderRadius: BorderRadius.circular(25),
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
            _isLoading ? "Creating Event..." : "Create Event",
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
}
