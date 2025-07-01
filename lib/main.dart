import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),

      home: Scaffold(
        body: Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: Image.asset('assets/images/Logo.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            'Bem-vindo ao app da sonoris.',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            'vamos configurar sua experiência.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                        ),
                        onPressed: () {},
                        child: Text(
                          'Cadastrar-se',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 250, 
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.indigoAccent, 
                            width: 2, 
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.indigo, fontSize: 18),
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 10)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
