import 'package:flutter/material.dart';
import 'package:sonoris/components/bottomNavigationBar.dart';
import 'package:sonoris/components/customBottomNav.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(BuildContext context, int index)? onTap;

  const AppBottomNav({Key? key, required this.currentIndex, this.onTap})
    : super(key: key);

  void _defaultOnTap(BuildContext context, int index) {
    if (index == currentIndex) return; // nada a fazer

    // Tenta encontrar o BottomNav ancestral e alternar a aba
    final bottomNavState = BottomNav.of(context);
    if (bottomNavState != null) {
      bottomNavState.switchTab(index);
    } else {
      // Sem BottomNav no contexto; não faz navegação para evitar quebrar a pilha
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      selectedIndex: currentIndex,
      onItemTapped: (i) {
        if (onTap != null) {
          onTap!(context, i);
        } else {
          _defaultOnTap(context, i);
        }
      },
    );
  }
}
