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

  List<_SavedChat> get _filteredChats {
    if (_query.isEmpty) return _allChats;
    final q = _query.toLowerCase();
    return _allChats.where((c) => c.nome.toLowerCase().contains(q)).toList();
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
                            spacing: 16,
                            children: [
                              // 1
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/images/icons/Favoritos.png',
                                  ),
                                  Text(
                                    'Favoritos',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.amber600,
                                    ),
                                  ),
                                ],
                              ),

                              // 2
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/images/icons/Estudos.png',
                                  ),
                                  Text(
                                    'Estudos',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.blue600,
                                    ),
                                  ),
                                ],
                              ),

                              // 3
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/images/icons/Trabalho.png',
                                  ),
                                  Text(
                                    'Trabalhos',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.teal600,
                                    ),
                                  ),
                                ],
                              ),

                              // 4
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/images/icons/Pessoal.png',
                                  ),
                                  Text(
                                    'Pessoal',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.rose600,
                                    ),
                                  ),
                                ],
                              ),

                              // 5
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/images/icons/Reuniao.png',
                                  ),
                                  Text(
                                    'Reunião',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.green600,
                                    ),
                                  ),
                                ],
                              ),

                              // 6
                              Column(
                                children: [
                                  Image.asset('assets/images/icons/Teams.png'),
                                  Text(
                                    'Teams',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.indigo600,
                                    ),
                                  ),
                                ],
                              ),

                              // 7
                              Column(
                                children: [
                                  Image.asset('assets/images/icons/Outros.png'),
                                  Text(
                                    'Outros',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.gray700,
                                    ),
                                  ),
                                ],
                              ),

                              // 8
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/images/icons/Customizado.png',
                                  ),
                                  Text(
                                    'Customizado',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.gray700,
                                    ),
                                  ),
                                ],
                              ),
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
