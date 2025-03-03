import 'dart:async';
import 'package:flutter/material.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:diu/pages/home_page/Daily_Streak/daily_streak_success.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DailyStreak extends StatefulWidget {
  const DailyStreak({Key? key}) : super(key: key);

  @override
  _DailyStreakState createState() => _DailyStreakState();
}

class _DailyStreakState extends State<DailyStreak> {
  late int hours;
  late int minutes;
  late int seconds;
  late Timer timer;
  bool isTimerActive = false;
  bool isTimerFinished = false;

  @override
  void initState() {
    super.initState();
    // Initialize time values
    hours = 0;
    minutes = 0;
    seconds = 10;
    // Initialize the timer with a dummy timer
    timer = Timer(Duration.zero, () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Coloris.backgroundColor,
        title: Text(
          "Complete Streak",
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),
                Image.asset("assets/svg/Daily_Streak.png"),
                SizedBox(height: 30.h),
                Text(
                  "Time Left:",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 30.h),
                TimerDisplay(hours: hours, minutes: minutes, seconds: seconds),
                SizedBox(height: 30.h),
                if (isTimerActive && !isTimerFinished)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(
                        onPressed: pauseTimer,
                        icon: Icons.pause,
                        label: "Pause",
                      ),
                      SizedBox(width: 20.w),
                      _buildButton(
                        onPressed: resetTimer,
                        icon: Icons.restore,
                        label: "Reset",
                      ),
                    ],
                  )
                else if (!isTimerActive && !isTimerFinished)
                  _buildButton(
                    onPressed: startTimer,
                    icon: Icons.play_arrow,
                    label: "Start",
                  )
                else if (isTimerFinished)
                  Common_Button(
                      text: "Finish", destination: DailyStreakSuccess()),
                SizedBox(height: 30.h),
                Text(
                  "“Pursue what catches your heart, not what catches your eyes.”",
                  style: TextStyle(
                    color: Coloris.text_color,
                    fontSize: 17.sp,
                  ),
                ),
                Text(
                  " ― Roy T. Bennett",
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

  Widget _buildButton(
      {required VoidCallback onPressed,
      required IconData icon,
      required String label}) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        backgroundColor:
            MaterialStateProperty.all<Color>(Coloris.primary_color),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
      ),
    );
  }

  void startTimer() {
    setState(() {
      isTimerActive = true;
    });
    timer.cancel(); // Cancel previous timer if exists
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          if (minutes > 0) {
            minutes--;
            seconds = 59;
          } else {
            if (hours > 0) {
              hours--;
              minutes = 59;
              seconds = 59;
            } else {
              // Timer finished
              isTimerFinished = true;
              timer.cancel(); // Stop the timer
            }
          }
        }
      });
    });
  }

  void pauseTimer() {
    setState(() {
      isTimerActive = false;
    });
    timer.cancel();
  }

  void resetTimer() {
    setState(() {
      isTimerActive = false;
      hours = 0;
      minutes = 0;
      seconds = 10; // Reset seconds to 10
    });
    timer.cancel();
  }

  void finishTimer() {
    setState(() {
      isTimerFinished = true;
      hours = 0;
      minutes = 0;
      seconds = 0;
    });
    timer.cancel();
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
}

class TimerDisplay extends StatelessWidget {
  final int hours;
  final int minutes;
  final int seconds;

  const TimerDisplay({
    Key? key,
    required this.hours,
    required this.minutes,
    required this.seconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimerUnit(hours.toString().padLeft(2, '0'), 'Hour'),
        _buildTimerUnit(minutes.toString().padLeft(2, '0'), 'Minute'),
        _buildTimerUnit(seconds.toString().padLeft(2, '0'), 'Second'),
      ],
    );
  }

  Widget _buildTimerUnit(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Text(label),
        ],
      ),
    );
  }
}
