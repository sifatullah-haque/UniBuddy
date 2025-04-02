import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';

class CreateClassSchedule extends StatefulWidget {
  const CreateClassSchedule({super.key});

  @override
  State<CreateClassSchedule> createState() => _CreateClassScheduleState();
}

class _CreateClassScheduleState extends State<CreateClassSchedule> {
  final _formKey = GlobalKey<FormState>();
  File? _routineImage;
  bool _isLoadingSchedule = false;
  bool _isLoadingRoutine = false;
  bool _isLoadingFaculty = false;
  String? _selectedDay;
  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Form controllers
  final _subjectController = TextEditingController();
  final _roomController = TextEditingController();
  final _facultyController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Faculty form controllers
  final _facultyNameController = TextEditingController();
  final _facultyEmailController = TextEditingController();
  final _facultyPhoneController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _roomController.dispose();
    _facultyController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _facultyNameController.dispose();
    _facultyEmailController.dispose();
    _facultyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _startTime = pickedTime;
        _startTimeController.text = _formatTimeOfDay(pickedTime);
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _endTime = pickedTime;
        _endTimeController.text = _formatTimeOfDay(pickedTime);
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  Future<void> _pickRoutineImage() async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      final cameraStatus = await Permission.camera.request();

      if (status.isDenied || cameraStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied to access photos')),
        );
        return;
      }

      // Show image source choice dialog
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
        maxWidth: 1200,
      );

      if (pickedFile != null) {
        setState(() {
          _routineImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _addClassSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a day')),
      );
      return;
    }

    setState(() => _isLoadingSchedule = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Add to Firestore
      await FirebaseFirestore.instance.collection('classSchedules').add({
        'day': _selectedDay,
        'subject': _subjectController.text,
        'room': _roomController.text,
        'faculty': _facultyController.text,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'createdAt': DateTime.now(),
        'userId': user.uid,
      });

      // Clear form
      _subjectController.clear();
      _roomController.clear();
      _facultyController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
      setState(() {
        _selectedDay = null;
        _startTime = null;
        _endTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class schedule added successfully'),
          backgroundColor: Color(0xff6686F6),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding class schedule: $e')),
      );
    } finally {
      setState(() => _isLoadingSchedule = false);
    }
  }

  Future<void> _uploadFullRoutine() async {
    if (_routineImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a routine image')),
      );
      return;
    }

    setState(() => _isLoadingRoutine = true);

    try {
      // Convert image to base64
      final bytes = await _routineImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Add to Firestore with base64 string
      await FirebaseFirestore.instance.collection('fullRoutines').add({
        'imageBase64': base64Image, // Store base64 string instead of URL
        'uploadedAt': DateTime.now(),
        'userId': FirebaseAuth.instance.currentUser!.uid,
      });

      setState(() {
        _routineImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Routine uploaded successfully'),
          backgroundColor: Color(0xff6686F6),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading routine: $e')),
      );
    } finally {
      setState(() => _isLoadingRoutine = false);
    }
  }

  Future<void> _addFaculty() async {
    if (_facultyNameController.text.isEmpty ||
        _facultyEmailController.text.isEmpty ||
        _facultyPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all faculty fields')),
      );
      return;
    }

    setState(() => _isLoadingFaculty = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Add to Firestore with userId
      await FirebaseFirestore.instance.collection('facultyContacts').add({
        'name': _facultyNameController.text,
        'email': _facultyEmailController.text,
        'phone': _facultyPhoneController.text,
        'createdAt': DateTime.now(),
        'userId': user.uid,
      });

      // Clear form
      _facultyNameController.clear();
      _facultyEmailController.clear();
      _facultyPhoneController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faculty contact added successfully'),
          backgroundColor: Color(0xff6686F6),
        ),
      );

      // Optional: Navigate back to ClassSchedule
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding faculty contact: $e')),
      );
    } finally {
      setState(() => _isLoadingFaculty = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildClassScheduleForm(),
                      SizedBox(height: 30.h),
                      _buildRoutineUploadSection(),
                      SizedBox(height: 30.h),
                      _buildFacultyContactForm(),
                    ],
                  ),
                ),
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
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Coloris.white, size: 24.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Text(
                "Create Class Schedule",
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w600,
                  color: Coloris.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassScheduleForm() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Class Schedule",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff6686F6),
            ),
          ),
          SizedBox(height: 20.h),
          // Day selection
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Day',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            value: _selectedDay,
            items: _weekDays.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDay = newValue;
              });
            },
          ),
          SizedBox(height: 15.h),
          // Subject
          TextFormField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter subject' : null,
          ),
          SizedBox(height: 15.h),
          // Time selection
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: _selectStartTime,
                  validator: (value) =>
                      value!.isEmpty ? 'Please select start time' : null,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: TextFormField(
                  controller: _endTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: _selectEndTime,
                  validator: (value) =>
                      value!.isEmpty ? 'Please select end time' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          // Room
          TextFormField(
            controller: _roomController,
            decoration: InputDecoration(
              labelText: 'Room Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter room number' : null,
          ),
          SizedBox(height: 15.h),
          // Faculty
          TextFormField(
            controller: _facultyController,
            decoration: InputDecoration(
              labelText: 'Faculty Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter faculty name' : null,
          ),
          SizedBox(height: 20.h),
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: _isLoadingSchedule ? null : _addClassSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _isLoadingSchedule ? 'Adding...' : 'Add Class',
                  style: TextStyle(
                    color: Coloris.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineUploadSection() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upload Full Routine",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff6686F6),
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: _pickRoutineImage,
            child: Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _routineImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _routineImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 50.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Tap to upload routine image",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 20.h),
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: _isLoadingRoutine || _routineImage == null
                    ? null
                    : _uploadFullRoutine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _isLoadingRoutine ? 'Uploading...' : 'Upload Routine',
                  style: TextStyle(
                    color: Coloris.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyContactForm() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Faculty Contact",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff6686F6),
            ),
          ),
          SizedBox(height: 20.h),
          TextFormField(
            controller: _facultyNameController,
            decoration: InputDecoration(
              labelText: 'Faculty Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          TextFormField(
            controller: _facultyEmailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 15.h),
          TextFormField(
            controller: _facultyPhoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 20.h),
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: _isLoadingFaculty ? null : _addFaculty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _isLoadingFaculty ? 'Adding...' : 'Add Faculty',
                  style: TextStyle(
                    color: Coloris.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
