import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Investment {
  final String type;
  final double amount;
  final Color color;

  Investment({
    required this.type,
    required this.amount,
    required this.color,
  });
}

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  final List<Investment> investments = [];
  final TextEditingController valueController = TextEditingController();
  String? selectedType;
  
  // Map to store colors for different investment types
  final Map<String, Color> typeColors = {
    'Stocks': Colors.blue,
    'Bonds': Colors.green,
    'Crypto': Colors.orange,
    'Real Estate': Colors.purple,
    'Commodities': Colors.amber,
    'Cash': Colors.teal,
  };

  double get totalInvestment {
    return investments.fold(0, (sum, investment) => sum + investment.amount);
  }

  Map<String, double> get investmentsByType {
    final Map<String, double> result = {};
    for (var investment in investments) {
      result[investment.type] = (result[investment.type] ?? 0) + investment.amount;
    }
    return result;
  }

  void addInvestment() {
    if (valueController.text.isEmpty || selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    final amount = double.tryParse(valueController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
      return;
    }

    final color = typeColors[selectedType];
    if (color == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid investment type selected')),
      );
      return;
    }

    setState(() {
      investments.add(Investment(
        type: selectedType!,
        amount: amount,
        color: color,
      ));
    });

    // Clear the inputs
    valueController.clear();
    setState(() {
      selectedType = null;
    });
  }

  List<PieChartSectionData> getSections() {
    if (investments.isEmpty) {
      return [
        PieChartSectionData(
          title: '100%',
          value: 100,
          color: Colors.grey.shade300,
          radius: 80,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ];
    }

    final Map<String, double> aggregated = investmentsByType;
    return aggregated.entries.map((entry) {
      final color = typeColors[entry.key];
      if (color == null) {
        // Provide a fallback color if the type's color is not found
        return PieChartSectionData(
          title: '',
          value: entry.value,
          color: Colors.grey,
          radius: 80,
        );
      }

      final percentage = (entry.value / totalInvestment) * 100;
      return PieChartSectionData(
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        value: entry.value,
        color: color,
        radius: 80,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  List<Widget> getLegendItems() {
    if (investments.isEmpty) {
      return [_buildLegendItem('No investments yet', Colors.grey.shade300)];
    }

    final Map<String, double> aggregated = investmentsByType;
    return aggregated.entries.map((entry) {
      final color = typeColors[entry.key] ?? Colors.grey;
      final percentage = (entry.value / totalInvestment) * 100;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildLegendItem(
          '${entry.key} (${percentage.toStringAsFixed(1)}%)',
          color,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                      'My Investments',
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

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(
                    controller: valueController,
                    hintText: 'Add Value',
                    keyboardType: TextInputType.number,
                    onAdd: addInvestment,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(),
                ],
              ),
            ),

            Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: getSections(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: getLegendItems(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Previous Investments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2D52),
                    ),
                  ),
                  Text(
                    'Total: \$${totalInvestment.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2D52),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: investments.length,
                itemBuilder: (context, index) {
                  final investment = investments[index];
                  return Dismissible(
                    key: Key(investment.type + index.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        investments.removeAt(index);
                      });
                    },
                    child: _buildInvestmentItem(investment),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedType,
                hint: const Text('Select Investment Type'),
                isExpanded: true,
                items: typeColors.keys.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: typeColors[type],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(type),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue;
                  });
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: addInvestment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2D52),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onAdd,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A2D52),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentItem(Investment investment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2D52).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance,
              color: investment.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            investment.type,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1A2D52),
            ),
          ),
          const Spacer(),
          Text(
            '\$${investment.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2D52),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }
}