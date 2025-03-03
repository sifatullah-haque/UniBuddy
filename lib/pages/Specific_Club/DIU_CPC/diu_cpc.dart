import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/pages/Specific_Club/DIU_CPC/gridview_with_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiuCpc extends StatelessWidget {
  const DiuCpc({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 45.0,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage("assets/logos/CPC.png"),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(
                    "DIU Computer & \nProgramming Community",
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                  )
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                height: 200.h,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10.0), // Adjust the radius as needed
                  child: AnotherCarousel(
                    images: const [
                      AssetImage("assets/banner/specific_page/DOM.jpg"),
                      AssetImage("assets/banner/specific_page/BOM.jpg"),
                      AssetImage("assets/banner/specific_page/COM.jpg"),
                      AssetImage("assets/banner/specific_page/LOM.jpg"),
                    ],
                    dotBgColor: Colors.transparent,
                    dotColor: Coloris.primary_color,
                    dotSize: 10.0,
                    dotIncreasedColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 40.h,
              ),
              SpecificPageGridviewWithIcons(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/svg/button_svg.png"),
            fit: BoxFit.cover,
          ),
        ),
        height: 120.h, // Adjust the height as needed
      ),
    );
  }
}
