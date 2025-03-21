import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController email = TextEditingController();

  reset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      Get.snackbar("Success", "Password reset email sent!");
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Failed to send reset email");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F5F5),
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06, vertical: size.height * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Forgot Password?", style: TextStyle(fontSize: size.width * 0.07)),
              SizedBox(height: size.height * 0.005),
              Text(
                "We've sent a password reset link to your email. Check your inbox or spam folder.",
                style: TextStyle(fontSize: size.width * 0.04, color: Colors.black54),
              ),
              SizedBox(height: size.height * 0.03),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter Email",
                  hintStyle: TextStyle(color: Colors.black54),
                  suffixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Center(
                child: ElevatedButton(
                  onPressed: (() => reset()),
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(size.width * 0.9, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Reset Password",
                      style: TextStyle(color: Colors.white, fontSize: size.width * 0.045)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
