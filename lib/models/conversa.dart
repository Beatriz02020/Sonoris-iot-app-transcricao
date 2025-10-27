import 'package:cloud_firestore/cloud_firestore.dart';

class ConversaNaoSalva {
  final String id;
  final String conversationId;
  final DateTime createdAt;
  final List<LinhaConversa> lines;
  final DateTime? expiresAt;

  ConversaNaoSalva({
    required this.id,
    required this.conversationId,
    required this.createdAt,
    required this.lines,
    this.expiresAt,
  });

  String get nome => conversationId;

  String get data {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year.toString();
    return '$day/$month/$year';
  }

  String get horarioInicial {
    if (lines.isEmpty) return '--:--';
    final firstLine = lines.first;
    final hour = firstLine.timestamp.hour.toString().padLeft(2, '0');
    final minute = firstLine.timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get horarioFinal {
    if (lines.isEmpty) return '--:--';
    final lastLine = lines.last;
    final hour = lastLine.timestamp.hour.toString().padLeft(2, '0');
    final minute = lastLine.timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Map<String, dynamic> toMap() {
    return {
      'conversation_id': conversationId,
      'created_at': Timestamp.fromDate(createdAt),
      'expires_at': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'lines': lines.map((line) => line.toMap()).toList(),
    };
  }

  factory ConversaNaoSalva.fromMap(String docId, Map<String, dynamic> map) {
    return ConversaNaoSalva(
      id: docId,
      conversationId: map['conversation_id'] ?? '',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      expiresAt:
          map['expires_at'] != null
              ? (map['expires_at'] as Timestamp).toDate()
              : null,
      lines:
          (map['lines'] as List<dynamic>?)
              ?.map((lineMap) => LinhaConversa.fromMap(lineMap))
              .toList() ??
          [],
    );
  }

  factory ConversaNaoSalva.fromBleJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['created_at']);
    final expiresAt = createdAt.add(const Duration(days: 7));

    return ConversaNaoSalva(
      id: '',
      conversationId: json['conversation_id'] ?? '',
      createdAt: createdAt,
      expiresAt: expiresAt,
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map((lineMap) => LinhaConversa.fromJson(lineMap))
              .toList() ??
          [],
    );
  }
}

class LinhaConversa {
  final String text;
  final DateTime timestamp;

  LinhaConversa({required this.text, required this.timestamp});

  String get horario {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  Map<String, dynamic> toMap() {
    return {'text': text, 'timestamp': Timestamp.fromDate(timestamp)};
  }

  factory LinhaConversa.fromMap(Map<String, dynamic> map) {
    return LinhaConversa(
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  factory LinhaConversa.fromJson(Map<String, dynamic> json) {
    return LinhaConversa(
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// Modelo para conversas salvas
class ConversaSalva {
  final String id;
  final String nome;
  final String descricao;
  final String
  categoria; // Favoritos, Estudos, Trabalho, Pessoal, Reunião, Teams, Outros
  final bool favorito;
  final DateTime createdAt;
  final DateTime dataConversa;
  final List<LinhaConversa> lines;

  ConversaSalva({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.favorito,
    required this.createdAt,
    required this.dataConversa,
    required this.lines,
  });

  String get data {
    final day = dataConversa.day.toString().padLeft(2, '0');
    final month = dataConversa.month.toString().padLeft(2, '0');
    final year = dataConversa.year.toString();
    return '$day/$month/$year';
  }

  String get horarioInicial {
    if (lines.isEmpty) return '--:--';
    final firstLine = lines.first;
    final hour = firstLine.timestamp.hour.toString().padLeft(2, '0');
    final minute = firstLine.timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get horarioFinal {
    if (lines.isEmpty) return '--:--';
    final lastLine = lines.last;
    final hour = lastLine.timestamp.hour.toString().padLeft(2, '0');
    final minute = lastLine.timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Getter para normalizar categoria para nome do arquivo (sem acentuação)
  String get categoriaNormalizada {
    if (categoria == 'Reunião') {
      return 'Reuniao';
    }
    return categoria;
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'favorito': favorito,
      'created_at': Timestamp.fromDate(createdAt),
      'data_conversa': Timestamp.fromDate(dataConversa),
      'lines': lines.map((line) => line.toMap()).toList(),
    };
  }

  factory ConversaSalva.fromMap(String docId, Map<String, dynamic> map) {
    return ConversaSalva(
      id: docId,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      categoria: map['categoria'] ?? 'Outros',
      favorito: map['favorito'] ?? false,
      createdAt: (map['created_at'] as Timestamp).toDate(),
      dataConversa: (map['data_conversa'] as Timestamp).toDate(),
      lines:
          (map['lines'] as List<dynamic>?)
              ?.map((lineMap) => LinhaConversa.fromMap(lineMap))
              .toList() ??
          [],
    );
  }

  // Criar ConversaSalva a partir de ConversaNaoSalva
  factory ConversaSalva.fromConversaNaoSalva({
    required ConversaNaoSalva conversa,
    required String nome,
    required String descricao,
    required String categoria,
    required bool favorito,
  }) {
    return ConversaSalva(
      id: '',
      nome: nome,
      descricao: descricao,
      categoria: categoria,
      favorito: favorito,
      createdAt: DateTime.now(),
      dataConversa: conversa.createdAt,
      lines: conversa.lines,
    );
  }
}
