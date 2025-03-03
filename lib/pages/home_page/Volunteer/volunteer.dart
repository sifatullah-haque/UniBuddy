import 'package:diu/Constant/backend/CRUD.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:diu/Constant/common_input_field.dart';

import 'package:diu/pages/home_page/Volunteer/Volunteer_Success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Volunteer extends StatelessWidget {
  Volunteer({Key? key}) : super(key: key);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController rollController = TextEditingController();
  final TextEditingController regController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  //get the firestore service

  final firestoreService fireStoreVolunteer = firestoreService();

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
          "Be a volunteer",
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
              InputFieldCommon(
                Controller: nameController,
                titleText: "Full Name: ",
                fieldText: "Ex: Sifatullah Haque",
              ),
              InputFieldCommon(
                Controller: emailController,
                titleText: "Email address: ",
                fieldText: "Ex: yourname@gmail.com",
              ),
              Row(
                children: [
                  Expanded(
                    child: InputFieldCommon(
                      Controller: batchController,
                      titleText: "Batch: ",
                      fieldText: "Ex: D-78",
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: InputFieldCommon(
                      Controller: rollController,
                      titleText: "Roll: ",
                      fieldText: "Ex: 10",
                    ),
                  ),
                ],
              ),
              InputFieldCommon(
                  Controller: regController,
                  titleText: "Registration No.",
                  fieldText: "Ex: CS-D-78-22-****"),
              SizedBox(
                height: 10.h,
              ),
              InputFieldCommon(
                  Controller: semesterController,
                  titleText: "Semester Type",
                  fieldText: "Tri-Semester"),
              SizedBox(
                height: 10.h,
              ),
              InputFieldCommon(
                  Controller: phoneController,
                  titleText: "Phone No:",
                  fieldText: "018********"),
              SizedBox(height: 10.h),
              Center(
                child: GestureDetector(
                  onTap: () {
                    fireStoreVolunteer.addVolunteer(
                        nameController.text,
                        emailController.text,
                        batchController.text,
                        rollController.text,
                        regController.text,
                        semesterController.text,
                        phoneController.text);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VolunteerSuccess(),
                      ),
                    );
                  },
                  child: Container(
                    height: 50.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Coloris.primary_color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              )
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
  const RadioButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text("Semester Type:"),
        ),
        SizedBox(
          height: 10.h,
        ),
        Row(
          children: [
            Row(
              children: [
                Radio(
                  value: 0,
                  groupValue: 1,
                  onChanged: (value) {},
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text("Bi-Semester"),
              ],
            ),
            SizedBox(
              width: 10.w,
            ),
            Row(
              children: [
                Radio(
                  value: 1,
                  groupValue: 1,
                  onChanged: (value) {},
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text("Tri-Semester"),
              ],
            )
          ],
        ),
      ],
    );
  }
}
