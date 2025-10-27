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
