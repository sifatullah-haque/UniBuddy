import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomTabBar extends StatelessWidget {
  CustomTabBar({Key? key}) : super(key: key);
  bool? ischecked = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Coloris.primary_color,
              labelColor: Coloris.primary_color,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  text: "Login",
                ),
                Tab(
                  text: "Register",
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLoginTab(context),
                  _buildRegistrationTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.mail_outline_rounded),
              prefixIconColor: Coloris.secondary_color,
              hintText: "Email Address",
              hintStyle: TextStyle(
                  color: Coloris.secondary_color, fontWeight: FontWeight.w400),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Coloris.primary_color)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Coloris.secondary_color)),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock_outline_rounded),
              prefixIconColor: Coloris.secondary_color,
              suffixIcon: Icon(Icons.remove_red_eye_outlined),
              suffixIconColor: Coloris.secondary_color,
              hintText: "Password",
              hintStyle: TextStyle(
                  color: Coloris.secondary_color, fontWeight: FontWeight.w400),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Coloris.primary_color)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Coloris.secondary_color)),
            ),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Forgot Password?",
              style: TextStyle(color: Coloris.primary_color, fontSize: 15.sp),
            ),
          ),
          const SizedBox(height: 15),
          Common_Button(
            text: "Login",
            onpressed: signIn,
          ),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }

  Widget _buildRegistrationTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          const SizedBox(height: 20),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Perform registration action
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
