import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecificPageGridviewWithIcons extends StatelessWidget {
  const SpecificPageGridviewWithIcons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // List of grid items
    final List<Map<String, String>> gridItems = [
      {"icon": "Coming_Events", "title": "Coming Events"},
      {"icon": "Running_Contest", "title": "Running Contest"},
      {"icon": "Talk", "title": "Talk"},
      {"icon": "Projects", "title": "Projects"},
      {"icon": "Challenges", "title": "Challenges"},
      {"icon": "Core_Members", "title": "Core Members"},
      {"icon": "Online_Seminar", "title": "Online Seminar"},
      {"icon": "Blog", "title": "Blog"},
      {"icon": "Discussion", "title": "Discussion"}
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          GridView.count(
            physics: NeverScrollableScrollPhysics(), // Disable scrolling
            shrinkWrap: true, // Use only the space needed
            crossAxisCount: 3,
            crossAxisSpacing: 15.w,
            mainAxisSpacing: 20.h,
            children: gridItems
                .map((item) => GridViewIcons(
                      icon: item["icon"]!,
                      title: item["title"]!,
                    ))
                .toList(),
          )
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
