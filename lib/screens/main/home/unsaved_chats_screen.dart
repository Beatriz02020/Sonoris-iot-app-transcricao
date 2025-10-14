import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/chatSelect.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/customTextField.dart';

class UnsavedChatsScreen extends StatefulWidget {
  const UnsavedChatsScreen({super.key});

  @override
  State<UnsavedChatsScreen> createState() => _UnsavedChatsScreenState();
}

class _UnsavedChatsScreenState extends State<UnsavedChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Lista estática temporária de conversas não salvas
  // Futuras melhorias:
  // 1. Integrar com backend/Firestore filtrando por usuário e flag de salvo.
  // 2. Aplicar lógica de expiração automática (cron job / cloud function) para remoção após 7 dias.
  // 3. Adicionar debounce ao campo de busca se volume crescer.
  // 4. Paginação (lazy load) se coleção ficar grande.
  final List<_UnsavedChat> _allUnsaved = [
    _UnsavedChat(
      nome: 'Conversa_04_07_25_8h',
      data: '04/07/2025',
      horarioInicial: '08:30',
      horarioFinal: '11:30',
    ),
    _UnsavedChat(
      nome: 'Conversa_03_07_25_10h',
      data: '03/07/2025',
      horarioInicial: '10:00',
      horarioFinal: '13:00',
    ),
    _UnsavedChat(
      nome: 'Conversa_02_07_25_9h',
      data: '02/07/2025',
      horarioInicial: '09:00',
      horarioFinal: '12:00',
    ),
  ];

  List<_UnsavedChat> get _filteredUnsaved {
    if (_query.isEmpty) return _allUnsaved;
    final q = _query.toLowerCase();
    return _allUnsaved.where((c) => c.nome.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.blue700),
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue700),
        title: const Text('Conversas Não Salvas'),
      ),
      body: ListView(
        children: [
          Padding(
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
                // texto do começo da página
                Text(
                  'As conversas que não forem salvas serão deletadas automaticamente após 1 semana',
                  style: AppTextStyles.body,
                ),

                // input de pesquisa
                CustomTextField(
                  hintText: 'Pesquisar',
                  isSearch: true,
                  fullWidth: true,
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _query = value?.trim() ?? '';
                    });
                  },
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: AppColors.gray500),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                        )
                      : null,
                ),

                // conversas
                Column(
                  spacing: 12,
                  children: [
                    if (_filteredUnsaved.isEmpty)
                      Text(
                        'Nenhuma conversa encontrada',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gray500,
                        ),
                      )
                    else
                      ..._filteredUnsaved.map(
                        (c) => ChatSelect(
                          nome: c.nome,
                          data: c.data,
                          horarioInicial: c.horarioInicial,
                          horarioFinal: c.horarioFinal,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnsavedChat {
  final String nome;
  final String data;
  final String horarioInicial;
  final String horarioFinal;
  _UnsavedChat({
    required this.nome,
    required this.data,
    required this.horarioInicial,
    required this.horarioFinal,
  });
}
