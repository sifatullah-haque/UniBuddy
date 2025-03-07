import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:diu/auth/forgot_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      // appBar: AppBar(
      //   toolbarHeight: 0,
      //   backgroundColor: Coloris.backgroundColor,
      //   elevation: 0,
      // ),
      resizeToAvoidBottomInset: true,
      backgroundColor: Coloris.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 150.h),
                    Image.asset(
                      "assets/svg/diu.png",
                      height: 100.h,
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      "Welcome Back !!!",
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 20.h),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Coloris.text_color,
                        ),
                        hintText: "Enter Your Email",
                        hintStyle: const TextStyle(
                          color: Coloris.secondary_color,
                          fontWeight: FontWeight.w400,
                        ),
                        label: Text(
                          "Email",
                          style: TextStyle(
                              fontSize: 20.sp, color: Coloris.text_color),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade600,
                            width: 1.0.w,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 1.5.w,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_rounded,
                          color: Coloris.text_color,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Coloris.text_color,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintText: "Enter Your Password",
                        hintStyle: const TextStyle(
                          color: Coloris.secondary_color,
                          fontWeight: FontWeight.w400,
                        ),
                        label: Text(
                          "Password",
                          style: TextStyle(
                              fontSize: 18.sp, color: Coloris.text_color),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade600,
                            width: 1.0.w,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 1.5.w,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPassword(),
                                ));
                          },
                          child: Text("Forgot Password?",
                              style: TextStyle(
                                  color: Coloris.primary_color,
                                  fontSize: 18.sp)),
                        )
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Common_Button(
                      text: _isLoading ? "Loading..." : "Login",
                      onpressed: _isLoading ? null : signIn,
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Text("Not a member yet?",
                            style: TextStyle(
                                color: Coloris.secondary_color,
                                fontSize: 18.sp)),
                        SizedBox(width: 10.w),
                        GestureDetector(
                          onTap: widget.showRegisterPage,
                          child: Text("Register Now",
                              style: TextStyle(
                                  color: Coloris.primary_color,
                                  fontSize: 18.sp)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            Image.asset("assets/svg/button_svg.png")
          ],
        ),
      ),
    );
  }
}
