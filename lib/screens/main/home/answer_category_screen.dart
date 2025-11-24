import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sonoris/components/answerCategoryButton.dart';
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

  late final FlutterTts _flutterTts;

  CollectionReference<Map<String, dynamic>> get _categoriaRef {
    return FirebaseFirestore.instance
        .collection('Usuario')
        .doc(_user!.uid)
        .collection('Categorias');
  }

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    // Configurações básicas (ajuste conforme necessário)
    _flutterTts.setLanguage('pt-BR');
    _flutterTts.setSpeechRate(0.55);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakText(String text) async {
    if (text.isEmpty) return;
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Erro TTS: $e');
    }
  }

  Future<void> _reorderRespostas(
    List<QueryDocumentSnapshot> respostas,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    if (_user == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Atualizar a ordem de todos os itens afetados
      for (int i = 0; i < respostas.length; i++) {
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

        batch.update(respostas[i].reference, {'ordem': newOrder});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Erro ao reordenar respostas: $e');
    }
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
      body: SingleChildScrollView(
        child: Padding(
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

                  CustomButton(
                    icon: Icons.close,
                    iconSize: 22,
                    color: AppColors.rose500,
                    text: 'Deletar Categoria',
                    onPressed: () async {
                      final shouldDelete = await _showDeleteCategoryDialog(
                        context,
                        widget.categoriaId,
                      );
                      if (shouldDelete == true) {
                        await _deleteCategory();
                        if (mounted) Navigator.of(context).pop();
                      }
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
                            .orderBy('ordem')
                            .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final respostas = snapshot.data!.docs;
                  return Column(
                    spacing: 10,
                    children: [
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: respostas.length,
                        onReorder: (oldIndex, newIndex) {
                          _reorderRespostas(respostas, oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final doc = respostas[index];
                          return Padding(
                            key: ValueKey(doc.id),
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AnswerCategoryButton(
                              icon: Icons.close,
                              title: doc['texto'] ?? '',
                              onPressed: () => _speakText(doc['texto'] ?? ''),
                              onIconPressed: () => _deleteResponse(doc.id),
                              onDragIconPressed: () {},
                            ),
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
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, String categoriaId) {
    final TextEditingController _categoryController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Adicionar Resposta'),
            titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
            backgroundColor: AppColors.white100,
            contentPadding: const EdgeInsets.all(16),
            elevation: 0,
            content: CustomTextField(
              hintText: 'Texto da resposta',
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
                  if (_user != null && _categoryController.text.isNotEmpty) {
                    // Obter a última ordem
                    final snapshot =
                        await _categoriaRef
                            .doc(categoriaId)
                            .collection('Respostas')
                            .orderBy('ordem', descending: true)
                            .limit(1)
                            .get();

                    int novaOrdem = 0;
                    if (snapshot.docs.isNotEmpty &&
                        snapshot.docs.first.data().containsKey('ordem')) {
                      novaOrdem = (snapshot.docs.first['ordem'] as int) + 1;
                    }

                    await _categoriaRef
                        .doc(categoriaId)
                        .collection('Respostas')
                        .add({
                          'texto': _categoryController.text,
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

  void _showRenameCategoryDialog(BuildContext context, String categoriaId) {
    final TextEditingController _renameController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Renomear Categoria'),
            titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
            backgroundColor: AppColors.white100,
            contentPadding: const EdgeInsets.all(16),
            elevation: 0,
            content: CustomTextField(
              hintText: 'Novo nome da categoria',
              controller: _renameController,
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
                text: 'Salvar',
                fullWidth: true,
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
    );
  }

  Future<bool?> _showDeleteCategoryDialog(
    BuildContext context,
    String categoriaId,
  ) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Deletar categoria'),
            titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
            backgroundColor: AppColors.white100,
            contentPadding: const EdgeInsets.all(16),
            elevation: 0,
            content: Text(
              'Tem certeza que deseja deletar esta categoria e todas as respostas associadas?',
              style: AppTextStyles.body,
            ),
            actions: [
              CustomButton(
                text: 'Cancelar',
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CustomButton(
                text: 'Deletar',
                fullWidth: true,
                color: AppColors.rose500,
                onPressed: () => Navigator.of(context).pop(true),
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
