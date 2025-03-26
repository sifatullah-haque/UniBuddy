import 'package:diu/Constant/color_is.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(_getErrorMessage(e.code));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'invalid-email':
        return 'Please enter a valid email address';
      default:
        return 'An error occurred. Please try again later';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Link Sent'),
        content: Text('Please check your email to reset your password.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to login page
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Column(
        children: [
          // Header
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
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    color: Coloris.white,
                  ),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(25.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Forgot your password?",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Coloris.text_color,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Enter your email address to receive a password reset link",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Coloris.text_color.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 30.h),
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Coloris.text_color.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Color(0xff6686F6)),
                      hintText: "Enter Your Email",
                      hintStyle: TextStyle(
                        color: Coloris.text_color.withOpacity(0.5),
                        fontSize: 14.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w, vertical: 12.h),
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Color(0xff6686F6), width: 1),
                      ),
                      filled: true,
                      fillColor: Coloris.white,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                GestureDetector(
                  onTap: _isLoading ? null : resetPassword,
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
                        _isLoading ? "Sending..." : "Send Reset Link",
                        style: TextStyle(
                          color: Coloris.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
