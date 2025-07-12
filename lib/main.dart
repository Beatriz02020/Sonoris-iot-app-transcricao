import 'package:flutter/material.dart';
import 'package:sonoris/screens/initial_screen.dart';
import 'package:sonoris/screens/select_mode_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade600),
      ),
      home:  SelectModeScreen(),
    );
  }
}
