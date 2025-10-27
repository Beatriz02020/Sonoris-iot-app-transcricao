import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/answerCategoryButton.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/screens/main/home/answer_category_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  Future<void> _reorderCategories(
    List<QueryDocumentSnapshot> categorias,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Atualizar a ordem de todos os itens afetados
      for (int i = 0; i < categorias.length; i++) {
        int newOrder;
        if (i == oldIndex) {
          newOrder = newIndex;
        } else if (oldIndex < newIndex) {
          if (i > oldIndex && i <= newIndex) {
            newOrder = i - 1;
          } else {
            newOrder = i;
          }
        } else {
          if (i >= newIndex && i < oldIndex) {
            newOrder = i + 1;
          } else {
            newOrder = i;
          }
        }

        batch.update(categorias[i].reference, {'ordem': newOrder});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Erro ao reordenar categorias: $e');
    }
  }

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
      body: SingleChildScrollView(
        child: Padding(
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
                      'As respostas rápidas préviamente configuradas, podem ser clicadas, emitindo um som correspondente à palavra ou frase definida.',
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
                stream:
                    FirebaseAuth.instance.currentUser == null
                        ? null
                        : FirebaseFirestore.instance
                            .collection('Usuario')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('Categorias')
                            .orderBy('ordem')
                            .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final categorias = snapshot.data!.docs;

                  return Column(
                    spacing: 10,
                    children: [
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: categorias.length,
                        onReorder: (oldIndex, newIndex) {
                          _reorderCategories(categorias, oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final doc = categorias[index];
                          return FutureBuilder<QuerySnapshot>(
                            key: ValueKey(doc.id),
                            future: doc.reference.collection('Respostas').get(),
                            builder: (context, respostaSnapshot) {
                              int quantidade = 0;
                              if (respostaSnapshot.hasData) {
                                quantidade = respostaSnapshot.data!.docs.length;
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AnswerCategoryButton(
                                  title: doc['nome'] ?? '',
                                  answerAmount: '$quantidade respostas',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AnswerCategoryScreen(
                                              categoriaId: doc.id,
                                            ),
                                      ),
                                    );
                                  },
                                  onDragIconPressed: () {},
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
      ),
    );
  }
}

void _showAddCategoryDialog(BuildContext context) {
  final TextEditingController _categoryController = TextEditingController();
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Adicionar Categoria'),
          titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
          backgroundColor: AppColors.white100,
          contentPadding: const EdgeInsets.all(16),
          elevation: 0,
          content: CustomTextField(
            hintText: 'Nome da categoria',
            controller: _categoryController,
            fullWidth: true,
          ),
          actions: [
            CustomButton(
              text: 'Cancelar',
              fullWidth: true,
              color: AppColors.rose500,
              onPressed: () => Navigator.of(context).pop(),
            ),
            CustomButton(
              text: 'Adicionar',
              fullWidth: true,
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && _categoryController.text.isNotEmpty) {
                  // Obter a última ordem
                  final snapshot =
                      await FirebaseFirestore.instance
                          .collection('Usuario')
                          .doc(user.uid)
                          .collection('Categorias')
                          .orderBy('ordem', descending: true)
                          .limit(1)
                          .get();

                  int novaOrdem = 0;
                  if (snapshot.docs.isNotEmpty &&
                      snapshot.docs.first.data().containsKey('ordem')) {
                    novaOrdem = (snapshot.docs.first['ordem'] as int) + 1;
                  }

                  await FirebaseFirestore.instance
                      .collection('Usuario')
                      .doc(user.uid)
                      .collection('Categorias')
                      .add({
                        'nome': _categoryController.text,
                        'criado_em': FieldValue.serverTimestamp(),
                        'ordem': novaOrdem,
                      });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
  );
}
