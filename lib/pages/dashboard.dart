import 'package:flutter/material.dart';
import 'package:personal_expenses/pages/Settings.dart';
import 'package:personal_expenses/pages/transaction_screen.dart';
import 'package:personal_expenses/widgets/navbar.dart';

import 'HomePage.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentIndex = 0; // Keep track of the selected tab

  final List<Widget> pages = [
    HomeScreen(),
    TransactionScreen(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: pages[currentIndex], // Show the correct page
      bottomNavigationBar: Navbar(
        currentPageIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index; // Update the selected tab
          });
        },
      ),
    );
  }
}
