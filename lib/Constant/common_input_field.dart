import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color_is.dart';

class InputFieldCommon extends StatelessWidget {
  final String fieldText;
  final String titleText;
  final int? maxLines;
  final bool hasDropDownIcon;
  final TextEditingController Controller;

  const InputFieldCommon({
    Key? key,
    required this.titleText,
    required this.fieldText,
    this.maxLines,
    this.hasDropDownIcon = false,
    required this.Controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(
            titleText,
            style: const TextStyle(
              color: Coloris.text_color,
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Coloris.text_color,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: Controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Coloris.text_color,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Coloris.primary_color,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: fieldText,
                    contentPadding: const EdgeInsets.only(
                        left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
                    hintStyle: const TextStyle(
                      color: Coloris.secondary_color,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  maxLines: maxLines,
                ),
              ),
              if (hasDropDownIcon)
                const Icon(Icons.arrow_drop_down,
                    color: Coloris.secondary_color),
            ],
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
