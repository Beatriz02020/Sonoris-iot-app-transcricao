import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customSelect.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/models/conversa.dart';
import 'package:sonoris/services/conversa_service.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class SavingChatScreen extends StatefulWidget {
  final ConversaNaoSalva conversa;

  const SavingChatScreen({super.key, required this.conversa});

  @override
  State<SavingChatScreen> createState() => _SavingChatScreenState();
}

class _SavingChatScreenState extends State<SavingChatScreen> {
  final ConversaService _conversaService = ConversaService();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  int? _selectedCategoryIndex;
  String _selectedCategory = 'Outros';
  bool _isFavorito = false;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Estudos',
      'color': AppColors.blue600,
      'image': 'assets/images/icons/Estudos.png',
    },
    {
      'name': 'Trabalho',
      'color': AppColors.teal600,
      'image': 'assets/images/icons/Trabalho.png',
    },
    {
      'name': 'Pessoal',
      'color': AppColors.rose600,
      'image': 'assets/images/icons/Pessoal.png',
    },
    {
      'name': 'Reunião',
      'color': AppColors.green600,
      'image': 'assets/images/icons/Reuniao.png',
    },
    {
      'name': 'Teams',
      'color': AppColors.indigo600,
      'image': 'assets/images/icons/Teams.png',
    },
    {
      'name': 'Outros',
      'color': AppColors.gray700,
      'image': 'assets/images/icons/Outros.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Preencher nome com o nome original da conversa
    _nomeController.text = widget.conversa.nome;
    // Definir categoria padrão como "Outros" (índice 6)
    _selectedCategoryIndex = 5;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColors.white100,
          systemNavigationBarColor: AppColors.blue500,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarConversa() async {
    // Validar campos
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um nome para a conversa'),
          backgroundColor: AppColors.rose500,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final conversaId = await _conversaService.salvarConversa(
        conversaNaoSalva: widget.conversa,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        categoria: _selectedCategory,
        favorito: _isFavorito,
      );

      if (!mounted) return;

      if (conversaId != null) {
        // Sucesso - volta para a tela anterior (2 vezes para sair do unsaved_chat_screen também)
        Navigator.of(context).pop();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversa salva com sucesso!'),
            backgroundColor: AppColors.teal500,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar conversa'),
            backgroundColor: AppColors.rose500,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.rose500),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildCategoryItem({
    required String assetPath,
    required String label,
    required Color labelColor,
    required int index,
  }) {
    final bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
          _selectedCategory = _categories[index]['name'];
        });
      },
      child: Column(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: AppColors.gray300,
                          blurRadius: 6,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    assetPath,
                    width: 53,
                    height: 53,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isSelected) ...[
                  Positioned.fill(
                    child: ClipOval(
                      child: Container(color: AppColors.gray900.withAlpha(50)),
                    ),
                  ),
                  const Icon(Icons.check, color: Colors.white, size: 45),
                ],
              ],
            ),
          ),
          Text(label, style: AppTextStyles.bold.copyWith(color: labelColor)),
        ],
      ),
    );
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
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.blue500),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text('Salvar Conversa'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 30,
            right: 30,
            top: 25,
            bottom: 30,
          ),
          child: Column(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 95,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Estudos.png',
                          label: 'Estudos',
                          labelColor: AppColors.blue600,
                          index: 0,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Trabalho.png',
                          label: 'Trabalhos',
                          labelColor: AppColors.teal600,
                          index: 1,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Pessoal.png',
                          label: 'Pessoal',
                          labelColor: AppColors.rose600,
                          index: 2,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Reuniao.png',
                          label: 'Reunião',
                          labelColor: AppColors.green600,
                          index: 3,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Teams.png',
                          label: 'Teams',
                          labelColor: AppColors.indigo600,
                          index: 4,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Outros.png',
                          label: 'Outros',
                          labelColor: AppColors.gray700,
                          index: 5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Text(
                'Nome',
                style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: CustomTextField(
                  controller: _nomeController,
                  hintText: 'Nome da conversa',
                ),
              ),

              Text(
                'Descrição',
                style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: CustomTextField(
                  controller: _descricaoController,
                  hintText: 'Descrição',
                  verticalPadding: 70,
                ),
              ),

              Text(
                'Favorito?',
                style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 45),
                child: CustomSelect(
                  options: ['Sim', 'Não'],
                  value: _isFavorito ? 'Sim' : 'Não',
                  onChanged: (value) {
                    setState(() {
                      _isFavorito = value == 'Sim';
                    });
                  },
                ),
              ),
              CustomButton(
                text: _isSaving ? 'Salvando...' : 'Salvar Conversa',
                fullWidth: true,
                onPressed: _isSaving ? null : _salvarConversa,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
