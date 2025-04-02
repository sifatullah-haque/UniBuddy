import 'package:diu/Constant/color_is.dart';
import 'package:diu/Constant/common_button.dart';
import 'package:diu/pages/home_page/Join_Club/join_club_success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isLoading = true;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userIdController =
      TextEditingController(); // New controller for userID
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
            // Pre-fill form with user data
            _nameController.text =
                '${userData['firstName']} ${userData['lastName']}';
            _emailController.text = userData['email'] ?? '';
            _userIdController.text = userData['userId'] ?? ''; // Load userID
            _batchController.text = userData['batchNo'] ?? '';
            _rollController.text = userData['rollNo'] ?? '';
            _registrationController.text = userData['registrationNo'] ?? '';
            _phoneController.text = userData['phoneNo'] ?? '';

            // Set toggle values based on user data
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _userIdController.dispose(); // Dispose of the new controller
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

  Future<bool> _saveToFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You must be logged in to apply for a club')),
        );
        return false;
      }

      setState(() {
        _isLoading = true;
      });

      // Create application data
      final applicationData = {
        'userId': currentUser.uid,
        'userDiuId':
            _userIdController.text.trim(), // Include the userID in the data
        'clubName': selectedClub,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'batch': _batchController.text.trim(),
        'roll': _rollController.text.trim(),
        'registrationNo': _registrationController.text.trim().toUpperCase(),
        'isDayShift': isDayShift,
        'isBiSemester': isBiSemester,
        'phoneNumber': _phoneController.text.trim(),
        'paymentMethod': paymentMethod,
        'transactionId': _transactionController.text.trim(),
        'fbProfile': _fbProfileController.text.trim(),
        'interestedIn': _interestedInController.text.trim(),
        'expertIn': _expertInController.text.trim(),
        'applicationDate': FieldValue.serverTimestamp(),
        'status': 'pending', // Default status for new applications
      };

      // Save to JoinClub collection
      await FirebaseFirestore.instance
          .collection('JoinClub')
          .add(applicationData);

      return true;
    } catch (e) {
      print('Error submitting club application: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to submit application: ${e.toString()}')),
      );
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkIfAlreadyMember() async {
    if (selectedClub == null) return false;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final snapshot = await FirebaseFirestore.instance
          .collection('JoinClub')
          .where('userId', isEqualTo: currentUser.uid)
          .where('clubName', isEqualTo: selectedClub)
          .where('status', whereIn: ['approved', 'pending']).get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking membership status: $e');
      return false;
    }
  }

  void _showAlreadyMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                "You're already a member of this club!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "You already have a pending or approved membership for this club.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate club selection
      if (selectedClub == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a club')),
        );
        return;
      }

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      // Check if user is already a member of this club
      bool isAlreadyMember = await _checkIfAlreadyMember();

      if (isAlreadyMember) {
        setState(() {
          _isLoading = false;
        });
        _showAlreadyMemberDialog();
        return;
      }

      // Convert registration number to uppercase
      final registrationNo = _registrationController.text.trim().toUpperCase();
      _registrationController.text = registrationNo;

      // Save data to Firebase
      bool success = await _saveToFirebase();

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JoinClubSuccess()),
        );
      } else {
        // Error already shown in _saveToFirebase method
        setState(() {
          _isLoading = false;
        });
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
                // Remove the conditional loading here, always show the form
                child: _buildForm(),
              ),
            ],
          ),
          // Only show the loading overlay when loading
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xff6686F6),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Loading your information...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // We can keep this method but it won't be used directly in the build method
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xff6686F6),
          ),
          SizedBox(height: 20.h),
          Text(
            "Loading your information...",
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 14.sp, // Reduced from 16.sp
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
            "Join Club",
            style: TextStyle(
              fontSize: 22.sp, // Reduced from 25.sp
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
                _nameController, "Full Name", "Enter your full name",
                enabled: false),
            _buildInputField(_userIdController, "User ID", "Your DIU ID",
                enabled: false), // Add the new UserID field (disabled)
            _buildInputField(_emailController, "Email", "Enter your email",
                keyboardType: TextInputType.emailAddress,
                enabled: false), // Disable email editing since it's from auth
            Row(
              children: [
                Expanded(
                  child: _buildInputField(_batchController, "Batch", "Ex: D-78",
                      enabled: false, isHalfWidth: true),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildInputField(_rollController, "Roll", "Ex: 10",
                      enabled: false, isHalfWidth: true),
                ),
              ],
            ),
            _buildInputField(
                _registrationController,
                "Registration No.",
                enabled: false,
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
                        fontSize: 15.sp, // Reduced from 16.sp
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
            fontSize: 14.sp, // Reduced from 16.sp
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
            // style: TextStyle(
            //   fontSize: 14.sp,
            // ),
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
            hint: Text("Select a club",
                style: TextStyle(fontSize: 12.sp)), // Added explicit font size
            items: clubs.map((String club) {
              return DropdownMenuItem(
                value: club,
                child: Text(club,
                    style: TextStyle(
                      fontSize: 14.sp,
                    )),
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
              fontSize: 14.sp, // Reduced from 16.sp
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h), // Reduced from 8.h
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Coloris.text_color.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: controller,
              style: TextStyle(
                fontSize: 14.sp,
              ),
              keyboardType: keyboardType,
              textCapitalization: isUppercaseField
                  ? TextCapitalization.characters
                  : TextCapitalization.none,
              enabled: enabled,
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
                  fontSize: 12.sp, // Reduced from 14.sp
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 10.h), // Reduced vertical padding from 12.h
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
              fontSize: 14.sp, // Reduced from 16.sp
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
                style: TextStyle(fontSize: 12.sp), // Added explicit font size
              ),
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
              fontSize: 14.sp, // Reduced from 16.sp
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
              Text('Bkash',
                  style:
                      TextStyle(fontSize: 12.sp)), // Added explicit font size
              Radio(
                value: 'nagad',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() => paymentMethod = value.toString());
                },
              ),
              Text('Nagad',
                  style:
                      TextStyle(fontSize: 12.sp)), // Added explicit font size
            ],
          ),
          Text(
            "Payment Number: 01XXXXXXXXX",
            style: TextStyle(
              color: Colors.red,
              fontSize: 12.sp, // Reduced from 14.sp
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
