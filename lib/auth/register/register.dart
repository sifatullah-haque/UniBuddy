import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Convert to stateless widget
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
            // Gradient Header
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
            // Extract the form to a separate stateful widget
            RegisterForm(onRegistrationComplete: onRegistrationComplete),
          ],
        ),
      ),
    );
  }
}

// New stateful widget for the form
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

  @override
  void dispose() {
    // Clean up controllers
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
    // ...existing validation code...
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form fields with updated styling
          _buildFormFields(),
          SizedBox(height: 30.h),
          RegisterButton(
            onRegister: () async {
              if (!_validateInputs(context)) return;

              try {
                await FirebaseAuth.instance.signOut();

                // Generate user ID
                String userId = await _generateUserId();

                // Create auth user
                final userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );

                if (userCredential.user == null) {
                  throw Exception('User creation failed');
                }

                // Create Firestore document
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
                  'registrationNo': _registrationNumberController.text.trim(),
                  'deptName': _departmentController.text.trim(),
                  'semesterNo': _semesterController.text.trim(),
                  'email': _emailController.text.trim(),
                  'isEmailVerified': false,
                  'profilePicture': null,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                // Send verification email
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
          // Login link
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
    // ...existing form fields code...
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
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _rollNumberController,
                label: "Roll No.",
                hint: "10",
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    bool isPassword = false,
  }) {
    // Determine which password visibility state to use
    bool isObscured = isPassword;
    if (isPassword) {
      isObscured = controller == _passwordController
          ? _obscurePassword
          : _obscureConfirmPassword;
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

// Keep the RegisterButton as is
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
