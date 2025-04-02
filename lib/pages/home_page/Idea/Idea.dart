import 'package:diu/Constant/backend/CRUD.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:diu/pages/home_page/Idea/Idea_Success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Idea extends StatefulWidget {
  Idea({Key? key}) : super(key: key);

  @override
  State<Idea> createState() => _IdeaState();
}

class _IdeaState extends State<Idea> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool isDayShift = true;
  bool isBiSemester = true;
  String? selectedClub;
  bool _isSubmitting = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController rollController = TextEditingController();
  final TextEditingController ideaController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();

  final firestoreService fireStoreIdea = firestoreService();

  final List<String> clubs = [
    'DIU Computer Programming Club',
    // 'DIU Career Development Club',
    // 'DIU Film & Photography Club',
    // 'DIU Sports Club',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            nameController.text =
                '${userData['firstName']} ${userData['lastName']}';
            phoneController.text = userData['phoneNo'] ?? '';
            batchController.text = userData['batchNo'] ?? '';
            rollController.text = userData['rollNo'] ?? '';
            userIdController.text = userData['userId'] ?? '';
            semesterController.text = userData['semesterNo'] ?? '';
            isDayShift = userData['isDayShift'] ?? true;
            isBiSemester = userData['isBiSemester'] ?? true;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitIdea() async {
    if (!_formKey.currentState!.validate() || selectedClub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create idea data
      final ideaData = {
        'userId': user.uid,
        'userDiuId': userIdController.text,
        'clubName': selectedClub,
        'name': nameController.text,
        'batch': batchController.text,
        'roll': rollController.text,
        'idea': ideaController.text,
        'phone': phoneController.text,
        'isDayShift': isDayShift,
        'isBiSemester': isBiSemester,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      await FirebaseFirestore.instance.collection('ideas').add(ideaData);

      // Navigate to success page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IdeaSuccess()),
      );
    } on FirebaseException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'permission-denied':
          errorMessage = 'You don\'t have permission to submit ideas';
          break;
        case 'unauthenticated':
          errorMessage = 'Please login again to submit your idea';
          break;
        default:
          errorMessage = 'Failed to submit idea: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildForm(),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xff6686F6),
                ),
              ),
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
            "Share Your Idea",
            style: TextStyle(
              fontSize: 22.sp,
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
              nameController,
              "Full Name",
              "Enter your full name",
              enabled: false,
            ),
            _buildInputField(
              userIdController,
              "User ID",
              "Your DIU ID",
              enabled: false,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    batchController,
                    "Batch",
                    "Ex: D-78",
                    enabled: false,
                    isHalfWidth: true,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildInputField(
                    rollController,
                    "Roll",
                    "Ex: 10",
                    enabled: false,
                    isHalfWidth: true,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildSwitchField(
                  "Semester Type",
                  isBiSemester,
                  (value) {
                    setState(() => isBiSemester = value);
                  },
                  "Bi-Semester",
                  "Tri-Semester",
                ),
                SizedBox(width: 20.w),
                _buildSwitchField(
                  "Shift",
                  isDayShift,
                  (value) {
                    setState(() => isDayShift = value);
                  },
                  "Day",
                  "Evening",
                ),
              ],
            ),
            _buildInputField(
              phoneController,
              "Phone Number",
              "01X-XXXXXXXX",
              keyboardType: TextInputType.phone,
              enabled: false,
            ),
            _buildInputField(
              ideaController,
              "Share your idea",
              "Enter your idea here...",
              maxLines: 6,
            ),
            SizedBox(height: 20.h),
            Center(
              child: GestureDetector(
                onTap: _isSubmitting ? null : _submitIdea,
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
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Submit Idea",
                            style: TextStyle(
                              color: Coloris.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
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
            fontSize: 14.sp,
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
            hint: Text("Select a club", style: TextStyle(fontSize: 12.sp)),
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
    bool enabled = true,
    int? maxLines,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Coloris.text_color.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: controller,
              style: TextStyle(
                // color: Coloris.text_color,
                fontSize: 14.sp,
              ),
              keyboardType: keyboardType,
              enabled: enabled,
              maxLines: maxLines ?? 1,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Coloris.text_color.withOpacity(0.5),
                  fontSize: 12.sp,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
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
                fillColor: enabled ? Coloris.white : Colors.grey.shade100,
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

  Widget _buildSwitchField(
    String label,
    bool value,
    Function(bool) onChanged,
    String trueLabel,
    String falseLabel,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 14.sp,
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
              Text(
                value ? trueLabel : falseLabel,
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
