import 'package:diu/pages/home_page/Bus_Schedule/busSchedule.dart';
import 'package:diu/pages/home_page/Cafeteria/cafeteria.dart';
import 'package:diu/pages/home_page/Certificate/certificate.dart';
import 'package:diu/pages/home_page/Class_Schedule/classSchedule.dart';
import 'package:diu/pages/home_page/Daily_Streak/daily_streak.dart';
import 'package:diu/pages/home_page/Emergency/emergency.dart';
import 'package:diu/pages/home_page/Events/events.dart';
import 'package:diu/pages/home_page/Idea/Idea.dart';
import 'package:diu/pages/home_page/Join_Club/join_club.dart';
import 'package:diu/pages/home_page/Leaderboard/leaderboard.dart';
import 'package:diu/pages/home_page/Lost_Item/lostItem.dart';
import 'package:diu/pages/home_page/Personal_Data/personal_data.dart';
import 'package:diu/pages/home_page/Support/Support.dart';
import 'package:diu/pages/home_page/Volunteer/volunteer.dart';
import 'package:diu/pages/home_page/calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GridviewWithIcons extends StatefulWidget {
  const GridviewWithIcons({
    super.key,
  });

  @override
  State<GridviewWithIcons> createState() => _GridviewWithIconsState();
}

class _GridviewWithIconsState extends State<GridviewWithIcons> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<List<Map<String, dynamic>>> _pages = [
    // First Page
    [
      {
        "title": "Cafeteria",
        "icon": "cafeteria",
        "destination": Cafeteria(),
      },
      {
        "title": "Bus Schedule",
        "icon": "bus",
        "destination": BusSchedule(),
      },
      {
        "title": "Join Club",
        "icon": "Join_Club",
        "destination": JoinClub(),
      },
      {
        "title": "Class Times",
        "icon": "Certificates",
        "destination": ClassSchedule(),
      },
      {
        "title": "Emergency",
        "icon": "emergency",
        "destination": Emergency(),
      },
      {
        "title": "Calendar",
        "icon": "Calendar",
        "destination": Calendar(),
      },
      {
        "title": "Lost Item",
        "icon": "lost",
        "destination": LostItem(),
      },
      {
        "title": "Events",
        "icon": "events",
        "destination": Events(),
      },
    ],
    // Second Page
    [
      {
        "title": "Join Club",
        "icon": "Join_Club",
        "destination": JoinClub(),
      },
      {
        "title": "Certificates",
        "icon": "Certificates",
        "destination": Certificate(),
      },
      {
        "title": "Volunteer",
        "icon": "Volunteer",
        "destination": Volunteer(),
      },
      {
        "title": "Personal Data",
        "icon": "Personal_Data",
        "destination": PersonalData(),
      },
      {
        "title": "Idea",
        "icon": "IDEA",
        "destination": Idea(),
      },
      {
        "title": "Support",
        "icon": "Support",
        "destination": Support(),
      },
      {
        "title": "Leaderboard",
        "icon": "Leaderboard",
        "destination": Leaderboard(),
      },
      {
        "title": "Daily Streak",
        "icon": "Daily_Streak",
        "destination": DailyStreak(),
      },
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          SizedBox(
            height: 240.h,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, pageIndex) {
                return GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8.0,
                    // mainAxisSpacing: 8.0,
                    childAspectRatio: 0.8,
                  ),
                  children: _pages[pageIndex].map((item) {
                    return GridViewIcons(
                      title: item["title"],
                      icon: item["icon"],
                      destination: item["destination"],
                    );
                  }).toList(),
                );
              },
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class GridViewIcons extends StatelessWidget {
  String title;
  String icon;
  final Widget destination;
  GridViewIcons({
    super.key,
    required this.icon,
    required this.title,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Column(
          children: [
            Image.asset(
              "assets/Icons/home_page/$icon.png",
              height: 50.h,
            ),
            Text(title, style: TextStyle(fontSize: 12.sp))
          ],
        ),
      ),
    );
  }
}
