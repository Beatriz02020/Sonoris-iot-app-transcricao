import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String nome;
  final DateTime dataNasc;
  final String email;
  final String? fotoUrl;
  final DateTime? criadoEm;

  Usuario({
    required this.uid,
    required this.nome,
    required this.dataNasc,
    required this.email,
    this.fotoUrl,
    this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'Nome': nome,
      'DataNasc': Timestamp.fromDate(dataNasc),
      'Email': email,
      // Inconsistência atual: no signUp é salvo 'Foto_url' e 'Criado_em' (CamelCase inicial),
      // aqui está sendo usado 'foto_url' e 'criado_em'. Ideal alinhar tudo (ex: padronizar TitleCase ou snake_case).
      'Foto_url': fotoUrl,
      'Criado_em': criadoEm != null ? Timestamp.fromDate(criadoEm!) : null,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    DateTime parseDataNasc(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        final parts = value.split('/');
        if (parts.length == 3) {
          final d = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final y = int.tryParse(parts[2]);
          if (d != null && m != null && y != null) {
            return DateTime(y, m, d);
          }
        }
      }
      // fallback: agora
      return DateTime.now();
    }

    return Usuario(
      uid: map['uid'] ?? '',
      nome: map['Nome'] ?? '',
      dataNasc: parseDataNasc(map['DataNasc']),
      email: map['Email'] ?? '',
      fotoUrl: map['Foto_url'] ?? map['foto_url'],
      criadoEm:
          map['Criado_em'] != null
              ? (map['Criado_em'] as Timestamp).toDate()
              : map['criado_em'] != null
              ? (map['criado_em'] as Timestamp).toDate()
              : null,
    );
  }
}
