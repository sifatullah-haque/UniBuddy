import 'package:diu/Constant/color_is.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu/models/lost_item_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'; // Ensure this import is present

class LostItem extends StatefulWidget {
  const LostItem({super.key});

  @override
  State<LostItem> createState() => _LostItemState();
}

class _LostItemState extends State<LostItem> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lostByController = TextEditingController();
  final _batchNameController = TextEditingController();
  final _dateLostController = TextEditingController();
  final _foundByController = TextEditingController();
  final _foundByBatchController = TextEditingController();
  final _foundByContactController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isLoadingUserData = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _lostByController.dispose();
    _batchNameController.dispose();
    _dateLostController.dispose();
    _foundByController.dispose();
    _foundByBatchController.dispose();
    _foundByContactController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoadingUserData = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        setState(() {
          // Pre-fill form with user data
          _lostByController.text =
              '${userData['firstName']} ${userData['lastName']}';
          _batchNameController.text = userData['batchNo'] ?? '';
          _contactController.text = userData['phoneNo'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final status = await Permission.storage.request();
      final cameraStatus = await Permission.camera.request();

      if (status.isDenied || cameraStatus.isDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied to access photos')),
        );
        return;
      }

      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      // Create a unique filename
      final fileName = 'lost_item_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create the reference with the full path
      final ref = FirebaseStorage.instance
          .ref()
          .child('lost_items') // folder in storage
          .child(fileName); // file name

      // Upload the file with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': _selectedImage!.path},
      );

      // Start upload task
      final uploadTask = ref.putFile(_selectedImage!, metadata);

      // Show upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Wait for upload to complete and get the URL
      await uploadTask.whenComplete(() => null);
      final downloadUrl = await ref.getDownloadURL();

      print('Upload successful. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<String?> _getImageBase64() async {
    if (_selectedImage == null) return null;

    try {
      final bytes = await _selectedImage!.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image: $e');
      return null;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateLostController.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xff6686F6)),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Creating lost item alert...',
                      style: TextStyle(
                        color: Color(0xff6686F6),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _createLostItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      _showLoadingOverlay(); // Show loading overlay

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      String? imageBase64;
      if (_selectedImage != null) {
        imageBase64 = await _getImageBase64();
      }

      final lostItem = LostItemModel(
        id: '',
        title: _titleController.text,
        location: _locationController.text,
        contact: _contactController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        userId: user.uid,
        lostBy: _lostByController.text,
        batchName: _batchNameController.text,
        dateLost: _selectedDate!,
        imageBase64: imageBase64,
      );

      // Add to Firestore
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('lostItems')
          .add(lostItem.toMap());

      // Send notifications
      await _sendNotificationToAllUsers(
        title: 'New Lost Item Report',
        message:
            '${_lostByController.text} lost ${_titleController.text} at ${_locationController.text}',
        type: 'lost_item',
        relatedItemId: docRef.id,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading overlay
      Navigator.pop(context); // Close create item dialog

      // Clear form
      _titleController.clear();
      _locationController.clear();
      _contactController.clear();
      _descriptionController.clear();
      _lostByController.clear();
      _batchNameController.clear();
      _dateLostController.clear();
      setState(() {
        _selectedImage = null;
        _selectedDate = null;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lost item alert created successfully'),
          backgroundColor: Color(0xff6686F6),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading overlay
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating lost item: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendNotificationToAllUsers({
    required String title,
    required String message,
    required String type,
    required String relatedItemId,
  }) async {
    try {
      // Get all users
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Create batch to handle multiple writes efficiently
      final batch = FirebaseFirestore.instance.batch();

      // Create a notification for each user
      for (var userDoc in usersSnapshot.docs) {
        final notificationRef =
            FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': userDoc.id,
          'title': title,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': type,
          'relatedItemId': relatedItemId,
        });
      }

      // Commit the batch
      await batch.commit();
      print('Notifications sent to all users successfully');
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  void _handleCardTap(LostItemModel item) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid == item.userId) {
      _showDeleteConfirmation(item);
    }
  }

  void _showDeleteConfirmation(LostItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Lost Item'),
        content: Text('Are you sure you want to delete this lost item alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('lostItems')
                    .doc(item.id)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting item: $e')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsFound(String itemId, String ownerId) async {
    _foundByController.clear();
    _foundByBatchController.clear();
    _foundByContactController.clear();

    // Preload user data
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          _foundByController.text =
              '${userData['firstName']} ${userData['lastName']}';
          _foundByBatchController.text = userData['batchNo'] ?? '';
          _foundByContactController.text = userData['phoneNo'] ?? '';
        }
      } catch (e) {
        print('Error loading user data for "Found it!" dialog: $e');
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom header
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Found Item Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Form content
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        controller: _foundByController,
                        labelText: 'Found By',
                        enabled: false,
                      ),
                      SizedBox(height: 12.h),
                      _buildFormField(
                        controller: _foundByBatchController,
                        labelText: 'Batch No.',
                        enabled: false,
                      ),
                      SizedBox(height: 12.h),
                      _buildFormField(
                        controller: _foundByContactController,
                        labelText: 'Contact Number',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          width: double.infinity,
                          height: 50.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                            ),
                            borderRadius: BorderRadius.circular(15),
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
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      try {
        // Update item status
        await FirebaseFirestore.instance
            .collection('lostItems')
            .doc(itemId)
            .update({
          'isFound': true,
          'foundBy': _foundByController.text,
          'foundByBatch': _foundByBatchController.text,
          'foundByContact': _foundByContactController.text,
        });

        // Create notification
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': ownerId,
          'title': 'Item Found!',
          'message':
              '${_foundByController.text} found your item. Contact: ${_foundByContactController.text}',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'found_item',
          'relatedItemId': itemId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item marked as found and owner notified')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item status: $e')),
        );
      }
    }
  }

  void _showCreateItemDialog() {
    _loadUserData();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Get keyboard visibility status
            final bool isKeyboardVisible =
                MediaQuery.of(context).viewInsets.bottom > 0;
            final double screenHeight = MediaQuery.of(context).size.height;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: isKeyboardVisible
                      ? screenHeight *
                          0.5 // Smaller height when keyboard is visible
                      : screenHeight *
                          0.7, // Normal height when keyboard is hidden
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Custom header
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 15.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Create Lost Item Alert',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    // Form content
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isKeyboardVisible) ...[
                                  StatefulBuilder(
                                    builder: (context, setImageState) {
                                      return GestureDetector(
                                        onTap: () async {
                                          await _pickImage();
                                          setImageState(
                                              () {}); // Force rebuild image preview
                                        },
                                        child: _buildImagePicker(),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                                // Rest of your form fields
                                _buildSectionTitle("User Information"),
                                _buildFormField(
                                  controller: _lostByController,
                                  labelText: 'Item Lost By',
                                  enabled: false,
                                ),
                                SizedBox(height: 12.h),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFormField(
                                        controller: _batchNameController,
                                        labelText: 'Batch',
                                        enabled: false,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: _buildFormField(
                                        controller: _contactController,
                                        labelText: 'Contact',
                                        enabled: false,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20.h),
                                _buildSectionTitle("Item Information"),
                                _buildFormField(
                                  controller: _titleController,
                                  labelText: 'Item Name*',
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Required field'
                                      : null,
                                ),
                                SizedBox(height: 12.h),
                                _buildDatePicker(),
                                SizedBox(height: 12.h),
                                _buildFormField(
                                  controller: _locationController,
                                  labelText: 'Location Lost*',
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Required field'
                                      : null,
                                ),
                                SizedBox(height: 12.h),
                                _buildFormField(
                                  controller: _descriptionController,
                                  labelText: 'Description',
                                  maxLines: 3,
                                ),
                                SizedBox(height: 20.h),

                                _buildSubmitButton(),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Item Image",
          style: TextStyle(
            color: Coloris.text_color,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image preview
                        Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                        // Change image button overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.5],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Tap to change image",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40.sp,
                        color: Color(0xff6686F6),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Add Item Image",
                        style: TextStyle(
                          color: Coloris.text_color,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "(Optional)",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xff6686F6),
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    bool enabled = true,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14.sp,
        color: enabled ? Coloris.text_color : Colors.grey[700],
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14.sp,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xff6686F6), width: 1.5),
        ),
        filled: !enabled,
        fillColor: enabled ? Colors.transparent : Colors.grey[100],
      ),
      validator: validator,
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dateLostController,
      readOnly: true,
      onTap: _selectDate,
      style: TextStyle(
        fontSize: 14.sp,
        color: Coloris.text_color,
      ),
      decoration: InputDecoration(
        labelText: 'Date Lost*',
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14.sp,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xff6686F6), width: 1.5),
        ),
        suffixIcon: Icon(
          Icons.calendar_today,
          size: 20.sp,
          color: Color(0xff6686F6),
        ),
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please select a date' : null,
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoadingUserData || _isLoading ? null : _createLostItem,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoadingUserData || _isLoading
                ? [Colors.grey, Colors.grey.shade400]
                : [Color(0xff6686F6), Color(0xff60BBEF)],
          ),
          borderRadius: BorderRadius.circular(15),
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
            "Create Lost Item Alert",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloris.backgroundColor,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xff6686F6), Color(0xff60BBEF)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          onPressed: _showCreateItemDialog,
          label: Text(
            'Create Lost Item Alert',
            style: TextStyle(
              color: Coloris.white,
              fontSize: 14.sp,
            ),
          ),
          icon: Icon(Icons.add, color: Coloris.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildLostItemsList(),
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
            "Lost Items",
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

  Widget _buildLostItemsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lostItems')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs.map((doc) {
          return LostItemModel.fromMap(
              // Changed from LostItem to LostItemModel
              doc.id,
              doc.data() as Map<String, dynamic>);
        }).toList();

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildLostItemCard(items[index]),
        );
      },
    );
  }

  Widget _buildLostItemCard(LostItemModel item) {
    return GestureDetector(
      onTap: () => _handleCardTap(item),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        decoration: BoxDecoration(
          color: Coloris.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (item.imageBase64 != null &&
                          item.imageBase64!.isNotEmpty) {
                        _showFullImageBase64(context, item.imageBase64!);
                      }
                    },
                    child: Container(
                      height: 80.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: item.imageBase64 != null &&
                              item.imageBase64!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(item.imageBase64!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.image,
                              color: Colors.grey[400],
                              size: 30,
                            ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Coloris.text_color,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "Lost in ${item.location}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Coloris.text_color.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "Lost By: ${item.lostBy} (${item.batchName})",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Coloris.text_color.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "Contact: ${item.contact}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Coloris.text_color.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Lost on: ${item.dateLost.toString().split(' ')[0]}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Coloris.text_color.withOpacity(0.7),
                    ),
                  ),
                  if (!item.isFound)
                    GestureDetector(
                      onTap: () => _markAsFound(item.id, item.userId),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff6686F6), Color(0xff60BBEF)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Found it!",
                          style: TextStyle(
                            color: Coloris.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  if (item.isFound)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Found",
                        style: TextStyle(
                          color: Coloris.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImageBase64(BuildContext context, String base64String) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Image.memory(
                    base64Decode(base64String),
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
