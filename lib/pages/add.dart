import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String selectedCategory = "Others";
  IconData selectedIcon = Icons.category;
  String _transactionType = 'Income';
  bool _isLoading = false;

  List<Map<String, dynamic>> categories = [
    {"icon": Icons.local_gas_station, "name": "Gas Filling"},
    {"icon": Icons.shopping_cart, "name": "Grocery"},
    {"icon": Icons.local_cafe, "name": "Milk"},
    {"icon": Icons.wifi, "name": "Internet"},
    {"icon": Icons.electric_bolt, "name": "Electricity"},
    {"icon": Icons.water, "name": "Water"},
    {"icon": Icons.home, "name": "Rent"},
    {"icon": Icons.phone, "name": "Phone Bill"},
    {"icon": Icons.restaurant, "name": "Dining Out"},
    {"icon": Icons.movie, "name": "Entertainment"},
    {"icon": Icons.local_hospital, "name": "Healthcare"},
    {"icon": Icons.directions_bus, "name": "Transportation"},
    {"icon": Icons.checkroom, "name": "Clothing"},
    {"icon": Icons.shield, "name": "Insurance"},
    {"icon": Icons.school, "name": "Education"},
    {"icon": Icons.shopping_bag, "name": "Others"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Add Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_amountController, "Amount", Icons.currency_rupee_sharp, TextInputType.number),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => _showCategorySelection(),
                child: _buildSelectionBox("Category", selectedIcon, selectedCategory),
              ),
              const SizedBox(height: 15),
              _buildTextField(_noteController, "Note", Icons.note_outlined, TextInputType.text),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _transactionType,
                decoration: _inputDecoration(Icons.swap_horiz),
                items: ["Income", "Expense"].map((String type) {
                  return DropdownMenuItem(
                      value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _transactionType = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Transaction", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, TextInputType keyboardType) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(icon).copyWith(labelText: label),
    );
  }

  Widget _buildSelectionBox(String label, IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      prefixIcon: Icon(icon, color: Colors.blueAccent),
    );
  }

  void _showCategorySelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = categories[index]["name"];
                    selectedIcon = categories[index]["icon"];
                  });
                  Navigator.pop(context);
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(categories[index]["icon"], size: 30, color: Colors.blueAccent),
                      const SizedBox(height: 6),
                      Text(categories[index]["name"], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// **🔹 Save Transaction to Firebase & Navigate Back Automatically**
  void _saveTransaction() async {
    String amount = _amountController.text.trim();
    String note = _noteController.text.trim();
    final User? user = FirebaseAuth.instance.currentUser;

    if (amount.isEmpty || note.isEmpty) {
      _showAlertDialog("Error", "Please fill all fields!", isSuccess: false);
      return;
    }

    double amountValue = double.tryParse(amount) ?? 0.0;
    if (amountValue <= 0) {
      _showAlertDialog("Error", "Enter a valid amount!", isSuccess: false);
      return;
    }

    if (user == null) {
      _showAlertDialog("Error", "User not logged in!", isSuccess: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('transactions').add({
        'Amount': amountValue,
        'Category': selectedCategory,
        'Note': note,
        'Type': _transactionType,
        'Date': Timestamp.now(),
      });

      // **Navigate back to Home Page after saving**
      Navigator.pop(context);
    } catch (e) {
      _showAlertDialog("Error", "Failed to save transaction!", isSuccess: false);
    }

    setState(() => _isLoading = false);
  }

  void _showAlertDialog(String title, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title, style: TextStyle(color: isSuccess ? Colors.green : Colors.red)),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        );
      },
    );
  }
}
