import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MinimalJournalApp(),
    ),
  );
}

class MinimalJournalApp extends StatelessWidget {
  const MinimalJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Minimal Journal',
          themeMode: appProvider.themeMode,
          theme: _buildThemeData(Brightness.light, appProvider),
          darkTheme: _buildThemeData(Brightness.dark, appProvider),
          home: const HomeScreen(),
        );
      },
    );
  }

  ThemeData _buildThemeData(Brightness brightness, AppProvider appProvider) {
    final baseTheme = ThemeData(
      brightness: brightness,
      primarySwatch: Colors.blueGrey,
      fontFamily: appProvider.fontFamily,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: brightness == Brightness.light ? Colors.grey[50] : Colors.grey[900],
      textTheme: _applyFontSize(baseTheme.textTheme, appProvider.fontSizeMultiplier),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: appProvider.fontFamily,
          fontSize: 22 * appProvider.fontSizeMultiplier,
          fontWeight: FontWeight.bold,
          color: brightness == Brightness.light ? Colors.black87 : Colors.white,
        ),
        iconTheme: IconThemeData(
          color: brightness == Brightness.light ? Colors.black54 : Colors.white70,
        ),
      ),
    );
  }

  TextTheme _applyFontSize(TextTheme base, double sizeMultiplier) {
    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16.0 * sizeMultiplier),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14.0 * sizeMultiplier),
      titleLarge: base.titleLarge?.copyWith(fontSize: 22.0 * sizeMultiplier),
      titleMedium: base.titleMedium?.copyWith(fontSize: 16.0 * sizeMultiplier),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 24.0 * sizeMultiplier),
    );
  }
}