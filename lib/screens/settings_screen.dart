import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the corrected font family names here
    final availableFonts = ['Roboto', 'Modulus', 'JetBrainsMono'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              // --- Dark Mode ---
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: appProvider.themeMode == ThemeMode.dark,
                onChanged: (value) => appProvider.toggleTheme(),
              ),
              const Divider(),
              // --- Font Size ---
              ListTile(
                title: const Text('Font Size'),
                subtitle: Slider(
                  value: appProvider.fontSizeMultiplier,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  label: appProvider.fontSizeMultiplier.toStringAsFixed(1),
                  onChanged: (value) => appProvider.changeFontSize(value),
                ),
              ),
              const Divider(),
              // --- Font Family ---
              ListTile(
                title: const Text('Font Family'),
                trailing: DropdownButton<String>(
                  // Ensure the value exists in the list to avoid errors
                  value: availableFonts.contains(appProvider.fontFamily)
                      ? appProvider.fontFamily
                      : 'Roboto',
                  items: availableFonts.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontFamily: value)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      appProvider.changeFontFamily(newValue);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}