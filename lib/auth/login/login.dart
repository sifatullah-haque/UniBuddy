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

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
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
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_rounded,
                          color: Coloris.text_color,
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
                      text: "Login",
                      onpressed: signIn,
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
