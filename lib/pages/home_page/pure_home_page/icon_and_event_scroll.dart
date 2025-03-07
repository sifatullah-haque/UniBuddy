import 'package:diu/Constant/color_is.dart';
import 'package:diu/pages/Specific_Club/DIU_CPC/diu_cpc.dart';
import 'package:diu/pages/home_page/Events/event_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IconsAndEventScroll extends StatelessWidget {
  const IconsAndEventScroll({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "University Clubs",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          SizedBox(
            height: 6.h,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DiuCpc()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 55.h,
                    backgroundColor: Colors.transparent,
                    child: Image.asset("assets/logos/CPC.png"),
                  ),
                ),
                CircleAvatar(
                  radius: 55.h,
                  backgroundColor: Colors.transparent,
                  child: Image.asset("assets/logos/CDS.png"),
                ),
                SizedBox(
                  width: 7.w,
                ),
                CircleAvatar(
                  radius: 45.h,
                  backgroundColor: Colors.transparent,
                  child: Image.asset("assets/logos/FPC.png"),
                ),
                SizedBox(
                  width: 5.w,
                ),
                CircleAvatar(
                  radius: 45.h,
                  backgroundColor: Colors.transparent,
                  child: Image.asset("assets/logos/DIU.png"),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          const Text(
            "Upcoming Events",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 6.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _roundedImageContainer(
                    "assets/banner/events/event1.jpg", context),
                SizedBox(
                  width: 10.w,
                ),
                _roundedImageContainer("assets/banner/events/event2.jpg",
                    context), // Placeholder Container
                SizedBox(
                  width: 10.w,
                ),
                _roundedImageContainer(
                    "assets/banner/events/event3.jpg", context),
                SizedBox(
                  width: 10.w,
                ),
                _roundedImageContainer(
                    "assets/banner/events/event4.jpg", context),
                SizedBox(
                  width: 10.w,
                ),
                _roundedImageContainer("assets/banner/events/event5.jpg",
                    context), // Placeholder Container
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _roundedImageContainer(String? imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (imagePath != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetails(
                title: "Tech Fest 2024",
                imagePath: imagePath,
                date: "March 15, 2024",
                venue: "DIU Campus",
              ),
            ),
          );
        }
      },
      child: Container(
        height: 80.0,
        width: 135.0,
        decoration: BoxDecoration(
          color: Coloris.primary_color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              )
            : null,
      ),
    );
  }
}
