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
      body: Container(
        color: Coloris.backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 20.h),
              _buildCarousel(),
              SizedBox(height: 30.h),
              const SpecificPageGridviewWithIcons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25.0),
          bottomRight: Radius.circular(25.0),
        ),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff6686F6), Color(0xff60BBEF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 30.h),
              _buildLogoAndClubInfo(),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndClubInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 40.0,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage("assets/logos/CPC.png"),
        ),
        SizedBox(width: 20.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DIU Computer &",
              style: TextStyle(
                color: Coloris.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Programming Community",
              style: TextStyle(
                color: Coloris.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        height: 200.h,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
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
    );
  }
}
