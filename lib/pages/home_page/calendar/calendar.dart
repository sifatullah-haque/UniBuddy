import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Helper function to normalize date (remove time component)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Modified events map with normalized dates
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2024, DateTime.now().month, DateTime.now().day): [
      {'title': 'Software Engineering Class', 'type': 'class'},
      {'title': 'Database Assignment Due', 'type': 'assignment'}
    ],
    DateTime(2024, DateTime.now().month, DateTime.now().day + 2): [
      {'title': 'Mobile App Development Class', 'type': 'class'}
    ],
    DateTime(2024, DateTime.now().month, DateTime.now().day + 5): [
      {'title': 'Project Presentation', 'type': 'assignment'}
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildCalendar(),
          _buildEventsList(),
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
            "Calendar",
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

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.all(20.w),
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
      child: TableCalendar(
        firstDay:
            DateTime.now().subtract(const Duration(days: 365)), // 1 year ago
        lastDay:
            DateTime.now().add(const Duration(days: 365)), // 1 year in future
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        eventLoader: _getEventsForDay,
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: Color(0xff6686F6),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: const Color(0xff60BBEF),
            borderRadius: BorderRadius.circular(4),
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xff6686F6).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Coloris.text_color,
          ),
          formatButtonVisible: false,
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _getEventMarkers(date),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  // Helper method to get event markers
  List<Container> _getEventMarkers(DateTime day) {
    final events = _events[_normalizeDate(day)] ?? [];
    return events.map((event) {
      return Container(
        width: 8.w,
        height: 8.h,
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: event['type'] == 'class'
              ? const Color(0xff4CAF50) // Green for classes
              : const Color(0xffF44336), // Red for assignments
        ),
      );
    }).toList();
  }

  Widget _buildEventsList() {
    final eventsForDay = _getEventsForDay(_selectedDay);

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Schedule for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xff6686F6),
              ),
            ),
            SizedBox(height: 15.h),
            Expanded(
              child: eventsForDay.isEmpty
                  ? Center(
                      child: Text(
                        "You have no classes or assignments today",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Coloris.text_color.withOpacity(0.7),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: eventsForDay.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(eventsForDay[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
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
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: event['type'] == 'class'
                  ? const Color(0xff4CAF50)
                  : const Color(0xffF44336),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      event['title'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Coloris.text_color,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: event['type'] == 'class'
                            ? const Color(0xff4CAF50).withOpacity(0.1)
                            : const Color(0xffF44336).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event['type'] == 'class' ? 'Class' : 'Assignment',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: event['type'] == 'class'
                              ? const Color(0xff4CAF50)
                              : const Color(0xffF44336),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  "Room 401 • 9:30 AM",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Coloris.text_color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modify the eventLoader to use normalized dates
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }
}
