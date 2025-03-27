import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:diu/pages/home_page/Join_Club/join_club_success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JoinClub extends StatefulWidget {
  const JoinClub({Key? key}) : super(key: key);

  @override
  State<JoinClub> createState() => _JoinClubState();
}

class _JoinClubState extends State<JoinClub> {
  final _formKey = GlobalKey<FormState>();
  String? selectedClub;
  bool isDayShift = true;
  bool isBiSemester = true;
  String paymentMethod = 'bkash';

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _batchController = TextEditingController();
  final _rollController = TextEditingController();
  final _registrationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _transactionController = TextEditingController();
  final _fbProfileController = TextEditingController();
  final _interestedInController = TextEditingController();
  final _expertInController = TextEditingController();

  // Dummy list of clubs - Replace with Firebase data later
  final List<String> clubs = [
    'DIU Computer Programming Club',
    'DIU Career Development Club',
    'DIU Film & Photography Club',
    'DIU Sports Club',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _batchController.dispose();
    _rollController.dispose();
    _registrationController.dispose();
    _phoneController.dispose();
    _transactionController.dispose();
    _fbProfileController.dispose();
    _interestedInController.dispose();
    _expertInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildForm(),
          ),
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
            "Join Club",
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

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField(),
            _buildInputField(
                _nameController, "Full Name", "Enter your full name"),
            _buildInputField(_emailController, "Email", "Enter your email",
                keyboardType: TextInputType.emailAddress),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(_batchController, "Batch", "Ex: D-78",
                      isHalfWidth: true),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildInputField(_rollController, "Roll", "Ex: 10",
                      isHalfWidth: true),
                ),
              ],
            ),
            _buildInputField(_registrationController, "Registration No.",
                "Ex: CS-D-78-22-****"),
            Row(
              children: [
                _buildSwitchField("Semester Type", isBiSemester, (value) {
                  setState(() => isBiSemester = value);
                }, "Bi-Semester", "Tri-Semester"),
                SizedBox(width: 20.w),
                _buildSwitchField("Shift", isDayShift, (value) {
                  setState(() => isDayShift = value);
                }, "Day", "Evening"),
              ],
            ),
            _buildInputField(_phoneController, "Phone Number", "01X-XXXXXXXX",
                keyboardType: TextInputType.phone),
            _buildPaymentSection(),
            _buildInputField(_transactionController, "Transaction ID",
                "Enter transaction ID"),
            _buildInputField(_fbProfileController, "Facebook Profile",
                "Your Facebook profile link"),
            _buildInputField(
                _interestedInController, "Interested In", "Your interests"),
            _buildInputField(
                _expertInController, "Expert In", "Your expertise"),
            SizedBox(height: 20.h),
            Center(
              child: GestureDetector(
                onTap: _submitForm,
                child: Container(
                  width: 250.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff6686F6).withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Submit Application",
                      style: TextStyle(
                        color: Coloris.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Club",
          style: TextStyle(
            color: Coloris.text_color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Coloris.text_color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedClub,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xff6686F6), width: 1),
              ),
            ),
            hint: Text("Select a club"),
            items: clubs.map((String club) {
              return DropdownMenuItem(
                value: club,
                child: Text(club),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() => selectedClub = value);
            },
            validator: (value) => value == null ? 'Please select a club' : null,
          ),
        ),
        SizedBox(height: 15.h),
      ],
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isHalfWidth = false,
    TextInputType? keyboardType,
  }) {
    // Check if this field should be uppercase
    bool isUppercaseField = (controller == _registrationController);

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Coloris.text_color.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textCapitalization: isUppercaseField
                  ? TextCapitalization.characters
                  : TextCapitalization.none,
              onChanged: (value) {
                if (isUppercaseField) {
                  final text = value.toUpperCase();
                  if (text != value) {
                    controller.value = controller.value.copyWith(
                      text: text,
                      selection: TextSelection.collapsed(offset: text.length),
                    );
                  }
                }
              },
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Coloris.text_color.withOpacity(0.5),
                  fontSize: 14.sp,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xff6686F6), width: 1),
                ),
                filled: true,
                fillColor: Coloris.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchField(String label, bool value, Function(bool) onChanged,
      String trueLabel, String falseLabel) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Color(0xff6686F6),
              ),
              Text(value ? trueLabel : falseLabel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Method",
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Radio(
                value: 'bkash',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() => paymentMethod = value.toString());
                },
              ),
              Text('Bkash'),
              Radio(
                value: 'nagad',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() => paymentMethod = value.toString());
                },
              ),
              Text('Nagad'),
            ],
          ),
          Text(
            "Payment Number: 01XXXXXXXXX",
            style: TextStyle(
              color: Colors.red,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Convert registration number to uppercase
      final registrationNo = _registrationController.text.trim().toUpperCase();

      // Update the controller with uppercase value
      _registrationController.text = registrationNo;

      // TODO: Implement Firebase submission
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JoinClubSuccess()),
      );
    }
  }
}
