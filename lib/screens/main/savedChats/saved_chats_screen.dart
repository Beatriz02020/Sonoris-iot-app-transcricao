import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/chatSelect.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/customTextField.dart';
import '../home/unsaved_chats_screen.dart';

class SavedChatsScreen extends StatefulWidget {
  const SavedChatsScreen({super.key});

  @override
  State<SavedChatsScreen> createState() => _SavedChatsScreenState();
}

class _SavedChatsScreenState extends State<SavedChatsScreen> {
  // Controlador e estado da pesquisa
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Novo: filtro selecionado (null = nenhum)
  String? _selectedFilter;

  // Lista de filtros com label e asset e cor (usada para construir a UI)
  final List<Map<String, dynamic>> _filters = [
    {
      'key': 'Favoritos',
      'asset': 'assets/images/icons/Favoritos.png',
      'color': AppColors.amber600,
    },
    {
      'key': 'Estudos',
      'asset': 'assets/images/icons/Estudos.png',
      'color': AppColors.blue600,
    },
    {
      'key': 'Trabalho',
      'asset': 'assets/images/icons/Trabalho.png',
      'color': AppColors.teal600,
    },
    {
      'key': 'Pessoal',
      'asset': 'assets/images/icons/Pessoal.png',
      'color': AppColors.rose600,
    },
    {
      'key': 'Reuniao',
      'asset': 'assets/images/icons/Reuniao.png',
      'color': AppColors.green600,
    },
    {
      'key': 'Teams',
      'asset': 'assets/images/icons/Teams.png',
      'color': AppColors.indigo600,
    },
    {
      'key': 'Outros',
      'asset': 'assets/images/icons/Outros.png',
      'color': AppColors.gray700,
    },
    {
      'key': 'Customizado',
      'asset': 'assets/images/icons/Customizado.png',
      'color': AppColors.gray700,
    },
  ];

  // Lista estática temporária de conversas salvas (mock). Em futura integração,
  // isto pode vir do Firestore ou outra fonte dinâmica.
  // Futuras melhorias:
  // 1. Buscar dados do Firestore ordenando por data/hora.
  // 2. Adicionar debounce (ex: Timer 300ms) se a coleção ficar grande.
  // 3. Implementar filtros de categorias (Favoritos, Estudos, etc.) combinando com busca.
  // 4. Paginação/infinite scroll caso volume cresça.
  final List<_SavedChat> _allChats = [
    _SavedChat(
      nome: 'Reuniao SoftSkills',
      data: '02/07/2025',
      horarioInicial: '09:00',
      horarioFinal: '12:00',
      image: 'Teams',
      favorito: true,
      descricao: 'DescriçãoDescriçãoDescriçasdsada',
    ),
    _SavedChat(
      nome: 'Workshop de Criatividade',
      data: '02/07/2025',
      horarioInicial: '09:00',
      horarioFinal: '12:00',
      image: 'Reuniao',
      favorito: true,
      descricao: 'DescriçãoDescriçãoDescriçasdsada',
    ),
    _SavedChat(
      nome: 'Treinamento de Liderança',
      data: '02/07/2025',
      horarioInicial: '09:00',
      horarioFinal: '12:00',
      image: 'Trabalho',
      descricao: 'DescriçãoDescriçãoDescriçasdsada',
    ),
    _SavedChat(
      nome: 'Conversa_01_07_25_13h',
      data: '02/07/2025',
      horarioInicial: '09:00',
      horarioFinal: '12:00',
      image: 'Outros',
    ),
  ];

  // Atualizado: aplica filtro por ícone/favorito e por query de texto combinados
  List<_SavedChat> get _filteredChats {
    Iterable<_SavedChat> list = _allChats;

    // Aplicar filtro de categoria/favorito primeiro (se houver)
    if (_selectedFilter != null && _selectedFilter!.isNotEmpty) {
      if (_selectedFilter == 'Favoritos') {
        list = list.where((c) => c.favorito == true);
      } else {
        final key = _selectedFilter!;
        list = list.where(
          (c) => (c.image ?? '').toLowerCase() == key.toLowerCase(),
        );
      }
    }

    // Aplicar pesquisa de texto (sempre combinada)
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((c) => c.nome.toLowerCase().contains(q));
    }

    return list.toList();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue700),
        title: const Text('Conversas Salvas'),
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
              spacing: 13,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  suffixIcon:
                      _query.isNotEmpty
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

                // filtros
                Column(
                  spacing: 6,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filtrar por', style: AppTextStyles.body),
                    SizedBox(
                      height: 95,
                      child:
                      //TODO: Fazer essa listview sair para fora do padding
                      ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Row(
                            spacing: 6,
                            children: [
                              // Construir dinamicamente os filtros a partir de _filters
                              for (var f in _filters)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // alterna: desmarca se clicar de novo
                                      if (_selectedFilter == f['key']) {
                                        _selectedFilter = null;
                                      } else {
                                        _selectedFilter = f['key'] as String;
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    // estilo visual para filtro selecionado
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Opacity(
                                          opacity:
                                              _selectedFilter == null ||
                                                      _selectedFilter ==
                                                          f['key']
                                                  ? 1.0
                                                  : 0.5,
                                          child: Image.asset(
                                            f['asset'] as String,
                                            width: 64,
                                            height: 64,
                                          ),
                                        ),
                                        Opacity(
                                          opacity:
                                              _selectedFilter == null ||
                                                      _selectedFilter ==
                                                          f['key']
                                                  ? 1.0
                                                  : 0.5,
                                          child: Text(
                                            f['key'] as String,
                                            style: AppTextStyles.bold.copyWith(
                                              color: f['color'] as Color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Espaço final
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // conversas não salvas
                    Container(
                      height: 2,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.blue500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UnsavedChatsScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            Image.asset('assets/images/icons/Historico.png'),
                            Text(
                              'Conversas Não Salvas',
                              style: AppTextStyles.bold.copyWith(
                                color: AppColors.blue700,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            Text(
                              '3',
                              style: AppTextStyles.bold.copyWith(
                                color: AppColors.blue700,
                              ),
                            ),
                            Image.asset('assets/images/icons/Seta.png'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // conversas
                Text('Conversas', style: AppTextStyles.body),

                // Lista filtrada de conversas ou estado vazio
                if (_filteredChats.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Nenhuma conversa encontrada',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  )
                else
                  ..._filteredChats.map(
                    (c) => ChatSelect(
                      nome: c.nome,
                      data: c.data,
                      horarioInicial: c.horarioInicial,
                      horarioFinal: c.horarioFinal,
                      image: c.image,
                      salvas: true,
                      favorito: c.favorito,
                      descricao: c.descricao,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modelo simples local para mock de conversas salvas
class _SavedChat {
  final String nome;
  final String data;
  final String horarioInicial;
  final String horarioFinal;
  final String? descricao;
  final String? image;
  final bool favorito;
  _SavedChat({
    required this.nome,
    required this.data,
    required this.horarioInicial,
    required this.horarioFinal,
    this.descricao,
    this.image,
    this.favorito = false,
  });
}
