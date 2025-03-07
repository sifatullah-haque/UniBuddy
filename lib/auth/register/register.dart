import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future register() async {
    if (!passConfirm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Add user details
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNo': int.tryParse(_phoneController.text.trim()) ?? 0,
        'rollNo': int.tryParse(_rollNumberController.text.trim()) ?? 0,
        'batchNo': _batchNumberController.text.trim(),
        'registrationNo': _registrationNumberController.text.trim(),
        'deptName': _departmentController.text.trim(),
        'semesterNo': _semesterController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for this email';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during registration')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool passConfirm() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Coloris.backgroundColor,
        toolbarHeight: 0,
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: Coloris.backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),
                Image.asset(
                  "assets/svg/diu.png",
                  height: 100.h,
                ),
                SizedBox(height: 30.h),
                Text(
                  "Create an Account",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: InputTextField(
                        fieldTextController: _firstNameController,
                        labelText: "First Name",
                        hintText: "Sifatullah",
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: InputTextField(
                        fieldTextController: _lastNameController,
                        labelText: "Last Name",
                        hintText: "Haque",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                InputTextField(
                  fieldTextController: _phoneController,
                  hintText: "018XXXXXXXX",
                  labelText: "Phone No.",
                  prefixIcon: Icons.phone,
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: InputTextField(
                        fieldTextController: _rollNumberController,
                        labelText: "Roll No.",
                        hintText: "10",
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: InputTextField(
                        fieldTextController: _batchNumberController,
                        labelText: "Batch No.",
                        hintText: "D-78(A)",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                InputTextField(
                  fieldTextController: _registrationNumberController,
                  hintText: "CS-D-78-22-120***",
                  labelText: "Registration No.",
                  prefixIcon: Icons.format_align_center_rounded,
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: InputTextField(
                        fieldTextController: _departmentController,
                        labelText: "Dept. Name.",
                        hintText: "CSE",
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: InputTextField(
                        fieldTextController: _semesterController,
                        labelText: "Semester No.",
                        hintText: "5",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                InputTextField(
                  fieldTextController: _emailController,
                  hintText: "Enter Your Email",
                  labelText: "Email",
                  prefixIcon: Icons.email_rounded,
                ),
                SizedBox(height: 20.h),
                InputTextField(
                  fieldTextController: _passwordController,
                  hintText: "Enter Your Password",
                  labelText: "Password",
                  prefixIcon: Icons.lock_rounded,
                  obscureText: _obscurePassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                SizedBox(height: 20.h),
                InputTextField(
                  fieldTextController: _confirmPasswordController,
                  hintText: "Confirm Password",
                  labelText: "Confirm Password",
                  prefixIcon: Icons.lock_rounded,
                  obscureText: _obscureConfirmPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                SizedBox(height: 20.h),
                Common_Button(
                  onpressed: _isLoading ? null : register,
                  text: _isLoading ? "Loading..." : "Register",
                  size: 150,
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Already a member?",
                        style: TextStyle(
                          color: Coloris.secondary_color,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Expanded(
                        child: Text(
                          "Login Now",
                          style: TextStyle(
                            color: Coloris.primary_color,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputTextField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final IconData? prefixIcon;
  final TextEditingController fieldTextController;
  final bool? obscureText;
  final VoidCallback? onToggleObscure;

  const InputTextField({
    Key? key,
    required this.fieldTextController,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.obscureText,
    this.onToggleObscure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: fieldTextController,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Coloris.text_color,
              )
            : null,
        suffixIcon: obscureText != null
            ? IconButton(
                icon: Icon(
                  obscureText! ? Icons.visibility_off : Icons.visibility,
                  color: Coloris.text_color,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Coloris.secondary_color,
          fontWeight: FontWeight.w400,
        ),
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 20.sp,
          color: Coloris.text_color,
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
    );
  }
}
