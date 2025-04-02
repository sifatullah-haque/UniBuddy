import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserDataProvider {
  static Map<String, dynamic>? _cachedUserData;
  static bool _isLoading = false;
  static DateTime? _lastFetchTime;

  static final List<VoidCallback> _listeners = [];

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  static Future<Map<String, dynamic>?> getUserData(
      {bool forceRefresh = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // Return cached data if available and not forcing refresh
    if (!forceRefresh && _cachedUserData != null) {
      return _cachedUserData;
    }

    // Prevent multiple simultaneous fetches
    if (_isLoading) {
      // Wait until the ongoing fetch completes
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cachedUserData;
    }

    _isLoading = true;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _cachedUserData = doc.data();
        _lastFetchTime = DateTime.now();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      _isLoading = false;
    }

    return _cachedUserData;
  }

  static Future<void> updateUserData(Map<String, dynamic> newData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(newData);

      // Update cache with new data
      _cachedUserData = {...?_cachedUserData, ...newData};
      _lastFetchTime = DateTime.now();

      // Notify listeners about the update
      _notifyListeners();
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  static void clearCache() {
    _cachedUserData = null;
    _lastFetchTime = null;
  }
}
