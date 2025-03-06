import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Cafeteria extends StatelessWidget {
  const Cafeteria({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildMenuList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            "Cafeteria",
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w600,
              color: Coloris.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      itemCount: 10, // Replace with your actual item count
      itemBuilder: (context, index) {
        return _buildMenuItem();
      },
    );
  }

  Widget _buildMenuItem() {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Coloris.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Container(
              height: 100.h,
              width: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage("assets/images/burger.jpg"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chicken Burger",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Coloris.text_color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "A delicious burger with chicken patty and fresh vegetables",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Coloris.text_color.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "150 BDT",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff6686F6),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Coloris.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
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
