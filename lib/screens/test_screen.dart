import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/theme/colors.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.white100,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var weight in [100.00, 200.00, 300.00, 400.00, 500.00, 600.00, 700.00, 800.00, 900.00])
              Text(
                'SourceSans3 peso $weight',
                style: TextStyle(
                  fontFamily: 'SourceSans3Variavel',
                  fontSize: 24,
                    fontVariations: <FontVariation>[FontVariation('wght', weight)]
                ),
              ),
          ],
        ),
      )
    );
  }
}
