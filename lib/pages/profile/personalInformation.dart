import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/pages/main_navigation.dart';
import 'package:diu/providers/user_data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({Key? key}) : super(key: key);

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isSaving = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _rollNumberController;
  late TextEditingController _batchNumberController;
  late TextEditingController _registrationNumberController;
  late TextEditingController _departmentController;
  late TextEditingController _semesterController;
  bool _isBiSemester = true;
  bool _isDayShift = true;
  String? _selectedBloodGroup;
  String? _profilePicture;
  String? _idCardImage;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchUserData();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _rollNumberController = TextEditingController();
    _batchNumberController = TextEditingController();
    _registrationNumberController = TextEditingController();
    _departmentController = TextEditingController();
    _semesterController = TextEditingController();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userData = doc.data();
            _populateFields();
            isLoading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
    setState(() => isLoading = false);
  }

  void _populateFields() {
    if (userData != null) {
      _firstNameController.text = userData!['firstName'] ?? '';
      _lastNameController.text = userData!['lastName'] ?? '';
      _phoneController.text = userData!['phoneNo'] ?? '';
      _rollNumberController.text = userData!['rollNo'] ?? '';
      _batchNumberController.text = userData!['batchNo'] ?? '';
      _registrationNumberController.text = userData!['registrationNo'] ?? '';
      _departmentController.text = userData!['deptName'] ?? '';
      _semesterController.text = userData!['semesterNo']?.toString() ?? '';
      _isBiSemester = userData!['isBiSemester'] ?? true;
      _isDayShift = userData!['isDayShift'] ?? true;
      _selectedBloodGroup = userData!['bloodGroup'];
      _profilePicture = userData!['profilePicture'];
      _idCardImage = userData!['idCardImage'];
    }
  }

  Future<void> _pickImage(bool isProfilePicture) async {
    try {
      final status = await Permission.storage.request();
      final cameraStatus = await Permission.camera.request();

      if (status.isDenied || cameraStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied to access photos')),
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
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() {
          if (isProfilePicture) {
            _profilePicture = base64Image;
          } else {
            _idCardImage = base64Image;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);
    try {
      final updatedData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNo': _phoneController.text.trim(),
        'rollNo': _rollNumberController.text.trim(),
        'batchNo': _batchNumberController.text.trim(),
        'registrationNo':
            _registrationNumberController.text.trim().toUpperCase(),
        'deptName': _departmentController.text.trim().toUpperCase(),
        'semesterNo': _semesterController.text.trim(),
        'isBiSemester': _isBiSemester,
        'isDayShift': _isDayShift,
        'bloodGroup': _selectedBloodGroup,
        'profilePicture': _profilePicture ?? '',
        'idCardImage': _idCardImage ?? '',
      };

      await UserDataProvider.updateUserData(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSaving = false);
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
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
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
            "Personal Information",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProfilePictureSection(),
            SizedBox(height: 20.h),
            _buildInputFields(),
            SizedBox(height: 20.h),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(true),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: Colors.grey[200],
                child: _profilePicture != null
                    ? ClipOval(
                        child: Image.memory(
                          base64Decode(_profilePicture!),
                          fit: BoxFit.cover,
                          width: 100.r,
                          height: 100.r,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.person, size: 50.r),
                        ),
                      )
                    : Icon(Icons.person, size: 50.r),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Color(0xff6686F6),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.camera_alt, color: Colors.white, size: 20.r),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Tap to change profile picture",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(_firstNameController, "First Name"),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _buildTextField(_lastNameController, "Last Name"),
            ),
          ],
        ),

        _buildTextField(_phoneController, "Phone Number",
            keyboardType: TextInputType.phone),
        // Roll and Batch in same row
        Row(
          children: [
            Expanded(
              child: _buildTextField(_rollNumberController, "Roll Number",
                  keyboardType: TextInputType.number),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _buildTextField(_batchNumberController, "Batch Number"),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildTextField(_registrationNumberController, "Registration Number"),
        // Department and Semester in same row
        Row(
          children: [
            Expanded(
              child: _buildTextField(_departmentController, "Department"),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _buildTextField(_semesterController, "Semester",
                  keyboardType: TextInputType.number),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildBloodGroupDropdown(),
        _buildSwitches(),
        SizedBox(height: 5.h),
        _buildIdCardSection(),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    bool isInRow = label == "Roll Number" ||
        label == "Batch Number" ||
        label == "Department" ||
        label == "Semester";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Coloris.text_color,
            fontSize: 16.sp,
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
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: TextStyle(
                color: Coloris.text_color.withOpacity(0.5),
                fontSize: 14.sp,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xff6686F6), width: 1),
              ),
              filled: true,
              fillColor: Coloris.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ),
        // Only add bottom spacing if not in a row
        if (!isInRow) SizedBox(height: 15.h),
      ],
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Blood Group",
          style: TextStyle(
            color: Coloris.text_color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Coloris.text_color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedBloodGroup,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
              border: InputBorder.none,
            ),
            items: _bloodGroups.map((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Text(group),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() => _selectedBloodGroup = newValue);
            },
          ),
        ),
        SizedBox(height: 15.h),
      ],
    );
  }

  Widget _buildSwitches() {
    return Row(
      children: [
        _buildSwitchField(
          label: "Semester Type",
          value: _isBiSemester,
          onChanged: (value) {
            setState(() => _isBiSemester = value);
          },
          trueLabel: "Bi-Semester",
          falseLabel: "Tri-Semester",
        ),
        SizedBox(width: 15.w),
        _buildSwitchField(
          label: "Shift",
          value: _isDayShift,
          onChanged: (value) {
            setState(() => _isDayShift = value);
          },
          trueLabel: "Day",
          falseLabel: "Evening",
        ),
      ],
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required String trueLabel,
    required String falseLabel,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Color(0xff6686F6),
              ),
              Text(
                value ? trueLabel : falseLabel,
                style: TextStyle(
                  color: Coloris.text_color,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ID Card Image",
          style: TextStyle(
            color: Coloris.text_color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _pickImage(false),
          child: Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Coloris.text_color.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _idCardImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(_idCardImage!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate,
                          size: 50.sp, color: Colors.grey),
                      Text(
                        "Tap to upload ID Card",
                        style: TextStyle(
                          color: Coloris.text_color.withOpacity(0.5),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: isSaving ? null : _saveChanges,
      child: Container(
        width: double.infinity,
        height: 45.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xff6686F6), Color(0xff60BBEF)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff6686F6).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isSaving ? "Saving..." : "Save Changes",
            style: TextStyle(
              color: Coloris.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _rollNumberController.dispose();
    _batchNumberController.dispose();
    _registrationNumberController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    super.dispose();
  }
}
