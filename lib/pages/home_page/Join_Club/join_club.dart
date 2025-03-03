import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:diu/pages/home_page/Join_Club/join_club_success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JoinClub extends StatelessWidget {
  const JoinClub({Key? key}) : super(key: key);

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
          "Join Cub",
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.w500,
            color: Coloris.text_color,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InputField(
                  titleText: "Select Club:",
                  fieldText: "Select a club from the list"),
              const InputField(
                titleText: "Full Name: ",
                fieldText: "Ex: Sifatullah Haque",
              ),
              const InputField(
                titleText: "Email address: ",
                fieldText: "Ex: yourname@gmail.com",
              ),
              Row(
                children: [
                  const Expanded(
                    child: InputField(
                      titleText: "Batch: ",
                      fieldText: "Ex: D-78",
                    ),
                  ),
                  SizedBox(width: 10.w),
                  const Expanded(
                    child: InputField(
                      titleText: "Roll: ",
                      fieldText: "Ex: 10",
                    ),
                  ),
                ],
              ),
              const InputField(
                  titleText: "Registration No.",
                  fieldText: "Ex: CS-D-78-22-****"),
              const RadioButton(
                radioTitle: "Semester Type:",
                firstOption: "Bi-Semester",
                secondOption: "Tri-Semester",
                value2: 1,
              ),
              const RadioButton(
                radioTitle: "Your Shift:",
                firstOption: "Day Shift",
                secondOption: "Evening Shift",
                value1: 1,
              ),
              const InputField(
                titleText: "Phone No:",
                fieldText: "018********",
              ),
              const RadioButton(
                  radioTitle: "Payment Type (Send Money)",
                  firstOption: "Bkash",
                  secondOption: "Nagad"),
              Text(
                "Bkash/Nagad Number for Payment 018********",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.sp),
              ),
              SizedBox(height: 10.h),
              const InputField(
                  titleText: "Transaction Id:", fieldText: "Ex: BBH31HXB5L"),
              const InputField(
                  titleText: "Fb Profile Link:",
                  fieldText: "Ex:  www.facebook.com/user.name"),
              const InputField(
                  titleText: "Interested In:",
                  fieldText: "Ex:  Programming, Networking"),
              const InputField(
                  titleText: "Expert In:",
                  fieldText: "ex:  Photography, Development"),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.h), // Adjust padding
                  child: const Common_Button(
                    text: "Submit",
                    destination: JoinClubSuccess(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/svg/button_svg.png"),
            fit: BoxFit.cover,
          ),
        ),
        height: 120.h, // Adjust the height as needed
      ),
    );
  }
}

class RadioButton extends StatelessWidget {
  final String radioTitle;
  final String firstOption;
  final String secondOption;
  final int? value1;
  final int? value2;
  const RadioButton({
    super.key,
    required this.radioTitle,
    required this.firstOption,
    required this.secondOption,
    this.value1,
    this.value2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(radioTitle),
        ),
        Row(
          children: [
            Row(
              children: [
                Radio(
                  value: value1,
                  groupValue: 1,
                  onChanged: (value) {},
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(firstOption),
              ],
            ),
            SizedBox(
              width: 10.w,
            ),
            Row(
              children: [
                Radio(
                  value: value2,
                  groupValue: 1,
                  onChanged: (value) {},
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(secondOption),
              ],
            )
          ],
        ),
        SizedBox(
          height: 10.h,
        )
      ],
    );
  }
}

class InputField extends StatelessWidget {
  final String fieldText;
  final String titleText;
  final int? maxLines;
  final bool hasDropDownIcon;

  const InputField({
    Key? key,
    required this.titleText,
    required this.fieldText,
    this.maxLines,
    this.hasDropDownIcon = false,
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
