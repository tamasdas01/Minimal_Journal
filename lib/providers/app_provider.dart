import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  // Theme settings
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  // Font settings
  double _fontSizeMultiplier = 1.0;
  double get fontSizeMultiplier => _fontSizeMultiplier;

  String _fontFamily = 'Roboto'; // Default font
  String get fontFamily => _fontFamily;

  AppProvider() {
    _loadSettings();
  }

  // --- Theme Methods ---
  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // --- Font Methods ---
  void changeFontSize(double newMultiplier) async {
    _fontSizeMultiplier = newMultiplier;
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSizeMultiplier', _fontSizeMultiplier);
    notifyListeners();
  }

  void changeFontFamily(String newFamily) async {
    _fontFamily = newFamily;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fontFamily', _fontFamily);
    notifyListeners();
  }

  // --- Persistence ---
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Load theme
    _themeMode = (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light;
    // Load font size
    _fontSizeMultiplier = prefs.getDouble('fontSizeMultiplier') ?? 1.0;
    // Load font family
    _fontFamily = prefs.getString('fontFamily') ?? 'Roboto';
    notifyListeners();
  }
}