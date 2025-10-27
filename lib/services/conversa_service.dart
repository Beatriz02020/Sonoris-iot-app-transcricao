import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/conversa.dart';

class ConversaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obter referência da subcoleção ConversasNaoSalvas do usuário atual
  CollectionReference? _getConversasNaoSalvasRef() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return _firestore
        .collection('Usuario')
        .doc(user.uid)
        .collection('ConversasNaoSalvas');
  }

  // Adicionar uma nova conversa não salva
  Future<String?> addConversaNaoSalva(ConversaNaoSalva conversa) async {
    try {
      final ref = _getConversasNaoSalvasRef();
      if (ref == null) {
        throw Exception('Usuário não autenticado');
      }

      final docRef = await ref.add(conversa.toMap());
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar conversa não salva: $e');
      return null;
    }
  }

  // Adicionar conversa a partir de JSON do BLE
  Future<String?> addConversaFromBleJson(Map<String, dynamic> json) async {
    try {
      final conversa = ConversaNaoSalva.fromBleJson(json);
      return await addConversaNaoSalva(conversa);
    } catch (e) {
      print('Erro ao processar JSON do BLE: $e');
      return null;
    }
  }

  // Stream de conversas não salvas do usuário atual
  Stream<List<ConversaNaoSalva>> getConversasNaoSalvasStream() {
    final ref = _getConversasNaoSalvasRef();
    if (ref == null) {
      return Stream.value([]);
    }

    return ref.orderBy('created_at', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return ConversaNaoSalva.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // Buscar uma conversa específica por ID
  Future<ConversaNaoSalva?> getConversaById(String conversaId) async {
    try {
      final ref = _getConversasNaoSalvasRef();
      if (ref == null) return null;

      final doc = await ref.doc(conversaId).get();
      if (!doc.exists) return null;

      return ConversaNaoSalva.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      print('Erro ao buscar conversa: $e');
      return null;
    }
  }

  // Deletar uma conversa não salva
  Future<bool> deleteConversa(String conversaId) async {
    try {
      final ref = _getConversasNaoSalvasRef();
      if (ref == null) return false;

      await ref.doc(conversaId).delete();
      return true;
    } catch (e) {
      print('Erro ao deletar conversa: $e');
      return false;
    }
  }

  // Deletar conversas expiradas (pode ser chamado no initState)
  Future<void> deleteExpiredConversas() async {
    try {
      final ref = _getConversasNaoSalvasRef();
      if (ref == null) return;

      final now = Timestamp.now();
      final snapshot = await ref.where('expires_at', isLessThan: now).get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Conversas expiradas deletadas: ${snapshot.docs.length}');
    } catch (e) {
      print('Erro ao deletar conversas expiradas: $e');
    }
  }

  // FUNÇÃO DE TESTE: Adicionar conversa de exemplo
  Future<String?> addTestConversa() async {
    try {
      final now = DateTime.now();
      final testConversa = ConversaNaoSalva(
        id: '',
        conversationId:
            'Conversa_Teste_${now.day}_${now.month}_${now.year}_${now.hour}h',
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
        lines: [
          LinhaConversa(
            text: 'Esta é uma conversa de teste criada automaticamente.',
            timestamp: now,
          ),
          LinhaConversa(
            text: 'Segunda linha da conversa de teste.',
            timestamp: now.add(const Duration(seconds: 15)),
          ),
          LinhaConversa(
            text: 'Terceira linha para verificar o funcionamento.',
            timestamp: now.add(const Duration(seconds: 30)),
          ),
          LinhaConversa(
            text: 'Última linha da conversa de teste.',
            timestamp: now.add(const Duration(seconds: 45)),
          ),
        ],
      );

      final id = await addConversaNaoSalva(testConversa);
      if (id != null) {
        print('Conversa de teste criada com ID: $id');
      }
      return id;
    } catch (e) {
      print('Erro ao criar conversa de teste: $e');
      return null;
    }
  }
}
