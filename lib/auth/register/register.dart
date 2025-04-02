import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';

class RegisterPage extends StatelessWidget {
  final VoidCallback onRegistrationComplete;

  const RegisterPage({Key? key, required this.onRegistrationComplete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                    "Create an account",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Coloris.white,
                    ),
                  ),
                ),
              ),
            ),
            RegisterForm(onRegistrationComplete: onRegistrationComplete),
          ],
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  final VoidCallback onRegistrationComplete;

  const RegisterForm({Key? key, required this.onRegistrationComplete})
      : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _departmentController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _semesterController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isBiSemester = true;
  bool _isDayShift = true;
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
  String? _selectedBloodGroup;
  File? _idCardImage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    _rollNumberController.dispose();
    _departmentController.dispose();
    _registrationNumberController.dispose();
    _batchNumberController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<String> _generateUserId() async {
    DocumentReference counterRef =
        FirebaseFirestore.instance.collection('counters').doc('userId');

    return FirebaseFirestore.instance
        .runTransaction<String>((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(counterRef);

      if (!snapshot.exists) {
        transaction.set(counterRef, {'current': 0});
        return 'DCMM-000001';
      }

      int currentNumber =
          (snapshot.data() as Map<String, dynamic>)['current'] + 1;
      transaction.update(counterRef, {'current': currentNumber});

      return 'DCMM-' + currentNumber.toString().padLeft(6, '0');
    });
  }

  bool _validateInputs(BuildContext context) {
    if (_emailController.text.trim().isEmpty) {
      _showError(context, 'Please enter your email');
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text.trim())) {
      _showError(context, 'Please enter a valid email address');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _showError(context, 'Please enter a password');
      return false;
    }

    if (_passwordController.text.length < 6) {
      _showError(context, 'Password must be at least 6 characters long');
      return false;
    }

    if (_firstNameController.text.trim().isEmpty) {
      _showError(context, 'Please enter your first name');
      return false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      _showError(context, 'Please enter your last name');
      return false;
    }

    if (!passConfirm()) {
      _showError(context, 'Passwords do not match');
      return false;
    }

    return true;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool passConfirm() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
  }

  Future<void> _pickIdCardImage() async {
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
        setState(() {
          _idCardImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormFields(),
          SizedBox(height: 30.h),
          RegisterButton(
            onRegister: () async {
              if (!_validateInputs(context)) return;

              try {
                await FirebaseAuth.instance.signOut();

                String userId = await _generateUserId();

                final userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );

                if (userCredential.user == null) {
                  throw Exception('User creation failed');
                }

                String? idCardBase64;
                if (_idCardImage != null) {
                  final bytes = await _idCardImage!.readAsBytes();
                  idCardBase64 = base64Encode(bytes);
                }

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userCredential.user!.uid)
                    .set({
                  'userId': userId,
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
                  'email': _emailController.text.trim(),
                  'isEmailVerified': false,
                  'profilePicture': '',
                  'createdAt': FieldValue.serverTimestamp(),
                  'bloodGroup': _selectedBloodGroup,
                  'idCardImage': idCardBase64,
                });

                await userCredential.user!.sendEmailVerification();
                await FirebaseAuth.instance.signOut();

                widget.onRegistrationComplete();
              } catch (e) {
                _showError(context, 'Registration failed: ${e.toString()}');
              }
            },
            controllers: {
              'email': _emailController,
              'password': _passwordController,
              'firstName': _firstNameController,
              'lastName': _lastNameController,
              'phone': _phoneController,
              'confirmPassword': _confirmPasswordController,
              'rollNumber': _rollNumberController,
              'department': _departmentController,
              'registrationNumber': _registrationNumberController,
              'batchNumber': _batchNumberController,
              'semester': _semesterController,
            },
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: TextStyle(
                  color: Coloris.text_color.withOpacity(0.7),
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: widget.onRegistrationComplete,
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Color(0xff6686F6),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _firstNameController,
                label: "First Name",
                hint: "Enter your first name",
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _buildInputField(
                controller: _lastNameController,
                label: "Last Name",
                hint: "Enter your last name",
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildInputField(
          controller: _phoneController,
          label: "Phone No.",
          hint: "018XXXXXXXX",
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _rollNumberController,
                label: "Roll No.",
                hint: "10",
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _buildInputField(
                controller: _batchNumberController,
                label: "Batch No.",
                hint: "D-78(A)",
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildInputField(
          controller: _registrationNumberController,
          label: "Registration No.",
          hint: "CS-D-78-22-120***",
          prefixIcon: Icons.format_align_center_rounded,
        ),
        SizedBox(height: 15.h),
        _buildInputField(
          controller: _departmentController,
          label: "Dept. Name.",
          hint: "CSE",
        ),
        SizedBox(height: 15.h),
        _buildInputField(
          controller: _semesterController,
          label: "Semester No.",
          hint: "5",
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 15.h),
        Row(
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
        ),
        SizedBox(height: 15.h),
        Column(
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
                hint: Text("Select Blood Group"),
                items: _bloodGroups.map((String group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBloodGroup = newValue;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Upload DIU ID Card",
              style: TextStyle(
                color: Coloris.text_color,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _pickIdCardImage,
              child: Container(
                height: 150.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Coloris.text_color.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _idCardImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_idCardImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 50.sp, color: Colors.grey),
                          SizedBox(height: 10.h),
                          Text(
                            "Upload ID Card Image",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildInputField(
          controller: _emailController,
          label: "Email",
          hint: "Enter Your Email",
          prefixIcon: Icons.email_rounded,
        ),
        SizedBox(height: 15.h),
        _buildInputField(
          controller: _passwordController,
          label: "Password",
          hint: "Enter Your Password",
          prefixIcon: Icons.lock_rounded,
          isPassword: true,
        ),
        SizedBox(height: 15.h),
        _buildInputField(
          controller: _confirmPasswordController,
          label: "Confirm Password",
          hint: "Confirm Password",
          prefixIcon: Icons.lock_rounded,
          isPassword: true,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    bool isObscured = isPassword;
    if (isPassword) {
      isObscured = controller == _passwordController
          ? _obscurePassword
          : _obscureConfirmPassword;
    }

    TextCapitalization capitalization = TextCapitalization.none;
    if (controller == _registrationNumberController ||
        controller == _departmentController) {
      capitalization = TextCapitalization.characters;
    }

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
            obscureText: isPassword ? isObscured : false,
            keyboardType: keyboardType,
            textCapitalization: capitalization,
            onChanged: (value) {
              if (controller == _registrationNumberController ||
                  controller == _departmentController) {
                final text = value.toUpperCase();
                if (text != value) {
                  controller.value = controller.value.copyWith(
                    text: text,
                    selection: TextSelection.collapsed(offset: text.length),
                  );
                }
              }
            },
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: Color(0xff6686F6))
                  : null,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isObscured ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xff6686F6),
                      ),
                      onPressed: () {
                        setState(() {
                          if (controller == _passwordController) {
                            _obscurePassword = !_obscurePassword;
                          } else if (controller == _confirmPasswordController) {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          }
                        });
                      },
                    )
                  : null,
              hintText: hint,
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
          ),
        ),
      ],
    );
  }
}

class RegisterButton extends StatefulWidget {
  final Function onRegister;
  final Map<String, TextEditingController> controllers;

  const RegisterButton({
    Key? key,
    required this.onRegister,
    required this.controllers,
  }) : super(key: key);

  @override
  State<RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<RegisterButton> {
  bool _isLoading = false;

  void _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      await widget.onRegister();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleRegister,
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
            _isLoading ? "Creating Account..." : "Register",
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
}
