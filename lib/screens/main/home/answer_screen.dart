import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/answerButton.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/screens/main/home/answer_category_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.background,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.blue500),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text('Respostas Rápidas'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10, // original (55)
          bottom: 30,
        ),
        child: Column(
          spacing: 4,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'As respostas rápidas são configuradas no aplicativo e exibidas no dispositivo, permitindo que, ao serem selecionadas, emitam um som correspondente à palavra ou frase definida.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.gray700,
                    ),
                  ),
                  Text(
                    'Categorias',
                    style: AppTextStyles.bold.copyWith(
                      color: AppColors.blue600,
                    ),
                  ),
                ],
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseAuth.instance.currentUser == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection('Usuario')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('Categorias')
                      .orderBy('criado_em', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final categorias = snapshot.data!.docs;
                return Column(
                  spacing: 10,
                  children: [
                    for (final doc in categorias)
                      FutureBuilder<QuerySnapshot>(
                        future: doc.reference.collection('Respostas').get(),
                        builder: (context, respostaSnapshot) {
                          int quantidade = 0;
                          if (respostaSnapshot.hasData) {
                            quantidade = respostaSnapshot.data!.docs.length;
                          }
                          return AnswerCategoryButton(
                            title: doc['nome'] ?? '',
                            answerAmount: '$quantidade respostas',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AnswerCategoryScreen(categoriaId: doc.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    CustomButton(
                      icon: Icons.add,
                      text: 'Adicionar Categoria',
                      fullWidth: true,
                      onPressed: () {
                        _showAddCategoryDialog(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController _categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Adicionar Categoria', style: AppTextStyles.h3.copyWith(color: AppColors.blue500)),
        content: CustomTextField(
          hintText: 'Nome da categoria',
          controller: _categoryController,
          fullWidth: true,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                text: 'Cancelar',
                color: AppColors.rose500,
                onPressed: () => Navigator.of(context).pop(),
              ),
              CustomButton(
                text: 'Salvar',
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null && _categoryController.text.isNotEmpty) {
                    await FirebaseFirestore.instance
                      .collection('Usuario')
                      .doc(user.uid)
                      .collection('Categorias')
                      .add({
                        'nome': _categoryController.text,
                        'criado_em': FieldValue.serverTimestamp(),
                      });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
