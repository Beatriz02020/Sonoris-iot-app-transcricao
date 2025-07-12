import 'package:flutter/material.dart';
import 'package:sonoris/screens/connection_screen.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/components/text.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: ClipRRect(
                            child: Image.asset('assets/images/Logo.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTitle(text: 'Bem-vindo ao app da sonoris.'),
                        CustomSubtitle(
                          text: 'Vamos configurar sua experiência.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Conectar Dispositivo',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConectionScreen(),
                        ),
                      );
                    },
                  ),
                  CustomButton(
                    text: 'Continur sem',
                    onPressed: () {},
                    outlined: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
