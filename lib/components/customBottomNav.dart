import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': 'assets/images/HomeOutlined.svg', 'selected': 'assets/images/HomeFill.svg', 'label': 'Home'},
      {'icon': 'assets/images/SavedOutlined.svg', 'selected': 'assets/images/SavedFill.svg', 'label': 'Salvos'},
      {'icon': 'assets/images/DeviceOutlined.svg', 'selected': 'assets/images/DeviceFill.svg', 'label': 'Dispositivo'},
      {'icon': 'assets/images/UserOutlined.svg', 'selected': 'assets/images/UserFill.svg', 'label': 'Perfil'},
    ];

    return Container(
      padding: const EdgeInsets.only(left: 24, top: 20, right: 24, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.blue500,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == selectedIndex;
          final iconPath = isSelected ? item['selected']! : item['icon']!;
          final label = item['label']!;

          return GestureDetector(
            onTap: () => onItemTapped(index),
            behavior: HitTestBehavior.opaque,
            child:
            SizedBox(
              width: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      isSelected ? AppColors.white100 : AppColors.white100.withValues(alpha: 0.7),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: isSelected
                        ? AppTextStyles.boldSmall.copyWith(color: AppColors.white100)
                        : AppTextStyles.bodySmall.copyWith(color: AppColors.white100.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            )

          );
        }),
      ),
    );
  }
}
