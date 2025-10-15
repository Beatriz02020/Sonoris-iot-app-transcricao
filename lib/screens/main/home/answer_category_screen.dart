import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/answerButton.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class AnswerCategoryScreen extends StatefulWidget {
  final String categoriaId;
  const AnswerCategoryScreen({super.key, required this.categoriaId});

  @override
  State<AnswerCategoryScreen> createState() => _AnswerCategoryScreenState();
}

class _AnswerCategoryScreenState extends State<AnswerCategoryScreen> {
  User? get _user => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>> get _categoriaRef {
    return FirebaseFirestore.instance
        .collection('Usuario')
        .doc(_user!.uid)
        .collection('Categorias');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.background,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: StreamBuilder<DocumentSnapshot>(
          stream:
              _user == null
                  ? null
                  : _categoriaRef.doc(widget.categoriaId).snapshots(),
          builder: (context, snapshot) {
            String nomeCategoria = 'Categoria';
            if (snapshot.hasData && snapshot.data!.exists) {
              nomeCategoria = snapshot.data!['nome'] ?? 'Categoria';
            }
            return AppBar(
              backgroundColor: AppColors.background,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: AppColors.blue500),
              titleTextStyle: AppTextStyles.h3.copyWith(
                color: AppColors.blue500,
              ),
              title: Text(nomeCategoria),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10, // original (55)
          bottom: 30,
        ),
        child: Column(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  icon: Icons.edit,
                  iconSize: 20,
                  text: 'Renomear',
                  onPressed: () {
                    _showRenameCategoryDialog(context, widget.categoriaId);
                  },
                ),

                //TODO: Adicionar confirmação antes de deletar
                CustomButton(
                  icon: Icons.close,
                  iconSize: 22,
                  color: AppColors.rose500,
                  text: 'Deletar Categoria',
                  onPressed: () async {
                    await _deleteCategory();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Text(
              'Respostas',
              style: AppTextStyles.bold.copyWith(color: AppColors.blue600),
            ),
            StreamBuilder<QuerySnapshot>(
              stream:
                  _user == null
                      ? null
                      : _categoriaRef
                          .doc(widget.categoriaId)
                          .collection('Respostas')
                          .orderBy('criado_em', descending: true)
                          .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final respostas = snapshot.data!.docs;
                return Column(
                  spacing: 10,
                  children: [
                    for (final doc in respostas)
                      AnswerCategoryButton(
                        icon: Icons.close,
                        title: doc['texto'] ?? '',
                        onPressed: () {},
                        onIconPressed: () => _deleteResponse(doc.id),
                        onDragIconPressed: () {
                          _showEditResponseDialog(
                            context,
                            doc.id,
                            doc['texto'] ?? '',
                          );
                        },
                      ),
                    CustomButton(
                      icon: Icons.add,
                      text: 'Adicionar Resposta',
                      fullWidth: true,
                      onPressed: () {
                        _showAddCategoryDialog(context, widget.categoriaId);
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

  void _showAddCategoryDialog(BuildContext context, String categoriaId) {
    final TextEditingController _categoryController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Adicionar Resposta',
              style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
            ),
            content: CustomTextField(
              hintText: 'Texto da resposta',
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
                      if (_user != null &&
                          _categoryController.text.isNotEmpty) {
                        await _categoriaRef
                            .doc(categoriaId)
                            .collection('Respostas')
                            .add({
                              'texto': _categoryController.text,
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

  void _showRenameCategoryDialog(BuildContext context, String categoriaId) {
    final TextEditingController _renameController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Renomear Categoria',
              style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
            ),
            content: CustomTextField(
              hintText: 'Novo nome da categoria',
              controller: _renameController,
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
                      if (_user != null && _renameController.text.isNotEmpty) {
                        await _categoriaRef.doc(categoriaId).update({
                          'nome': _renameController.text,
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

  void _showEditResponseDialog(
    BuildContext context,
    String respostaId,
    String textoAtual,
  ) {
    final controller = TextEditingController(text: textoAtual);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Editar Resposta',
              style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
            ),
            content: CustomTextField(
              hintText: 'Texto da resposta',
              controller: controller,
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
                      if (_user != null && controller.text.isNotEmpty) {
                        await _categoriaRef
                            .doc(widget.categoriaId)
                            .collection('Respostas')
                            .doc(respostaId)
                            .update({'texto': controller.text});
                        if (mounted) Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Future<void> _deleteResponse(String respostaId) async {
    if (_user == null) return;
    try {
      await _categoriaRef
          .doc(widget.categoriaId)
          .collection('Respostas')
          .doc(respostaId)
          .delete();
    } catch (e) {
      debugPrint('Erro ao deletar resposta: $e');
    }
  }

  Future<void> _deleteCategory() async {
    if (_user == null) return;
    try {
      final categoriaRef = _categoriaRef.doc(widget.categoriaId);
      final respostasSnapshot =
          await categoriaRef.collection('Respostas').get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in respostasSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(categoriaRef);
      await batch.commit();
    } catch (e) {
      debugPrint('Erro ao deletar categoria: $e');
    }
  }
}
