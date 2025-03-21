import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:personal_expenses/pages/Login.dart';
import 'package:personal_expenses/wrapper.dart';

class SignupWidget extends StatefulWidget {
  const SignupWidget({super.key});

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();

  signup() async {
    try {
      //  Firebase Authentication Me User Create Karna
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        //  Firestore Me Name, Email Store Karna
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name.text.trim(),
          'email': email.text.trim(),
          'createdAt': DateTime.now(),
        });

        Get.snackbar("Success", "Account created successfully!");
        Get.offAll(Wrapper()); // Signup ke baad Home Page par Navigate Karna
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Signup failed");
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
              Text("Sign up", style: TextStyle(fontSize: size.width * 0.07)),
              SizedBox(height: size.height * 0.005),
              Text(
                "Create an account to access all the features of SpendSync!",
                style: TextStyle(fontSize: size.width * 0.04, color: Colors.black54),
              ),
              SizedBox(height: size.height * 0.03),
              Text("Email", style: TextStyle(fontSize: size.width * 0.04)),
              SizedBox(height: size.height * 0.01),
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
              SizedBox(height: size.height * 0.02),
              Text("Name", style: TextStyle(fontSize: size.width * 0.04)),
              SizedBox(height: size.height * 0.01),
              TextField(
                controller: name,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: 'Enter Your Name',
                  hintStyle: TextStyle(color: Colors.black54),
                  suffixIcon: Icon(Icons.drive_file_rename_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text("Password", style: TextStyle(fontSize: size.width * 0.04)),
              SizedBox(height: size.height * 0.01),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter Password",
                  hintStyle: TextStyle(fontSize: size.width * 0.04, color: Colors.black54),
                  suffixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: (() => signup()),
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: Colors.blueAccent,
                        minimumSize: Size(size.width * 0.9, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Sign up", style: TextStyle(color: Colors.white, fontSize: size.width * 0.045)),
                    ),
                    SizedBox(height: size.height * 0.03),
                    RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.black, fontSize: size.width * 0.04),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginWidgets()),
                                );
                              },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
