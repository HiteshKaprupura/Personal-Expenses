import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:personal_expenses/pages/ForgotPassword.dart';
import 'package:personal_expenses/pages/Signup.dart';
import 'package:personal_expenses/wrapper.dart';

import 'auth_service.dart';

class LoginWidgets extends StatefulWidget {
  const LoginWidgets({super.key});

  @override
  State<LoginWidgets> createState() => _LoginWidgetsState();
}

class _LoginWidgetsState extends State<LoginWidgets> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obscureText = true;
  final AuthService _authService = AuthService();


  signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);

      // Redirect to Wrapper (it will automatically show Dashboard if logged in)
      Get.snackbar("Success", "Login successfully!");
      Get.offAll(() => Wrapper());

    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.code, duration: Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
  Future<void> signInWithGoogle() async {
    User? user = await _authService.signInWithGoogle();
    if (user != null) {
      print("User Signed In: ${user.displayName}");
      Get.snackbar("Success", "Signed in as ${user.displayName}");
    } else {
      Get.snackbar("Error", "Google Sign-In Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06, vertical: size.height * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Login", style: TextStyle(fontSize: size.width * 0.07)),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    "Login now to track all your expenses and income at a place!",
                    style: TextStyle(
                        fontSize: size.width * 0.04, color: Colors.black54),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text('Email', style: TextStyle(fontSize: size.width * 0.04)),
                  SizedBox(height: size.height * 0.01),
                  TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter Email',
                        hintStyle: TextStyle(color: Colors.black54),
                        suffixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                      )),
                  SizedBox(height: size.height * 0.02),
                  Text('Password',
                      style: TextStyle(fontSize: size.width * 0.04)),
                  SizedBox(height: size.height * 0.01),
                  TextField(
                    controller: password,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscureText, // Hide/Show Password
                    decoration: InputDecoration(
                      hintText: 'Enter Password',
                      hintStyle: TextStyle(color: Colors.black54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Toggle Password
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  SizedBox(height: size.height * 0.001),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword()));
                        },
                        child: Text("Forgot Password?",
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: size.width * 0.04))),
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () => signIn(),
                        style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            minimumSize: Size(size.width * 0.9, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text('Login',
                            style: TextStyle(fontSize: size.width * 0.045))),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Row(
                    children: [
                      Expanded(
                          child: Divider(thickness: 2, color: Colors.black26)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("Or continue with",
                            style: TextStyle(
                                fontSize: size.width * 0.04,
                                color: Colors.black)),
                      ),
                      Expanded(
                          child: Divider(thickness: 2, color: Colors.black26)),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(size.width * 0.9, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: Colors.black26, width: 1),
                        ),
                        onPressed: () => signInWithGoogle(),
                        icon: Image.asset(
                          'assets/google.png',
                          width: size.width * 0.07,
                          height: size.width * 0.07,
                          fit: BoxFit.contain,
                        ),
                        label: Text(
                          'Continue with Google',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black54,
                              minimumSize: Size(size.width * 0.9, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              side: BorderSide(color: Colors.black26)),
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/facebook.png',
                            width: size.width * 0.07,
                            height: size.width * 0.07,
                            fit: BoxFit.contain,
                          ),
                          label: Text("Continue with Facebook",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * 0.045,
                                  fontWeight: FontWeight.w500))),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don’t have an account? ",
                          style:
                          TextStyle(fontSize: size.width * 0.04, color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Sign up",
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignupWidget()),
                                  );
                                },
                            ),
                          ],
                        ),
                      )),
                ],
              )),
        ));
  }
}
