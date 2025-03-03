import 'package:diu/Constant/backend/CRUD.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:diu/Constant/common_input_field.dart';
import 'package:diu/pages/home_page/Support/Supoport_Success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Support extends StatelessWidget {
  Support({Key? key}) : super(key: key);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController rollController = TextEditingController();
  final TextEditingController helpController = TextEditingController();

  //add firebase firestore

  final firestoreService fireStoreSupport = firestoreService();
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
          "Support",
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
                titleText: "Select Club: ",
                fieldText: "Select a club from the list",
                // hasDropDownIcon: true,
              ),
              SizedBox(height: 10.h),
              InputFieldCommon(
                Controller: nameController,
                titleText: "Full Name: ",
                fieldText: "Ex: Sifatullah Haque",
              ),
              InputFieldCommon(
                Controller: phoneController,
                titleText: "Mobile No: ",
                fieldText: "Ex: 018********",
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
                Controller: helpController,
                titleText: "Ask for help: ",
                fieldText: "Enter your text here...",
                maxLines: 6,
              ),
              SizedBox(height: 10.h),
              Center(
                child: GestureDetector(
                  onTap: () {
                    fireStoreSupport.addSupport(
                        nameController.text,
                        phoneController.text,
                        batchController.text,
                        rollController.text,
                        helpController.text);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SupportSuccess(),
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
        decoration: BoxDecoration(
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
