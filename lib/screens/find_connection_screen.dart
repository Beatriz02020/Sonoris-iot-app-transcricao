import 'package:flutter/material.dart';
import '../components/text.dart';

class FindConnectionScreen extends StatefulWidget {
  const FindConnectionScreen({super.key});

  @override
  State<FindConnectionScreen> createState() => _FindConnectionScreenState();
}

class _FindConnectionScreenState extends State<FindConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 20),
              child: SizedBox(
                width: 250,
                height: 250,
                child: ClipRRect(child: Image.asset('assets/images/Logo.png')),
              ),
            ),
            CustomTitle(text: 'Paremento'),
            CustomSubtitle(text: 'Selecione seu dispositivo:'),
            Container(color: Colors.black12, width: 330, height: 330),
          ],
        ),
      ),
    );
  }
}
