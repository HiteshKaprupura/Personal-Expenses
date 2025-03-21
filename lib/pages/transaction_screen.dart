import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool showCredit = true;
  String selectedCategory = "All";

  final List<String> categories = [
    "All", "Gas Filling", "Grocery", "Milk", "Internet", "Electricity", "Water",
    "Rent", "Phone Bill", "Dining Out", "Entertainment", "Healthcare",
    "Transportation", "Clothing", "Insurance", "Education", "Others"
  ];

  final Map<String, IconData> categoryIcons = {
    "Gas Filling": Icons.local_gas_station, "Grocery": Icons.shopping_cart, "Milk": Icons.local_cafe,
    "Internet": Icons.wifi, "Electricity": Icons.electric_bolt, "Water": Icons.water, "Rent": Icons.home,
    "Phone Bill": Icons.phone, "Dining Out": Icons.restaurant, "Entertainment": Icons.movie,
    "Healthcare": Icons.local_hospital, "Transportation": Icons.directions_bus, "Clothing": Icons.checkroom,
    "Insurance": Icons.shield, "Education": Icons.school, "Others": Icons.shopping_bag,
  };

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Transactions",
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[100],
      body: user == null
          ? const Center(child: Text("Please Login First!"))
          : Column(
        children: [
          // **Category Filter**
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01, horizontal: screenWidth * 0.02),
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                  child: ChoiceChip(
                    label: Text(category, style: TextStyle(fontSize: screenWidth * 0.035)),
                    selected: selectedCategory == category,
                    selectedColor: Colors.blueAccent,
                    labelStyle: TextStyle(
                        color: selectedCategory == category ? Colors.white : Colors.black),
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // **Credit & Debit Toggle**
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02, vertical: screenHeight * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToggleButton("Credit", showCredit, true, screenWidth),
                _buildToggleButton("Debit", !showCredit, false, screenWidth),
              ],
            ),
          ),

          // **Transactions List**
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('transactions')
                  .orderBy('Date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Transactions Yet!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
                  );
                }

                var transactions = snapshot.data!.docs.where((doc) {
                  var type = doc['Type'] ?? "Expense";
                  var category = doc['Category'] ?? "Others";

                  bool typeFilter = showCredit ? type == "Income" : type == "Expense";
                  bool categoryFilter = selectedCategory == "All" || category == selectedCategory;

                  return typeFilter && categoryFilter;
                }).toList();

                return transactions.isEmpty // Show message when the list is empty
                    ? Center(child: Text("No transactions match the selected filters."))
                    : ListView.separated(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[300],
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    var transaction = transactions[index].data() as Map<String, dynamic>;

                    String category = transaction["Category"] ?? "Others";
                    IconData categoryIcon = categoryIcons[category] ?? Icons.shopping_bag;
                    bool isIncome = transaction["Type"] == "Income";

                    double amount = (transaction["Amount"] as num?)?.toDouble() ?? 0.0;

                    Timestamp timestamp = transaction["Date"] as Timestamp? ?? Timestamp.now();
                    String formattedDate = DateFormat('d MMM hh:mm a').format(timestamp.toDate());

                    return _buildTransactionListItem(categoryIcon, transaction["Note"] ?? "No Note",
                        formattedDate, amount, isIncome, screenWidth, screenHeight);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// **Reusable Transaction List Item UI**
  Widget _buildTransactionListItem(
      IconData icon, String title, String date, double amount, bool isIncome, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01, horizontal: screenWidth * 0.04),
      child: Row(
        children: [
          CircleAvatar(
            radius: screenWidth * 0.06,
            backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
            child: Icon(icon, color: isIncome ? Colors.green : Colors.red, size: screenWidth * 0.06),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold)),
                Text(date, style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            "${isIncome ? '+' : '-'} ₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: screenWidth * 0.042,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// **Reusable Toggle Button for Credit/Debit**
  Widget _buildToggleButton(String text, bool isSelected, bool credit, double screenWidth) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showCredit = credit;
          });
        },
        child: Container(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
            decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(text,
                    style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)))),
      ),
    );
  }
}