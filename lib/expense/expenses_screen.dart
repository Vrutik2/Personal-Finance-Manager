import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _valueController = TextEditingController();
  final _categoryController = TextEditingController();
  final _dateController = TextEditingController();
  final _formatter = DateFormat('MMM dd, yyyy');
  final _currencyFormatter =
      NumberFormat.currency(locale: 'en_US', symbol: '\$');
  String? _editingId;
  bool _isLoading = false;

  // Predefined categories with icons
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Personal', 'icon': Icons.person},
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Transport', 'icon': Icons.directions_car},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Bills', 'icon': Icons.receipt},
    {'name': 'Others', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> _expenses = [
    {
      'id': '1',
      'category': 'Personal',
      'amount': 500.0,
      'date': DateTime.now(),
    },
    {
      'id': '2',
      'category': 'Food',
      'amount': 45.0,
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '3',
      'category': 'Others',
      'amount': 100.0,
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatter.format(DateTime.now());
  }

  @override
  void dispose() {
    _valueController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF1A2D52),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleDelete(String id) async {
    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _expenses.removeWhere((item) => item['id'] == id);
      _isLoading = false;
    });

    _showMessage('Expense deleted successfully');
  }

  void _editExpense(Map<String, dynamic> expense) {
    setState(() {
      _editingId = expense['id'];
      _valueController.text = expense['amount'].toString();
      _categoryController.text = expense['category'];
      _dateController.text = _formatter.format(expense['date']);
    });
  }

  Future<void> _addOrUpdateExpense() async {
    // Validate amount
    if (_valueController.text.isEmpty) {
      _showMessage('Please enter an amount', isError: true);
      return;
    }

    double? amount;
    try {
      amount = double.parse(_valueController.text.replaceAll(',', ''));
      if (amount <= 0) throw const FormatException();
    } catch (e) {
      _showMessage('Please enter a valid amount', isError: true);
      return;
    }

    // Validate category
    if (_categoryController.text.isEmpty) {
      _showMessage('Please select a category', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      if (_editingId != null) {
        // Update existing expense
        int index = _expenses.indexWhere((e) => e['id'] == _editingId);
        if (index != -1) {
          _expenses[index] = {
            'id': _editingId!,
            'category': _categoryController.text,
            'amount': amount,
            'date': DateFormat('MMM dd, yyyy').parse(_dateController.text),
          };
        }
        _editingId = null;
        _showMessage('Expense updated successfully');
      } else {
        // Add new expense
        _expenses.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'category': _categoryController.text,
          'amount': amount,
          'date': DateFormat('MMM dd, yyyy').parse(_dateController.text),
        });
        _showMessage('Expense added successfully');
      }

      // Clear inputs
      _valueController.clear();
      _categoryController.clear();
      _dateController.text = _formatter.format(DateTime.now());
      _isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A2D52),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = _formatter.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses =
        _expenses.fold(0, (sum, expense) => sum + expense['amount']);

    return Stack(
      children: [
        Scaffold(
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
                  child: Column(
                    children: [
                      Text(
                        _currencyFormatter.format(totalExpenses),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2D52),
                        ),
                      ),
                      const Text(
                        'Total Expenses',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Add/Edit Entry Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Amount Input
                      TextField(
                        controller: _valueController,
                        decoration: InputDecoration(
                          hintText: 'Enter Amount',
                          prefixText: '\$ ',
                          suffixIcon: Container(
                            padding: const EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: _addOrUpdateExpense,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A2D52),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  Text(_editingId != null ? 'Update' : 'Add'),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            try {
                              final number = double.parse(newValue.text);
                              final formatted =
                                  _currencyFormatter.format(number);
                              return TextEditingValue(
                                text: formatted.substring(1),
                                selection: TextSelection.collapsed(
                                    offset: formatted.length - 1),
                              );
                            } catch (e) {
                              return newValue;
                            }
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _categoryController.text.isEmpty
                            ? null
                            : _categoryController.text,
                        decoration: InputDecoration(
                          hintText: 'Select Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['name'],
                            child: Row(
                              children: [
                                Icon(category['icon'],
                                    size: 20, color: const Color(0xFF1A2D52)),
                                const SizedBox(width: 8),
                                Text(category['name']),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _categoryController.text = newValue;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date Input
                      TextField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _selectDate,
                        decoration: InputDecoration(
                          hintText: 'Select Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _selectDate,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Expenses List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return Dismissible(
                        key: Key(expense['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Expense'),
                              content: const Text(
                                  'Are you sure you want to delete this expense?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (result ?? false) {
                            _handleDelete(expense['id']);
                            return true;
                          }
                          return false;
                        },
                        child: GestureDetector(
                          onTap: () => _editExpense(expense),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A2D52)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _categories.firstWhere(
                                      (cat) =>
                                          cat['name'] == expense['category'],
                                      orElse: () => _categories.last,
                                    )['icon'],
                                    color: const Color(0xFF1A2D52),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense['category'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF1A2D52),
                                        ),
                                      ),
                                      Text(
                                        _formatter.format(expense['date']),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _currencyFormatter.format(expense['amount']),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A2D52),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A2D52)),
              ),
            ),
          ),
      ],
    );
  }
}
