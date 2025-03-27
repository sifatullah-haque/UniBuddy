import 'package:diu/auth/login/login.dart';
import 'package:diu/auth/register/register.dart';
import 'package:diu/pages/main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IsLogin extends StatefulWidget {
  const IsLogin({super.key});

  @override
  State<IsLogin> createState() => _IsLoginState();
}

class _IsLoginState extends State<IsLogin> {
  final ValueNotifier<bool> _showLogin = ValueNotifier<bool>(true);
  bool _isChecking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Check auth status once at startup
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (!user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        _isLoggedIn = false;
      } else {
        _isLoggedIn = true;
      }
    } else {
      _isLoggedIn = false;
    }

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }

    // Listen for auth changes after initial check
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _isLoggedIn = user != null && user.emailVerified;
        });
      }
    });
  }

  void _handleRegistrationComplete() {
    _showLogin.value = true;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email to login'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _showLogin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking auth status
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show main navigation if logged in
    if (_isLoggedIn) {
      return MainNavigation();
    }

    // Show login/register screen based on _showLogin value
    return WillPopScope(
      onWillPop: () async {
        if (!_showLogin.value) {
          _showLogin.value = true;
          return false;
        }
        return true;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _showLogin,
        builder: (context, showLogin, _) {
          if (showLogin) {
            return LoginPage(
              onRegisterClick: () => _showLogin.value = false,
            );
          } else {
            return RegisterPage(
              onRegistrationComplete: _handleRegistrationComplete,
            );
          }
        },
      ),
    );
  }
}
