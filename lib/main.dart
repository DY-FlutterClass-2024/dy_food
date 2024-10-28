import 'package:dy_food_flutter/home_screen.dart';
import 'package:dy_food_flutter/bmi_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: HomeScreen(),
      routes: {
        '/': (context) => const HomeScreen(),
        '/bmi': (context) => const BmiScreen()
      },
      initialRoute: '/',
    );
  }
}
