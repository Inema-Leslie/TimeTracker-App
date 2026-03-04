import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/time_entry_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart'; // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeEntryProvider()),
      ],
      child: MaterialApp(
        title: 'Time Tracker',
        theme: AppTheme.lightTheme, // Use the theme here
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}