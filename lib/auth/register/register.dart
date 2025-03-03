import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterPage extends StatelessWidget {
  final VoidCallback showLoginPage;
  RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

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

  Future register() async {
    //login user
    if (passConfirm()) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    }

    //addUser
    await addUserDetails(
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      int.parse(_phoneController.text.trim()),
      int.parse(_rollNumberController.text.trim()),
      _batchNumberController.text.trim(),
      _registrationNumberController.text.trim(),
      _departmentController.text.trim(),
      _semesterController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  Future addUserDetails(
      String firstName,
      String lastName,
      int phoneNo,
      int rollNo,
      String batchNo,
      String registrationNo,
      String deptName,
      String semesterNo,
      String emailAdd,
      String pass) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'firstName': firstName,
      'lastName': lastName,
      'phoneNo': phoneNo,
      'rollNo': rollNo,
      'batchNo': batchNo,
      'registrationNo': registrationNo,
      'deptName': deptName,
      'semesterNo': semesterNo,
      'email': emailAdd,
      'password': pass,
    });
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
                ),
                SizedBox(height: 20.h),
                InputTextField(
                  fieldTextController: _confirmPasswordController,
                  hintText: "Confirm Password",
                  labelText: "Confirm Password",
                  prefixIcon: Icons.lock_rounded,
                ),
                SizedBox(height: 20.h),
                Common_Button(
                  onpressed: register,
                  text: "Register",
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
                      onTap: showLoginPage,
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

  const InputTextField({
    Key? key,
    required this.fieldTextController,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: fieldTextController,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Coloris.text_color,
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
