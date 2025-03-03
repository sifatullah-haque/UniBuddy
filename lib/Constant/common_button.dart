import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'color_is.dart';

class Common_Button extends StatelessWidget {
  final int? size;
  final String text;
  final Widget? destination;
  final Function? onpressed; // Destination screen widget
  const Common_Button({
    Key? key,
    required this.text,
    this.destination,
    this.onpressed,
    this.size, // Destination screen widget parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size != null ? size!.w : 200.w,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(Coloris.primary_color),
        ),
        onPressed: () {
          // Navigate to the destination screen when the button is pressed
          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination!),
            );
          } else if (onpressed != null) {
            onpressed!();
          } else {
            print("No destination or onpressed function found");
          }
        },
        child: Text(
          text,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 18.sp),
        ),
      ),
    );
  }
}
