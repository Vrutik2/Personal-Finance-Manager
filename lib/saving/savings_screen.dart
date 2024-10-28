import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SavingsTransaction {
  final String id;
  final double amount;
  final DateTime date;

  SavingsTransaction({
    required this.id,
    required this.amount,
    required this.date,
  });
}

class SavingsData {
  String id;
  double targetAmount;
  double savedAmount;
  List<SavingsTransaction> transactions;

  SavingsData({
    required this.id,
    required this.targetAmount,
    this.savedAmount = 0.0,
    List<SavingsTransaction>? transactions,
  }) : transactions = transactions ?? [];

  double get remainingAmount => targetAmount - savedAmount;

  // Get today's savings
  double get dailyProgress {
    final today = DateTime.now();
    return transactions
        .where((trans) =>
            trans.date.year == today.year &&
            trans.date.month == today.month &&
            trans.date.day == today.day)
        .fold(0, (sum, trans) => sum + trans.amount);
  }

  // Get this week's savings
  double get weeklyProgress {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return transactions
        .where((trans) => trans.date.isAfter(startOfWeek))
        .fold(0, (sum, trans) => sum + trans.amount);
  }

  // Get this month's savings
  double get monthlyProgress {
    final now = DateTime.now();
    return transactions
        .where((trans) =>
            trans.date.year == now.year && trans.date.month == now.month)
        .fold(0, (sum, trans) => sum + trans.amount);
  }

  void addTransaction(double amount) {
    transactions.add(
      SavingsTransaction(
        id: DateTime.now().toString(),
        amount: amount,
        date: DateTime.now(),
      ),
    );
    savedAmount += amount;
  }

  void updateTarget(double newTarget) {
    targetAmount = newTarget;
  }
}

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  final _dateFormatter = DateFormat('MMM dd, yyyy');
  final _targetController = TextEditingController();
  final _savedController = TextEditingController();
  
  late SavingsData _savingsData;

  @override
  void initState() {
    super.initState();
    _savingsData = SavingsData(
      id: '1',
      targetAmount: 8000.0,
      savedAmount: 3342.0,
    );
  }

  @override
  void dispose() {
    _targetController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF1A2D52),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _updateTarget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Update Target Amount',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2D52),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              decoration: InputDecoration(
                labelText: 'New Target Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_targetController.text.isEmpty) {
                    _showMessage('Please enter a target amount', isError: true);
                    return;
                  }

                  double newTarget = double.parse(_targetController.text);
                  if (newTarget < _savingsData.savedAmount) {
                    _showMessage(
                      'Target cannot be less than saved amount',
                      isError: true,
                    );
                    return;
                  }

                  setState(() {
                    _savingsData.updateTarget(newTarget);
                  });

                  _targetController.clear();
                  Navigator.pop(context);
                  _showMessage('Target amount updated successfully');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2D52),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Update Target',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  void _addSavings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Savings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2D52),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _savedController,
              decoration: InputDecoration(
                labelText: 'Amount to Add',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_savedController.text.isEmpty) {
                    _showMessage('Please enter an amount', isError: true);
                    return;
                  }

                  double amount = double.parse(_savedController.text);
                  if (_savingsData.savedAmount + amount > _savingsData.targetAmount) {
                    _showMessage(
                      'Amount exceeds target',
                      isError: true,
                    );
                    return;
                  }

                  setState(() {
                    _savingsData.addTransaction(amount);
                  });

                  _savedController.clear();
                  Navigator.pop(context);
                  _showMessage('Savings added successfully');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2D52),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Savings',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _viewTransactions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Savings History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2D52),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _savingsData.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _savingsData.transactions[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.savings,
                      color: Color(0xFF1A2D52),
                    ),
                    title: Text(
                      _currencyFormatter.format(transaction.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _dateFormatter.format(transaction.date),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
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
                      'My savings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2D52),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'update_target':
                          _updateTarget();
                          break;
                        case 'view_history':
                          _viewTransactions();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'update_target',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Update Target'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'view_history',
                        child: Row(
                          children: [
                            Icon(Icons.history, size: 20),
                            SizedBox(width: 8),
                            Text('View History'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Savings Overview Cards
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSavingsCard('Target', _savingsData.targetAmount),
                  _buildSavingsCard('Saved', _savingsData.savedAmount),
                  _buildSavingsCard('Remaining', _savingsData.remainingAmount),
                ],
              ),
            ),

            // Progress Tracking Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProgressSection(
                      title: 'This month',
                      current: _savingsData.monthlyProgress,
                      target: _savingsData.targetAmount,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    _buildProgressSection(
                      title: 'This week',
                      current: _savingsData.weeklyProgress,
                      target: _savingsData.targetAmount * 0.25,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    _buildProgressSection(
                      title: 'Today',
                      current: _savingsData.dailyProgress,
                      target: _savingsData.targetAmount * 0.05,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _addSavings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2D52),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Savings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard(String label, double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        children: [
          Text(
            _currencyFormatter.format(amount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2D52),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection({
    required String title,
    required double current,
    required double target,
    required Color color,
  }) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2D52),
              ),
            ),
            Text(
              '${_currencyFormatter.format(current)} of ${_currencyFormatter.format(target)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}