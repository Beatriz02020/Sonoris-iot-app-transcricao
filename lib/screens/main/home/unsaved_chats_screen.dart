import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/chatSelect.dart';
import 'package:sonoris/components/customSnackBar.dart';
import 'package:sonoris/models/conversa.dart';
import 'package:sonoris/services/bluetooth_manager.dart';
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
  final BluetoothManager _manager = BluetoothManager();
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
    _manager.onConversationsReceived = null;
    _manager.onConnectionEstablished = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Deletar conversas expiradas ao iniciar a tela
    _conversaService.deleteExpiredConversas();

    // Configura callback para processar conversas recebidas via BLE
    _manager.onConversationsReceived = _handleConversationsFromBle;

    // Configura callback para requisitar conversas quando conectar
    _manager.onConnectionEstablished = () {
      debugPrint(
        '[UNSAVED_CHATS] 🔗 Dispositivo conectado - requisitando conversas...',
      );
      _manager.requestConversations();
    };

    // Se já está conectado, requisita conversas imediatamente
    if (_manager.connectedDevice != null) {
      debugPrint('[UNSAVED_CHATS] 📱 Já conectado - requisitando conversas...');
      _manager.requestConversations();
    }

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

  /// Processa conversas recebidas do dispositivo via BLE
  Future<void> _handleConversationsFromBle(
    List<Map<String, dynamic>> conversations,
  ) async {
    try {
      debugPrint(
        '[UNSAVED_CHATS] 📥 Processando ${conversations.length} conversa(s) do dispositivo...',
      );

      for (final convMeta in conversations) {
        try {
          final conversationId = convMeta['conversation_id'] as String?;
          if (conversationId == null) {
            debugPrint('[UNSAVED_CHATS] ⚠️ Conversa sem ID - pulando');
            continue;
          }

          debugPrint(
            '[UNSAVED_CHATS] 📄 Processando conversa: $conversationId',
          );

          // Primeiro, requisita metadados da conversa
          final metadata = await _manager.requestConversationById(
            conversationId,
          );

          if (metadata == null || metadata.isEmpty) {
            debugPrint(
              '[UNSAVED_CHATS] ⚠️ Não foi possível obter metadados de $conversationId',
            );
            continue;
          }

          // Verifica se precisa baixar em chunks
          final requiresChunking =
              metadata['requires_chunking'] as bool? ?? false;
          final totalChunks = metadata['total_chunks'] as int? ?? 1;

          Map<String, dynamic> conversaCompleta;

          if (requiresChunking && totalChunks > 1) {
            debugPrint(
              '[UNSAVED_CHATS] 📦 Conversa requer $totalChunks chunks - baixando...',
            );

            // Baixa todos os chunks e monta a conversa completa
            final allLines = <Map<String, dynamic>>[];

            for (int i = 0; i < totalChunks; i++) {
              final chunk = await _manager.requestConversationChunk(
                conversationId,
                i,
              );

              if (chunk == null) {
                debugPrint('[UNSAVED_CHATS] ⚠️ Erro ao baixar chunk $i');
                break;
              }

              final lines = chunk['lines'] as List?;
              if (lines != null) {
                allLines.addAll(lines.cast<Map<String, dynamic>>());
              }

              debugPrint(
                '[UNSAVED_CHATS] ✓ Chunk $i/${totalChunks - 1} baixado',
              );

              // Delay maior entre chunks para evitar sobrecarga BLE
              if (i < totalChunks - 1) {
                await Future.delayed(const Duration(milliseconds: 500));
              }
            }
            if (allLines.length < (metadata['total_lines'] as int? ?? 0)) {
              debugPrint(
                '[UNSAVED_CHATS] ⚠️ Download incompleto: ${allLines.length}/${metadata['total_lines']} linhas',
              );
              continue;
            }

            // Monta conversa completa com todos os chunks
            conversaCompleta = {
              'conversation_id': metadata['conversation_id'],
              'created_at': metadata['created_at'],
              'finalized': metadata['finalized'],
              'lines': allLines,
            };

            debugPrint(
              '[UNSAVED_CHATS] ✅ Conversa completa montada: ${allLines.length} linhas',
            );
          } else {
            // Conversa pequena, não precisa de chunks
            debugPrint(
              '[UNSAVED_CHATS] 📄 Conversa pequena, baixando chunk único',
            );

            final chunk = await _manager.requestConversationChunk(
              conversationId,
              0,
            );

            if (chunk == null) {
              debugPrint('[UNSAVED_CHATS] ⚠️ Erro ao baixar conversa');
              continue;
            }

            conversaCompleta = {
              'conversation_id': metadata['conversation_id'],
              'created_at': metadata['created_at'],
              'finalized': metadata['finalized'],
              'lines': chunk['lines'] ?? [],
            };
          }

          debugPrint('[UNSAVED_CHATS] 💾 Salvando conversa no Firebase...');

          // Adiciona conversa ao Firebase
          final conversaId = await _conversaService.addConversaFromBleJson(
            conversaCompleta,
          );

          if (conversaId != null) {
            debugPrint(
              '[UNSAVED_CHATS] ✅ Conversa salva com sucesso: $conversaId',
            );

            // Deleta conversa do dispositivo após salvar
            final deleted = await _manager.deleteConversationFromDevice(
              conversationId,
            );
            if (deleted) {
              debugPrint(
                '[UNSAVED_CHATS] 🗑️ Conversa deletada do dispositivo',
              );
            }
          } else {
            debugPrint('[UNSAVED_CHATS] ❌ Erro ao salvar conversa no Firebase');
          }

          // Delay entre conversas para evitar sobrecarga BLE
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          debugPrint('[UNSAVED_CHATS] ❌ Erro ao processar conversa: $e');
        }
      }
      debugPrint('[UNSAVED_CHATS] ✅ Processamento de conversas concluído');
    } catch (e) {
      debugPrint('[UNSAVED_CHATS] ❌ Erro ao processar conversas do BLE: $e');
    }
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
                CustomSnackBar.success('Conversa de teste adicionada')
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
