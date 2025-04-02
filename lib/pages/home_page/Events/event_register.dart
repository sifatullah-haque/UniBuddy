import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu/Constant/color_is.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventRegister extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventRegister({
    Key? key,
    required this.eventId,
    required this.eventData,
  }) : super(key: key);

  @override
  State<EventRegister> createState() => _EventRegisterState();
}

class _EventRegisterState extends State<EventRegister> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool isDayShift = true;
  bool isBiSemester = true;
  String paymentMethod = 'bkash';
  bool _confirmRegistration = false;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userIdController = TextEditingController();
  final _batchController = TextEditingController();
  final _rollController = TextEditingController();
  final _registrationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _transactionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _semesterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
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
            _nameController.text =
                '${userData['firstName']} ${userData['lastName']}';
            _emailController.text = userData['email'] ?? '';
            _userIdController.text = userData['userId'] ?? '';
            _batchController.text = userData['batchNo'] ?? '';
            _rollController.text = userData['rollNo'] ?? '';
            _registrationController.text = userData['registrationNo'] ?? '';
            _phoneController.text = userData['phoneNo'] ?? '';
            _departmentController.text = userData['deptName'] ?? '';
            _semesterController.text = userData['semesterNo']?.toString() ?? '';
            isDayShift = userData['isDayShift'] ?? true;
            isBiSemester = userData['isBiSemester'] ?? true;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_confirmRegistration) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please confirm your registration by checking the box'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if already registered
    final existingRegistration = await FirebaseFirestore.instance
        .collection('eventRegistrations')
        .where('eventId', isEqualTo: widget.eventId)
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (existingRegistration.docs.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are already registered for this event'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      final registrationData = {
        'eventId': widget.eventId,
        'eventTitle': widget.eventData['title'],
        'userId': currentUser.uid,
        'userDiuId': _userIdController.text,
        'name': _nameController.text,
        'email': _emailController.text,
        'batch': _batchController.text,
        'roll': _rollController.text,
        'registrationNo': _registrationController.text,
        'department': _departmentController.text,
        'semester': _semesterController.text,
        'isDayShift': isDayShift,
        'isBiSemester': isBiSemester,
        'phoneNumber': _phoneController.text,
        'registrationDate': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      // Add payment information if the event is not free
      if (!(widget.eventData['isFree'] ?? true)) {
        registrationData.addAll({
          'paymentMethod': paymentMethod,
          'transactionId': _transactionController.text,
          'amount': widget.eventData['amount'],
        });
      }

      // Save to event registrations collection
      await FirebaseFirestore.instance
          .collection('eventRegistrations')
          .add(registrationData);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration submitted successfully'),
          backgroundColor: Color(0xff6686F6),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting registration: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _userIdController.dispose();
    _batchController.dispose();
    _rollController.dispose();
    _registrationController.dispose();
    _phoneController.dispose();
    _transactionController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    super.dispose();
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
            "Event Registration",
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
            Text(
              widget.eventData['title'] ?? 'Event Registration',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Coloris.text_color,
              ),
            ),
            SizedBox(height: 20.h),
            _buildInputField(
                _nameController, "Full Name", "Enter your full name",
                enabled: false),
            _buildInputField(_userIdController, "User ID", "Your DIU ID",
                enabled: false),
            _buildInputField(_emailController, "Email", "Enter your email",
                enabled: false),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(_batchController, "Batch", "Ex: D-78",
                      enabled: false),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: _buildInputField(_rollController, "Roll", "Ex: 10",
                      enabled: false),
                ),
              ],
            ),
            _buildInputField(_registrationController, "Registration No.",
                "Ex: CS-D-78-22-****",
                enabled: false),
            _buildInputField(
                _departmentController, "Department", "Your department",
                enabled: false),
            _buildInputField(_semesterController, "Semester", "Your semester",
                enabled: false),
            Row(
              children: [
                _buildSwitchField("Semester Type", isBiSemester, (value) {
                  setState(() => isBiSemester = value);
                }, "Bi-Semester", "Tri-Semester", enabled: false),
                SizedBox(width: 15.w),
                _buildSwitchField("Shift", isDayShift, (value) {
                  setState(() => isDayShift = value);
                }, "Day", "Evening", enabled: false),
              ],
            ),
            _buildInputField(_phoneController, "Phone Number", "01X-XXXXXXXX"),
            if (!(widget.eventData['isFree'] ?? true)) ...[
              _buildPaymentMethodSelector(),
              _buildInputField(_transactionController, "Transaction ID",
                  "Enter transaction ID"),
            ],
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.h),
              child: Row(
                children: [
                  Checkbox(
                    value: _confirmRegistration,
                    onChanged: (value) {
                      setState(() {
                        _confirmRegistration = value ?? false;
                      });
                    },
                    activeColor: Color(0xff6686F6),
                  ),
                  Expanded(
                    child: Text(
                      'I confirm that I want to register for this event',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Coloris.text_color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    String hint, {
    bool enabled = true,
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
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Coloris.text_color.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                border: InputBorder.none,
                fillColor: enabled ? Colors.white : Colors.grey[100],
                filled: true,
              ),
              validator: (value) {
                if (enabled && (value == null || value.isEmpty)) {
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
    String falseLabel, {
    bool enabled = true,
  }) {
    return Expanded(
      child: Container(
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
                  onChanged: enabled ? onChanged : null,
                  activeColor: Color(0xff6686F6),
                ),
                Text(
                  value ? trueLabel : falseLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: enabled ? Coloris.text_color : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Method",
            style: TextStyle(
              color: Coloris.text_color,
              fontSize: 14.sp,
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
          if (widget.eventData['paymentNumber'] != null)
            Text(
              "Payment Number: ${widget.eventData['paymentNumber']}",
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submitRegistration,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6686F6), Color(0xff60BBEF)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Color(0xff6686F6).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _isLoading ? "Submitting..." : "Submit Registration",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
