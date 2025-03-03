import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:diu/pages/home_page/pure_home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JoinClubSuccess extends StatelessWidget {
  const JoinClubSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      appBar: AppBar(
        backgroundColor: Coloris.backgroundColor,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/svg/joined_club.png"),
                SizedBox(
                  height: 50.h,
                ),
                Column(
                  children: [
                    Text(
                      "Congratulation !",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 40.sp,
                        color: Coloris.text_color,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      "Thank you for signing up! We'll be in touch soon with more information  ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Coloris.secondary_color,
                          fontWeight: FontWeight.w300,
                          fontSize: 16.sp),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Common_Button(
                      text: "Go Home",
                      destination: HomePage(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 280.h,
                )
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Image.asset("assets/svg/button_svg.png"),
          )
        ],
      ),
    );
  }
}
