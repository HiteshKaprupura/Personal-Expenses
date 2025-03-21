import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserProfile extends StatefulWidget {
  const EditUserProfile({super.key});

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final TextEditingController nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isEditingName = false;
  bool isLoading = false;
  final FocusNode nameFocusNode = FocusNode();
  String userEmail = "user@example.com"; // Read-only email field

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch user details from Firebase
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        nameController.text = userDoc['name'] ?? "User Name";
        userEmail = user.email ?? "user@example.com"; // Set email for display
      });
    }
  }

  // Update only the name in Firestore
  Future<void> _updateUserData() async {
    if (nameController.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': nameController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Name updated successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating name: $e")),
      );
    }

    setState(() {
      isLoading = false;
      isEditingName = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        title: const Text("User Profile",
            style: TextStyle(fontSize: 25, color: Colors.white)),
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              // Profile Icon
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 15),

              // Editable Name Field
              GestureDetector(
                onTap: () => setState(() {
                  isEditingName = true;
                  FocusScope.of(context).requestFocus(nameFocusNode);
                }),
                child: TextField(
                  controller: nameController,
                  enabled: isEditingName,
                  focusNode: nameFocusNode,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    hintStyle: const TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isEditingName ? Colors.white : Colors.grey[200],
                    suffixIcon: IconButton(
                      icon: Icon(
                        isEditingName ? Icons.check : Icons.edit,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          isEditingName = !isEditingName;
                          if (!isEditingName) _updateUserData();
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Read-Only Email Field
              TextField(
                controller: TextEditingController(text: userEmail),
                enabled: false, // Disable editing
                decoration: InputDecoration(
                  labelText: "Email Address",
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200], // Read-only effect
                ),
              ),
              const SizedBox(height: 20),

              // Save Changes Button (Optional)
              ElevatedButton(
                onPressed: isEditingName ? _updateUserData : null,
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: isEditingName ? Colors.blueAccent : Colors.grey, // Active/InActive Color
                  foregroundColor: Colors.white,
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
