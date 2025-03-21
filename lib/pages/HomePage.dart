import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_expenses/pages/add.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLogoutLoading = false;
  final User? user = FirebaseAuth.instance.currentUser;


  // Category Icons Map
  final Map<String, IconData> categoryIcons = {
    "Gas Filling": Icons.local_gas_station,
    "Grocery": Icons.shopping_cart,
    "Milk": Icons.local_cafe,
    "Internet": Icons.wifi,
    "Electricity": Icons.electric_bolt,
    "Water": Icons.water,
    "Rent": Icons.home,
    "Phone Bill": Icons.phone,
    "Dining Out": Icons.restaurant,
    "Entertainment": Icons.movie,
    "Healthcare": Icons.local_hospital,
    "Transportation": Icons.directions_bus,
    "Clothing": Icons.checkroom,
    "Insurance": Icons.shield,
    "Education": Icons.school,
    "Others": Icons.shopping_bag,
  };

  // Logout function
  Future<void> Logout() async {
    setState(() {
      isLogoutLoading = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Logout Error: $e");
    }

    setState(() {
      isLogoutLoading = false;
    });

    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "SpendSync",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.025), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **User Profile Section**
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.07, // Responsive radius
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: screenWidth * 0.08, color: Colors.white), // Responsive icon size
                ),
                SizedBox(width: screenWidth * 0.04), // Responsive spacing
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            "Loading...",
                            style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text(
                            "Error",
                            style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.red),
                          );
                        }

                        String userName = user?.displayName ?? "Hello"; // Fallback to displayName or default

                        if (snapshot.hasData && snapshot.data?.exists == true) {
                          userName = snapshot.data!.get('name') ?? userName;
                        }

                        return Text(
                          userName,
                          style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                        );
                      },
                    ),

                    Text(
                      user?.email ?? "No Email Available",
                      style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey), // Responsive font size
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01), // Responsive spacing

            /// **Fetching Transaction Data**
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('transactions')
                  .orderBy('Date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white,)));
                }

                double totalIncome = 0.0;
                double totalExpense = 0.0;
                List<DocumentSnapshot> deletedTransactions = []; // Track deleted transactions for undo

                for (var doc in snapshot.data!.docs) {
                  double amount = (doc['Amount'] as num).toDouble();
                  if (doc['Type'] == 'Income') {
                    totalIncome += amount;
                  } else if (doc['Type'] == 'Expense') {
                    totalExpense += amount;
                  }
                }

                double totalBalance = totalIncome - totalExpense;

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// **Total Balance Section**
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.0125), // Responsive padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Balance",
                              style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w600), // Responsive font size
                            ),
                            Text(
                              "₹${totalBalance.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: screenWidth * 0.09, fontWeight: FontWeight.w600), // Responsive font size
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.00), // Responsive spacing

                      /// **Income & Expense Section**
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAmountContainer("Income", totalIncome, Colors.green, screenWidth, screenHeight),
                          _buildAmountContainer("Expense", totalExpense, Colors.red, screenWidth, screenHeight),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.0125), // Responsive spacing
                      /// **Recent Transactions**
                      Text(
                        "Recent Transactions",
                        style: TextStyle(fontSize: screenWidth * 0.048, fontWeight: FontWeight.bold), // Responsive font size
                      ),
                      SizedBox(height: screenHeight * 0.00625), // Responsive spacing
                      Expanded(
                        child: ListView.separated( // Changed to ListView.separated
                          itemCount: snapshot.data!.docs.length,
                          separatorBuilder: (context, index) => Divider( // Added Divider
                            color: Colors.grey[300],
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = snapshot.data!.docs[index];
                            Map<String, dynamic> transaction = doc.data() as Map<String, dynamic>;

                            String category = transaction["Category"] ?? "Others";
                            IconData categoryIcon = categoryIcons[category] ?? Icons.shopping_bag;
                            bool isIncome = transaction["Type"] == "Income";
                            double amount = (transaction["Amount"] as num).toDouble();
                            String formattedDate = DateFormat('d MMM hh:mm a').format(
                              (transaction["Date"] as Timestamp).toDate(),
                            );

                            return Dismissible(
                              key: Key(doc.id), // Unique key for each item
                              direction: DismissDirection.endToStart, // Swipe from right to left
                              onDismissed: (direction) async {
                                // Track the deleted transaction
                                deletedTransactions.add(doc);

                                // Delete transaction from Firestore
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user?.uid)
                                      .collection('transactions')
                                      .doc(doc.id)
                                      .delete();

                                  // Show the SnackBar with Undo option
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Transaction deleted"),
                                      duration: const Duration(seconds: 5),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        textColor: Colors.white,
                                        onPressed: () {
                                          // If Undo clicked, add the transaction back to Firestore
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user?.uid)
                                              .collection('transactions')
                                              .doc(doc.id)
                                              .set(doc.data() as Map<String, dynamic>);
                                        },
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                color: Colors.red,
                                child: const Icon(Icons.delete_outline, color: Colors.white),
                              ),
                              child: _buildTransactionListItem(categoryIcon, transaction["Note"], formattedDate, amount, isIncome, screenWidth, screenHeight), // Changed to _buildTransactionListItem
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionPage()),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }


  /// **Reusable Transaction List Item UI (With Icons)**
  Widget _buildTransactionListItem(IconData icon, String title, String date, double amount, bool isIncome, double screenWidth, double screenHeight) {
    return Padding( // Removed Card and replaced with Padding
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenWidth * 0.02), // Responsive padding
      child: Row(
        children: [
          CircleAvatar(
            radius: screenWidth * 0.06, // Responsive radius
            backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
            child: Icon(icon, color: isIncome ? Colors.green : Colors.red, size: screenWidth * 0.065), // Responsive icon size
          ),
          SizedBox(width: screenWidth * 0.03), // Responsive spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold)), // Responsive font size
                Text(date, style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey)), // Responsive font size
              ],
            ),
          ),
          Text(
            isIncome ? "+ ₹${amount.toStringAsFixed(2)}" : "- ₹${amount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: screenWidth * 0.042, fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red), // Responsive font size
          ),
        ],
      ),
    );
  }

  /// **Reusable Transaction Card UI (With Icons)**
  Widget _buildTransactionCard(IconData icon, String title, String date, double amount, bool isIncome, double screenWidth, double screenHeight) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005), // Responsive margin
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015, horizontal: screenWidth * 0.04), // Responsive padding
        child: Row(
          children: [
            CircleAvatar(
              radius: screenWidth * 0.06, // Responsive radius
              backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(icon, color: isIncome ? Colors.green : Colors.red, size: screenWidth * 0.065), // Responsive icon size
            ),
            SizedBox(width: screenWidth * 0.03), // Responsive spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold)), // Responsive font size
                  Text(date, style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey)), // Responsive font size
                ],
              ),
            ),
            Text(
              isIncome ? "+ ₹${amount.toStringAsFixed(2)}" : "- ₹${amount.toStringAsFixed(2)}",
              style: TextStyle(fontSize: screenWidth * 0.042, fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red), // Responsive font size
            ),
          ],
        ),
      ),
    );
  }

  /// **Reusable Widget for Income & Expense**
  Widget _buildAmountContainer(String title, double amount, Color color, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.45, // Responsive width
      height: screenHeight * 0.11, // Responsive height
      padding: EdgeInsets.all(screenWidth * 0.025), // Responsive padding
      decoration: BoxDecoration(color: color.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold, color: color)), // Responsive font size
          SizedBox(height: screenHeight * 0.0125), // Responsive spacing
          Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: color)), // Responsive font size
        ],
      ),
    );
  }
}