import 'package:flutter/material.dart';
import 'package:finance_manager/expense/expenses_screen.dart';
import 'package:finance_manager/income/incomes_screen.dart';
import 'package:finance_manager/saving/savings_screen.dart';
import 'package:finance_manager/investment/investment_screen.dart';
import 'package:finance_manager/settings/settings_screen.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            accountName: Text(
              'Username',
              style: TextStyle(
                color: Color(0xFF1A2D52),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Color(0xFF1A2D52),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ),
            ),
            accountEmail: null,
          ),
          const Divider(),

          // Home Option
          ListTile(
            leading: Image.asset(
              'assets/home_icon.png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'Home',
              style: TextStyle(
                color: Color(0xFF1A2D52),
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF1A2D52)),
            tileColor: Colors.red.withOpacity(0.1),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Savings Option
          ListTile(
            leading: Image.asset(
              'assets/savings_icon.png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'Savings',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavingsScreen(),
                ),
              );
            },
          ),

          // Investments Option
          ListTile(
            leading: Image.asset(
              'assets/investment_icon.png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'Investments',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvestmentsScreen(),
                ),
              );
            },
          ),

          // Expenses Option
          ListTile(
            leading: Image.asset(
              'assets/expense_icon.png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'Expenses',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpensesScreen(),
                ),
              );
            },
          ),

          // Income Option
          ListTile(
            leading: Image.asset(
              'assets/income_icon.png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'Income',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncomeScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Settings Option
          ListTile(
            leading: Image.asset(
              'assets/settings_icon.png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}