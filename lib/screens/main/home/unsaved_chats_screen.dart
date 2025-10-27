import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/chatSelect.dart';
import 'package:sonoris/models/conversa.dart';
import 'package:sonoris/services/conversa_service.dart';
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
  final ConversaService _conversaService = ConversaService();
  String _query = '';
  List<ConversaNaoSalva> _allConversas = [];

  List<ConversaNaoSalva> get _filteredConversas {
    if (_query.isEmpty) return _allConversas;
    final q = _query.toLowerCase();
    return _allConversas
        .where((c) => c.nome.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Deletar conversas expiradas ao iniciar a tela
    _conversaService.deleteExpiredConversas();

    // TODO: Implementar recebimento de JSON via BLE do Raspberry Pi
    // Quando receber o JSON via BLE, chamar:
    // await _conversaService.addConversaFromBleJson(jsonData);

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
        iconTheme: const IconThemeData(color: AppColors.blue500),
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text('Conversas Não Salvas'),
/*
        actions: [
          // Botão de teste para adicionar conversa
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Adicionar conversa de teste',
            onPressed: () async {
              await _conversaService.addTestConversa();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversa de teste adicionada!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],*/
      ),
      body: StreamBuilder<List<ConversaNaoSalva>>(
        stream: _conversaService.getConversasNaoSalvasStream(),
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
                  top: 10,
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

                    // conversas
                    Column(
                      spacing: 12,
                      children: [
                        if (_filteredConversas.isEmpty)
                          Text(
                            _allConversas.isEmpty
                                ? 'Nenhuma conversa não salva'
                                : 'Nenhuma conversa encontrada',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.gray500,
                            ),
                          )
                        else
                          ..._filteredConversas.map(
                            (conversa) => ChatSelect(
                              nome: conversa.nome,
                              data: conversa.data,
                              horarioInicial: conversa.horarioInicial,
                              horarioFinal: conversa.horarioFinal,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/unsavedchats/chat',
                                  arguments: conversa,
                                );
                              },
                            ),
                          ),
                      ],
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
