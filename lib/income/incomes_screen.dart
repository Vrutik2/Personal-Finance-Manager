// lib/screens/income_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _valueController = TextEditingController();
  final _monthController = TextEditingController();
  final _formatter = DateFormat('MMMM yyyy');
  final _currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  String? _selectedCategory;
  String? _editingId;

  // Predefined income categories with icons
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Salary', 'icon': Icons.account_balance_wallet},
    {'name': 'Freelance', 'icon': Icons.computer},
    {'name': 'Investments', 'icon': Icons.trending_up},
    {'name': 'Business', 'icon': Icons.store},
    {'name': 'Rental', 'icon': Icons.home},
    {'name': 'Others', 'icon': Icons.more_horiz},
  ];

  // Sample income data
  final List<Map<String, dynamic>> _incomeList = [
    {
      'id': '1',
      'category': 'Salary',
      'amount': 5000.0,
      'date': DateTime.now(),
    },
    {
      'id': '2',
      'category': 'Freelance',
      'amount': 2000.0,
      'date': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': '3',
      'category': 'Rental',
      'amount': 1200.0,
      'date': DateTime.now().subtract(const Duration(days: 60)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _monthController.text = _formatter.format(DateTime.now());
  }

  @override
  void dispose() {
    _valueController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF1A2D52),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleDelete(String id) {
    setState(() {
      _incomeList.removeWhere((item) => item['id'] == id);
    });
    _showMessage('Income entry deleted successfully');
  }

  void _editIncome(Map<String, dynamic> income) {
    setState(() {
      _editingId = income['id'];
      _valueController.text = income['amount'].toString();
      _selectedCategory = income['category'];
      _monthController.text = _formatter.format(income['date']);
    });
  }

  void _addOrUpdateIncome() {
    if (_valueController.text.isEmpty || _selectedCategory == null) {
      _showMessage('Please fill all fields', isError: true);
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

    setState(() {
      if (_editingId != null) {
        // Update existing income
        int index = _incomeList.indexWhere((e) => e['id'] == _editingId);
        if (index != -1) {
          _incomeList[index] = {
            'id': _editingId!,
            'category': _selectedCategory!,
            'amount': amount,
            'date': DateFormat('MMMM yyyy').parse(_monthController.text),
          };
        }
        _editingId = null;
        _showMessage('Income updated successfully');
      } else {
        // Add new income
        _incomeList.add({
          'id': DateTime.now().toString(),
          'category': _selectedCategory!,
          'amount': amount,
          'date': DateFormat('MMMM yyyy').parse(_monthController.text),
        });
        _showMessage('Income added successfully');
      }
      
      // Clear inputs
      _valueController.clear();
      _selectedCategory = null;
      _monthController.text = _formatter.format(DateTime.now());
    });
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
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
        _monthController.text = _formatter.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort income list by date in descending order
    _incomeList.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    // Calculate total income
    double totalIncome = _incomeList.fold(0, (sum, item) => sum + (item['amount'] as double));

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
                      'My Income',
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

            // Total Income Card
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
                    _currencyFormatter.format(totalIncome),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2D52),
                    ),
                  ),
                  const Text(
                    'Total Income',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Income Input Section
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
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
                            Icon(
                              category['icon'],
                              color: const Color(0xFF1A2D52),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(category['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Month Selection
                  TextField(
                    controller: _monthController,
                    readOnly: true,
                    onTap: _selectMonth,
                    decoration: InputDecoration(
                      hintText: 'Select Month',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectMonth,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add/Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addOrUpdateIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2D52),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _editingId != null ? 'Update Income' : 'Add Income',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Income List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _incomeList.length,
                itemBuilder: (context, index) {
                  final income = _incomeList[index];
                  final icon = _categories.firstWhere(
                    (cat) => cat['name'] == income['category'],
                    orElse: () => _categories.last,
                  )['icon'];

                  return Dismissible(
                    key: Key(income['id']),
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
                          title: const Text('Delete Income Entry'),
                          content: const Text(
                            'Are you sure you want to delete this income entry?'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (result ?? false) {
                        _handleDelete(income['id']);
                        return true;
                      }
                      return false;
                    },
                    child: GestureDetector(
                      onTap: () => _editIncome(income),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2)
                          ),
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
                                icon,
                                color: const Color(0xFF1A2D52),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    income['category'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A2D52),
                                    ),
                                  ),
                                  Text(
                                    _formatter.format(income['date']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _currencyFormatter.format(income['amount']),
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
    );
  }
}