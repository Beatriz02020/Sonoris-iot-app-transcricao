import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/chatSelect.dart';
import 'package:sonoris/models/conversa.dart';
import 'package:sonoris/services/conversa_service.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/customTextField.dart';

class SavedChatsScreen extends StatefulWidget {
  const SavedChatsScreen({super.key});

  @override
  State<SavedChatsScreen> createState() => _SavedChatsScreenState();
}

class _SavedChatsScreenState extends State<SavedChatsScreen> {
  // Controlador e estado da pesquisa
  final TextEditingController _searchController = TextEditingController();
  final ConversaService _conversaService = ConversaService();
  String _query = '';
  List<ConversaSalva> _allConversas = [];

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
      'key': 'Reunião',
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
  ];

  // Atualizado: aplica filtro por categoria/favorito e por query de texto combinados
  List<ConversaSalva> get _filteredConversas {
    if (_query.isEmpty && _selectedFilter == null) return _allConversas;

    Iterable<ConversaSalva> list = _allConversas;

    // Aplicar filtro de categoria/favorito primeiro (se houver)
    if (_selectedFilter != null && _selectedFilter!.isNotEmpty) {
      if (_selectedFilter == 'Favoritos') {
        list = list.where((c) => c.favorito == true);
      } else {
        final key = _selectedFilter!;
        list = list.where(
          (c) => c.categoria.toLowerCase() == key.toLowerCase(),
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

      body: StreamBuilder<List<ConversaSalva>>(
        stream: _conversaService.getConversasSalvasStream(),
        builder: (context, snapshot) {
          // Atualiza _allConversas quando recebe novos dados
          if (snapshot.hasData) {
            _allConversas = snapshot.data!;
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              _allConversas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar conversas: ${snapshot.error}',
                style: AppTextStyles.body.copyWith(color: AppColors.rose500),
              ),
            );
          }

          return ListView(
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
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.gray500,
                                ),
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
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Filtrar por', style: AppTextStyles.body),
                        SizedBox(
                          height: 85,
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
                                            _selectedFilter =
                                                f['key'] as String;
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        // estilo visual para filtro selecionado
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                                width: 54,
                                                height: 54,
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
                                                style: AppTextStyles.bold
                                                    .copyWith(
                                                      color:
                                                          f['color'] as Color,
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

                    /*
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
                ),*/

                    // conversas
                    Text('Conversas', style: AppTextStyles.body),

                    // Lista filtrada de conversas ou estado vazio
                    if (_filteredConversas.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _allConversas.isEmpty
                              ? 'Nenhuma conversa salva'
                              : 'Nenhuma conversa encontrada',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      )
                    else
                      ..._filteredConversas.map(
                        (c) => ChatSelect(
                          nome: c.nome,
                          data: c.data,
                          horarioInicial: c.horarioInicial,
                          horarioFinal: c.horarioFinal,
                          image: c.categoriaNormalizada,
                          salvas: true,
                          favorito: c.favorito,
                          descricao: c.descricao,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed('/savedchats/chat', arguments: c);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
