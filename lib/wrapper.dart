import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_expenses/pages/Login.dart';
import 'package:personal_expenses/pages/Welcome.dart';
import 'package:personal_expenses/pages/dashboard.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(), // Show loading spinner while waiting for auth state
            );
          }

          // If user is logged in, show Dashboard
          if (snapshot.hasData) {
            return Dashboard();
          } else {
            // If user is not logged in, show Welcome
            return WelcomeWidget();
          }
        },
      ),
    );
  }
}
