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

  Future<void> _pickImage() async {
    try {
      // Request permissions first
      final status = await Permission.storage.request();
      final cameraStatus = await Permission.camera.request();

      if (status.isDenied || cameraStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied to access photos')),
        );
        return;
      }

      // Show image source choice dialog
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
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70, // Reduce image quality to save storage
        maxWidth: 1000, // Limit image dimensions
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
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

  Future<void> _createLostItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
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
        imageBase64: imageBase64, // Use imageBase64 instead of imageUrl
      );

      // Add to Firestore
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('lostItems')
          .add(lostItem.toMap());

      // Send notifications to all users
      await _sendNotificationToAllUsers(
        title: 'New Lost Item Report',
        message:
            '${_lostByController.text} lost ${_titleController.text} at ${_locationController.text}',
        type: 'lost_item',
        relatedItemId: docRef.id,
      );

      if (!mounted) return;
      Navigator.pop(context);

      // Clear all fields including the image
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
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lost item alert created successfully'),
          backgroundColor: Color(0xff6686F6),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating lost item: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Add this new method to send notifications to all users
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

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Found Item Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _foundByController,
              decoration: InputDecoration(
                labelText: 'Found By',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _foundByBatchController,
              decoration: InputDecoration(
                labelText: 'Batch No.',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _foundByContactController,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Submit'),
          ),
        ],
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
          'timestamp': FieldValue.serverTimestamp(), // Use server timestamp
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

  void _showCreateItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create Lost Item Alert',
          style: TextStyle(
            color: Coloris.text_color,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _lostByController,
                  decoration: InputDecoration(
                    labelText: 'Item Lost By',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _batchNameController,
                  decoration: InputDecoration(
                    labelText: 'Batch Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _dateLostController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Date Lost',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location Lost',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:
                                Image.file(_selectedImage!, fit: BoxFit.cover),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40),
                                Text('Add Image (Optional)'),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff6686F6), Color(0xff60BBEF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: _isLoading ? null : _createLostItem,
              child: Text(
                _isLoading ? 'Creating...' : 'Create',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
