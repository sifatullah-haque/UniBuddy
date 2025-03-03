// import 'dart:ui';

// import 'package:diu/Constant/color_is.dart';
// import 'package:diu/pages/home_page/Certificate/certificate.dart';
// import 'package:diu/pages/home_page/Join_Club/join_club.dart';
// import 'package:diu/pages/home_page/Leaderboard/leaderboard.dart';
// import 'package:diu/pages/home_page/pure_home_page/home_page.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// // Using secure storage

// class ButtonNavigator extends StatefulWidget {
//   const ButtonNavigator({Key? key}) : super(key: key);

//   @override
//   State<ButtonNavigator> createState() => _ButtonNavigatorState();
// }

// class _ButtonNavigatorState extends State<ButtonNavigator> {
//   int _selectedIndex = 0;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkAuthToken();
//   }

//   void _checkAuthToken() {
//     // Add your authentication token check logic here
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     final List<Widget> _widgetOptions = <Widget>[
//       HomePage(),
//       Leaderboard(),
//       JoinClub(),
//       Certificate(),
//     ];

//     return Scaffold(
//       backgroundColor: Coloris.backgroundColor,
//       // Add AppBar with blue background
//       appBar: PreferredSize(
//         preferredSize:
//             Size.fromHeight(0), // Height 0 to just show the status bar color
//         child: AppBar(
//           backgroundColor:
//               Color(0xFF2962FF), // Use your app's primary blue color
//           elevation: 0,
//         ),
//       ),
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Main content
//           _widgetOptions.elementAt(_selectedIndex),

//           Positioned(
//             left: 16.w,
//             right: 16.w,
//             bottom: MediaQuery.of(context).padding.bottom + 3.h,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.white.withOpacity(0.7), // White at the top center
//                     Color(0xff174BED).withOpacity(0.4), // Blue at the bottom
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//               padding: EdgeInsets.all(2), // Adjust for border thickness
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20.r),
//                 child: Container(
//                   height: 64.h,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                       colors: [
//                         Color(0xffD5DFFF).withOpacity(
//                             0.2), // Lower opacity for glassmorphic effect
//                         Color(0xff174BED).withOpacity(0.08),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(32.r),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 20,
//                         offset: const Offset(0, 4),
//                         spreadRadius: 0,
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15.r),
//                     child: Stack(
//                       children: [
//                         // Backdrop Filter for Blur Effect
//                         BackdropFilter(
//                           filter: ImageFilter.blur(
//                               sigmaX: 15, sigmaY: 15), // Adjust blur intensity
//                           child: Container(
//                             color: Colors
//                                 .transparent, // Ensures it remains see-through
//                           ),
//                         ),
//                         // Content Layer
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             _buildNavItem(
//                                 0,
//                                 'assets/Icons/home_page/Leaderboard.png',
//                                 'Home'),
//                             _buildNavItem(
//                                 1,
//                                 'assets/Icons/home_page/Leaderboard.png',
//                                 'Bookings'),
//                             _buildNavItem(
//                                 2,
//                                 'assets/Icons/home_page/Leaderboard.png',
//                                 'Notification'),
//                             _buildNavItem(
//                                 3,
//                                 'assets/Icons/home_page/Leaderboard.png',
//                                 'Profile'),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(int index, String icon, String label) {
//     return GestureDetector(
//       onTap: () => _onItemTapped(index),
//       behavior: HitTestBehavior.opaque,
//       child: Container(
//         width: 70.w,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               icon,
//               width: 24.w,
//               height: 24.h,
//               color: _selectedIndex == index
//                   ? Coloris.primary_color
//                   : Colors.white,
//             ),
//             SizedBox(height: 2.h),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: _selectedIndex == index
//                     ? Coloris.primary_color
//                     : Colors.white,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
