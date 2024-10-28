import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Keys for SharedPreferences
  static const String notificationsKey = 'notifications_enabled';
  static const String darkModeKey = 'dark_mode_enabled';
  static const String currencyKey = 'selected_currency';
  static const String languageKey = 'selected_language';

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedCurrency = 'USD';
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(notificationsKey) ?? true;
      _darkModeEnabled = prefs.getBool(darkModeKey) ?? false;
      _selectedCurrency = prefs.getString(currencyKey) ?? 'USD';
      _selectedLanguage = prefs.getString(languageKey) ?? 'English';
    });
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationsKey, _notificationsEnabled);
    await prefs.setBool(darkModeKey, _darkModeEnabled);
    await prefs.setString(currencyKey, _selectedCurrency);
    await prefs.setString(languageKey, _selectedLanguage);
  }

  // Handle notifications toggle
  Future<void> _handleNotificationsChanged(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await _saveSettings();
    
    if (value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications enabled')),
      );
    }
  }

  // Handle dark mode toggle
  Future<void> _handleDarkModeChanged(bool value) async {
    setState(() {
      _darkModeEnabled = value;
    });
    await _saveSettings();
  }

  // Handle password change
  Future<void> _handlePasswordChange() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _buildChangePasswordDialog(),
    );

    if (result ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    }
  }

  // Handle logout
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Widget _buildChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter current password' : null,
            ),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter new password';
                if (value!.length < 8) return 'Password must be at least 8 characters';
                return null;
              },
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              validator: (value) => value != newPasswordController.text ? 'Passwords do not match' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
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
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A2D52)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
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

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader('Preferences'),
                  _buildSettingsTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: _handleNotificationsChanged,
                      activeColor: const Color(0xFF1A2D52),
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    trailing: Switch(
                      value: _darkModeEnabled,
                      onChanged: _handleDarkModeChanged,
                      activeColor: const Color(0xFF1A2D52),
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.attach_money,
                    title: 'Currency',
                    subtitle: _selectedCurrency,
                    onTap: () => _showCurrencyPicker(),
                  ),
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: _selectedLanguage,
                    onTap: () => _showLanguagePicker(),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Security'),
                  _buildSettingsTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: _handlePasswordChange,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A2D52),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A2D52)),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Currency',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2D52)),
              ),
              const Divider(),
              ListTile(
                title: const Text('USD'),
                onTap: () => _selectCurrency('USD'),
              ),
              ListTile(
                title: const Text('EUR'),
                onTap: () => _selectCurrency('EUR'),
              ),
              ListTile(
                title: const Text('JPY'),
                onTap: () => _selectCurrency('JPY'),
              ),
              ListTile(
                title: const Text('INR'),
                onTap: () => _selectCurrency('INR'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectCurrency(String currency) {
    setState(() {
      _selectedCurrency = currency;
    });
    _saveSettings();
    Navigator.pop(context);
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2D52)),
              ),
              const Divider(),
              ListTile(
                title: const Text('English'),
                onTap: () => _selectLanguage('English'),
              ),
              ListTile(
                title: const Text('Spanish'),
                onTap: () => _selectLanguage('Spanish'),
              ),
              ListTile(
                title: const Text('French'),
                onTap: () => _selectLanguage('French'),
              ),
              ListTile(
                title: const Text('German'),
                onTap: () => _selectLanguage('German'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    _saveSettings();
    Navigator.pop(context);
  }
}
