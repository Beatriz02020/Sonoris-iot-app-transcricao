import 'package:flutter/material.dart';

// TODO excluir

class CustomTitle extends StatelessWidget {
  final String text;
  final Color? color;

  const CustomTitle({
    super.key,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? Colors.blue.shade600,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class CustomSubtitle extends StatelessWidget {
  final String text;
  final Color? color;

  const CustomSubtitle({
    super.key,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}