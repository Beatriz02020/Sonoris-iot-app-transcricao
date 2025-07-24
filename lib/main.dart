import 'package:flutter/material.dart';
import 'package:sonoris/screens/initial/initial_screen.dart';
import 'package:sonoris/components/bottomNavigationBar.dart';
import 'package:sonoris/screens/test_screen.dart';


void main() {
  runApp(const SonorisApp());
}

class SonorisApp extends StatelessWidget {
  const SonorisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonoris App',
      home:  BottomNav(),
    );
  }
}
