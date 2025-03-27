import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:diu/auth/forgot_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onRegisterClick;
  const LoginPage({Key? key, required this.onRegisterClick}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> signIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // First, sign in with the provided credentials
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        // Store reference to the user before signing out
        User currentUser = userCredential.user!;

        // Ask user if they want a new verification email
        if (!mounted) return;
        final sendEmail = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Email Not Verified'),
            content: const Text(
                'Would you like to receive a new verification email?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Send Email'),
              ),
            ],
          ),
        );

        // If user wants a new verification email
        if (sendEmail == true) {
          try {
            // Send verification email while still signed in
            await currentUser.sendEmailVerification();

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Verification email sent. Please check your inbox.'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Failed to send verification email: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        // Sign out after handling verification
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(e.code)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Please try again later.';
      default:
        return 'Error: $code';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Coloris.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(25.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/svg/diu.png",
                    height: 80.h,
                  ),
                  SizedBox(height: 30.h),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Coloris.text_color.withOpacity(0.2)),
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
                  SizedBox(height: 20.h),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Coloris.text_color.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.lock_rounded, color: Color(0xff6686F6)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Color(0xff6686F6),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintText: "Enter Your Password",
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
                  SizedBox(height: 15.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassword()));
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xff6686F6),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  GestureDetector(
                    onTap: _isLoading ? null : signIn,
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
                          _isLoading ? "Loading..." : "Login",
                          style: TextStyle(
                            color: Coloris.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member yet?",
                        style: TextStyle(
                          color: Coloris.text_color.withOpacity(0.7),
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      GestureDetector(
                        onTap: widget.onRegisterClick,
                        child: Text(
                          "Register Now",
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
            ),
          ],
        ),
      ),
    );
  }
}
