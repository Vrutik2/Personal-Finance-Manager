import 'package:flutter/material.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with back button and title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF1A2D52),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'My expenses',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2D52),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const Divider(height: 1),

            // Total Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    '\$13,342.0',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2D52),
                    ),
                  ),
                  Text(
                    '10 - 28 November',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Add Entry Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Add Value TextField
                  _buildTextField(
                    hintText: 'Add Value',
                    onAdd: () {
                      // TODO: Implement add value
                    },
                  ),
                  const SizedBox(height: 16),

                  // Add Category TextField
                  _buildTextField(
                    hintText: 'Add Category',
                    onAdd: () {
                      // TODO: Implement add category
                    },
                  ),
                  const SizedBox(height: 16),

                  // Add Date TextField
                  _buildTextField(
                    hintText: 'Add Date',
                    onAdd: () {
                      // TODO: Implement add date
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Expenses List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // Today's Date
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Today, 29 November',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2D52),
                      ),
                    ),
                  ),

                  // Expense Items
                  ExpenseItem(
                    category: 'Personal',
                    amount: 500,
                    onTap: () {
                      // TODO: Handle item tap
                    },
                  ),
                  ExpenseItem(
                    category: 'Food',
                    amount: 45,
                    onTap: () {
                      // TODO: Handle item tap
                    },
                  ),
                  ExpenseItem(
                    category: 'Others',
                    amount: 100,
                    onTap: () {
                      // TODO: Handle item tap
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required VoidCallback onAdd,
  }) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: Container(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A2D52),
              foregroundColor: Colors.white,  // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),  // Added padding
            ),
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.white,  // Explicit white color
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A2D52)),
        ),
      ),
    );
  }
}

// Keep the ExpenseItem class unchanged
class ExpenseItem extends StatelessWidget {
  final String category;
  final double amount;
  final VoidCallback onTap;

  const ExpenseItem({
    super.key,
    required this.category,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.shopping_cart,
              color: Color(0xFF1A2D52),
            ),
            const SizedBox(width: 12),
            Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A2D52),
              ),
            ),
            const Spacer(),
            Text(
              '\$$amount',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2D52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}