import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Stack(
        children: [
          _buildHeader(context),
          Positioned(
            top: _calculateContainerTopPosition(context),
            left: _calculateContainerMiddlePosition(context),
            right: _calculateContainerMiddlePosition(context),
            child: _buildRedContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 460.h,
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  _buildAvatarAndUserInfo(),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 50.h),
        Expanded(child: _buildListView()),
      ],
    );
  }

  Widget _buildAvatarAndUserInfo() {
    return Column(
      children: [
        const PositionWithName(
          pos: 1,
          name: "Hey_Sifu",
          point: 1350,
          color: Colors.orange,
          image: "sifat.jpg",
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const PositionWithName(
              pos: 2,
              name: "Rakib3_",
              point: 1300,
              color: Colors.white,
              image: "rakib.png",
            ),
            SizedBox(width: 20.w),
            const PositionWithName(
              pos: 3,
              name: "Ifram96",
              point: 1290,
              color: Colors.brown,
              image: "ifram.jpg",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRedContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      alignment: Alignment.center,
      height: 55.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            color: Colors.grey,
          ),
          SizedBox(width: 10.w),
          Text(
            "Search for user",
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateContainerTopPosition(BuildContext context) {
    return ScreenUtil().screenHeight * 0.46;
  }

  double _calculateContainerMiddlePosition(BuildContext context) {
    return ScreenUtil().screenWidth * 0.22;
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      itemCount: 20,
      itemBuilder: (context, index) {
        return const Column(
          children: [
            ListTile(
              title: Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Text("User_name"),
              ),
              leading: CircleAvatar(
                radius: 25.0,
                backgroundColor: Colors.red,
              ),
              trailing: CircleAvatar(
                radius: 15.0,
                backgroundColor: Colors.green,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: DottedDivider(),
            ),
          ],
        );
      },
    );
  }
}

class PositionWithName extends StatelessWidget {
  final int pos;
  final String name;
  final int point;
  final Color color;
  final String image;

  const PositionWithName({
    Key? key,
    required this.pos,
    required this.name,
    required this.point,
    required this.color,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$pos",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        CircleAvatar(
          radius: 42.0,
          backgroundColor: color,
          child: CircleAvatar(
            radius: 38.0,
            backgroundImage: AssetImage("assets/avatars/$image"),
          ),
        ),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        Text(
          "$point",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class DottedDivider extends StatelessWidget {
  const DottedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (width / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
