import 'package:diu/Constant/color_is.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Certificate extends StatelessWidget {
  const Certificate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Coloris.backgroundColor,
        backgroundColor: Coloris.backgroundColor,
        surfaceTintColor: Coloris.backgroundColor,
        title: Text(
          "Certificate",
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.w500,
            color: Coloris.text_color,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            CertificateRow(
                title: "Certificate of Monthly Programming...",
                issue: "Issue: 25 January 2024"),
            SizedBox(height: 20.h),
            CertificateRow(
                title: "Best Photographer of DIU Film & Photo...",
                issue: "Issue: 13 February 2024"),
          ],
        ),
      ),
    );
  }
}

class CertificateRow extends StatelessWidget {
  final String title;
  final String issue;
  const CertificateRow({
    super.key,
    required this.title,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            width: 130.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Text(title),
              Text(
                issue,
                style: TextStyle(
                  color: Coloris.secondary_color,
                  fontSize: 15.sp,
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Icon(
            Icons.arrow_right_alt_rounded,
            color: Coloris.text_color,
          ),
        )
      ],
    );
  }
}
