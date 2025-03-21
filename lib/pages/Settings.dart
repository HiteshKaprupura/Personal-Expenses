import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_expenses/pages/ChangePassword.dart';
import 'EditUserProfile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontSize: 25, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildProfileSection(screenWidth),
          const SizedBox(height: 20),
          Expanded(child: _buildSettingsOptions(screenWidth)),
        ],
      ),
    );
  }

  /// ** Profile Section with Real-Time Firestore Data**
  Widget _buildProfileSection(double screenWidth) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        String userName = "User Name"; // Default name
        String userEmail = user?.email ?? "No Email Available"; // Default email

        if (snapshot.hasData && snapshot.data!.exists) {
          userName = snapshot.data!.get('name') ?? userName;
          userEmail = snapshot.data!.get('email') ?? userEmail;
        }

        return Column(
          children: [
            const SizedBox(height: 15),
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://www.w3schools.com/w3images/avatar2.png"),
            ),
            const SizedBox(height: 10),
            Text(
              userName,
              style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              userEmail, // ** Email now displays properly**
              style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditUserProfile()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.3, vertical: 12),
              ),
              child: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  /// ** Settings List**
  Widget _buildSettingsOptions(double screenWidth) {
    return ListView(
      children: [
        _buildSettingsTile(Icons.lock, "Change Password", "Update your account password", () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
        }),
        _buildDivider(),

        _buildSettingsTile(Icons.logout_rounded, "Logout", "Sign out from your account", _logout, isButton: true),
        _buildDivider(),

        _buildSettingsTile(Icons.info, "App Info", "Version 1.0.0", _showAppInfo),
      ],
    );
  }

  /// ** Settings ListTile**
  Widget _buildSettingsTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isButton = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent, size: 26),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      trailing: isButton
          ? ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Logout", style: TextStyle(color: Colors.white)),
      )
          : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: isButton ? null : onTap,
    );
  }

  /// ** Divider**
  Widget _buildDivider() {
    return Divider(thickness: 0.8, color: Colors.grey.shade300);
  }

  /// ** Logout Function**
  void _logout() async {
    bool confirmLogout = await _showLogoutDialog();
    if (confirmLogout) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } catch (e) {
        print("Logout Error: $e");
      }
    }
  }

  /// **🔥 Show Confirmation Dialog**
  Future<bool> _showLogoutDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel logout
              child: const Text("Cancel", style: TextStyle(color: Colors.blueAccent)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm logout
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;
  }


  /// ** App Info Dialog**
  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("App Info"),
          content: const Text("SpendSync v1.0.0\nThis is a personal expense tracker app."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }
}
