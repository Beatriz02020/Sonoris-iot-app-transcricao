import 'package:flutter/material.dart';
import 'package:sonoris/components/customBottomNav.dart';
import 'package:sonoris/components/bottomNavigationBar.dart';

/// AppBottomNav: bottom navigation reutilizável para colocar em qualquer
/// Scaffold via `bottomNavigationBar: AppBottomNav(currentIndex: X)`.
///
/// - `currentIndex` indica a aba ativa (0..3).
/// - `onTap` (opcional) permite interceptar toques; se não fornecido, o
///   widget solicitará ao `BottomNav` ancestral para alternar a aba atual.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(BuildContext context, int index)? onTap;

  const AppBottomNav({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  void _defaultOnTap(BuildContext context, int index) {
    if (index == currentIndex) return; // nada a fazer

    // Tenta encontrar o BottomNav ancestral e alternar a aba
    final bottomNavState = BottomNav.of(context);
    if (bottomNavState != null) {
      bottomNavState.switchTab(index);
    } else {
      // Sem BottomNav no contexto; não faz navegação para evitar quebrar a pilha
      // Opcional: poderia redirecionar para '/main', mas mantemos seguro aqui.
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
