import 'package:flutter/material.dart';
import 'package:personal_expenses/pages/Login.dart';
import 'package:personal_expenses/pages/Signup.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome to", style: TextStyle(fontSize: size.width * 0.04)),
              SizedBox(height: size.height * 0.005),
              Text("SpendSync", style: TextStyle(fontSize: size.width * 0.07, fontWeight: FontWeight.bold)),
              SizedBox(height: size.height * 0.005),
              Text(
                "A place where you can track all your expenses and incomes...",
                style: TextStyle(color: Colors.black54, fontSize: size.width * 0.04),
              ),
              SizedBox(height: size.height * 0.05),
              Text("Let's get started!", style: TextStyle(fontSize: size.width * 0.04)),
              SizedBox(height: size.height * 0.03),
              Center(
                child: Image.asset("assets/welcome.png", width: size.width * 0.7),
              ),
              SizedBox(height: size.height * 0.04),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginWidgets()));
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, size.height * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: Text("Login", style: TextStyle(fontSize: size.width * 0.045)),
                ),
              ),
              SizedBox(height: size.height * 0.02),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignupWidget()));
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, size.height * 0.06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Sign up", style: TextStyle(fontSize: size.width * 0.045)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
