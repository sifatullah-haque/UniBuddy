import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecificPageGridviewWithIcons extends StatelessWidget {
  const SpecificPageGridviewWithIcons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          SizedBox(
              height: 360.h,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    // childAspectRatio: 2 / 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 20.0),
                children: [
                  GridViewIcons(
                    title: "Coming Events",
                    icon: "Coming_Events",
                  ),
                  GridViewIcons(
                    icon: "Running_Contest",
                    title: "Running Contest",
                  ),
                  GridViewIcons(
                    icon: "Talk",
                    title: "Talk",
                  ),
                  GridViewIcons(
                    icon: "Projects",
                    title: "Projects",
                  ),
                  GridViewIcons(
                    icon: "Challenges",
                    title: "Challenges",
                  ),
                  GridViewIcons(
                    icon: "Core_Members",
                    title: "Core Members",
                  ),
                  GridViewIcons(
                    icon: "Online_Seminar",
                    title: "Online Seminar",
                  ),
                  GridViewIcons(
                    icon: "Blog",
                    title: "Blog",
                  ),
                  GridViewIcons(
                    icon: "Discussion",
                    title: "Discussion",
                  )
                ],
              ))
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class GridViewIcons extends StatelessWidget {
  String title;
  String icon;

  GridViewIcons({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => destination),
          // );
        },
        child: Column(
          children: [
            Image.asset(
              "assets/Icons/specific_club/$icon.png",
              height: 66.h,
            ),
            Text(title, style: TextStyle(fontSize: 12.sp))
          ],
        ),
      ),
    );
  }
}
