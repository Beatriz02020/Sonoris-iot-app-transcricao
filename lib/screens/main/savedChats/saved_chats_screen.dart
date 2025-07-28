import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/chatSelect.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/screens/initial/bluetooth_screen.dart';
import 'package:sonoris/screens/initial/language_screen.dart';
import 'package:sonoris/screens/main/savedChats/saved_chat_screen.dart';
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        //iconTheme: const IconThemeData(color: AppColors.blue700,),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue700),
        title: const Text('Conversas Salvas'),
      ),

      // TODO arrumar o espaçamento
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 30, // original (55)
              bottom: 30,
            ),
            child: Column(
              spacing: 15,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // input de pesquisa
                CustomTextField(
                  hintText: 'Pesquisar',
                  isSearch: true,
                  fullWidth: true,
                ),

                // filtros
                Text('Filtrar por', style: AppTextStyles.body),
                SizedBox(
                  height: 100,
                  child:
                    ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // 1
                        Column(
                          children: [
                            Image.asset('assets/images/icons/Favoritos.png'),
                            Text('Favoritos', style: AppTextStyles.bold.copyWith(color: AppColors.amber600,),
                            )
                          ],
                        ),

                        SizedBox(width: 18),

                        // 2
                        Column(
                          children: [
                            Image.asset('assets/images/icons/Estudos.png'),
                            Text('Estudos', style: AppTextStyles.bold.copyWith(color: AppColors.blue600,),
                            )
                          ],
                        ),

                        SizedBox(width: 18),

                        // 3
                        Column(
                          children: [
                            Image.asset('assets/images/icons/Trabalho.png'),
                            Text('Trabalhos', style: AppTextStyles.bold.copyWith(color: AppColors.teal600,),
                            )
                          ],
                        ),

                        SizedBox(width: 18),

                        // 4
                        Column(
                          children: [
                            Image.asset('assets/images/icons/Pessoal.png'),
                            Text('Pessoal', style: AppTextStyles.bold.copyWith(color: AppColors.rose600,),
                            )
                          ],
                        ),

                        SizedBox(width: 18),

                        // 5
                        Column(
                          children: [
                            Image.asset('assets/images/icons/Reuniao.png'),
                            Text('Reunião', style: AppTextStyles.bold.copyWith(color: AppColors.green600,),
                            )
                          ],
                        ),

                        SizedBox(width: 18),

                        // 6
                        Column(
                          children: [
                            Image.asset('assets/images/icons/Teams.png'),
                            Text('Teams', style: AppTextStyles.bold.copyWith(color: AppColors.indigo600,),
                            )
                          ],
                        ),

                        SizedBox(width: 18),

                        // 7
                        Column(
                          children: [
                            Image.asset('assets/images/icons/Outros.png'),
                            Text('Outros', style: AppTextStyles.bold.copyWith(color: AppColors.gray700,),
                            )
                          ],
                        ),

                        SizedBox(width: 18),

                        // 8
                        Column(
                          children: [
                            Image.asset('assets/images/icons/Customizado.png'),
                            Text('Customizado', style: AppTextStyles.bold.copyWith(color: AppColors.gray700,),
                            )
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
                    padding: const EdgeInsets.only(left: 20, right: 20),
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

                ChatSelect(
                  nome: 'Reuniao SoftSkills',
                  data: '02/07/2025',
                  horarioInicial: '09:00',
                  horarioFinal: '12:00',
                  image: 'Teams',
                  salvas: true,
                  favorito: true,
                  descricao: 'DescriçãoDescriçãoDescriçasdsada',
                ),
                ChatSelect(
                  nome: 'Workshop de Criatividade',
                  data: '02/07/2025',
                  horarioInicial: '09:00',
                  horarioFinal: '12:00',
                  image: 'Reuniao',
                  salvas: true,
                  favorito: true,
                  descricao: 'DescriçãoDescriçãoDescriçasdsada',
                ),
                ChatSelect(
                  nome: 'Treinamento de Liderança',
                  data: '02/07/2025',
                  horarioInicial: '09:00',
                  horarioFinal: '12:00',
                  image: 'Trabalho',
                  salvas: true,
                  descricao: 'DescriçãoDescriçãoDescriçasdsada',
                ),
                ChatSelect(
                  nome: 'Conversa_01_07_25_13h',
                  data: '02/07/2025',
                  horarioInicial: '09:00',
                  horarioFinal: '12:00',
                  salvas: true,
                  image: 'Outros',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
