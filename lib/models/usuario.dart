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
      'foto_url': fotoUrl,
      'criado_em': criadoEm != null ? Timestamp.fromDate(criadoEm!) : null,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uid: map['uid'] ?? '',
      nome: map['Nome'] ?? '',
      dataNasc: (map['DataNasc'] as Timestamp).toDate(),
      email: map['Email'] ?? '',
      fotoUrl: map['foto_url'],
      criadoEm:
          map['criado_em'] != null ? (map['criado_em'] as Timestamp).toDate() : null,
    );
  }
}
