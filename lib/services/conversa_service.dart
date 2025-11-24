import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  // Obter referência da subcoleção ConversasSalvas do usuário atual
  CollectionReference? _getConversasSalvasRef() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return _firestore
        .collection('Usuario')
        .doc(user.uid)
        .collection('ConversasSalvas');
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
      debugPrint('Erro ao adicionar conversa não salva: $e');
      return null;
    }
  }

  // Adicionar conversa a partir de JSON do BLE
  Future<String?> addConversaFromBleJson(Map<String, dynamic> json) async {
    try {
      final conversa = ConversaNaoSalva.fromBleJson(json);
      return await addConversaNaoSalva(conversa);
    } catch (e) {
      debugPrint('Erro ao processar JSON do BLE: $e');
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
      debugPrint('Erro ao buscar conversa: $e');
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
      debugPrint('Erro ao deletar conversa: $e');
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
    } catch (e) {
      debugPrint('Erro ao deletar conversas expiradas: $e');
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
      return id;
    } catch (e) {
      debugPrint('Erro ao criar conversa de teste: $e');
      return null;
    }
  }

  // ===== MÉTODOS PARA CONVERSAS SALVAS =====

  // Salvar conversa (move de ConversasNaoSalvas para ConversasSalvas)
  Future<String?> salvarConversa({
    required ConversaNaoSalva conversaNaoSalva,
    required String nome,
    required String descricao,
    required String categoria,
    required bool favorito,
  }) async {
    try {
      final refSalvas = _getConversasSalvasRef();
      if (refSalvas == null) {
        throw Exception('Usuário não autenticado');
      }

      // Criar conversa salva a partir da não salva
      final conversaSalva = ConversaSalva.fromConversaNaoSalva(
        conversa: conversaNaoSalva,
        nome: nome,
        descricao: descricao,
        categoria: categoria,
        favorito: favorito,
      );

      // Adicionar na coleção ConversasSalvas
      final docRef = await refSalvas.add(conversaSalva.toMap());

      // Deletar da coleção ConversasNaoSalvas
      await deleteConversa(conversaNaoSalva.id);

      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao salvar conversa: $e');
      return null;
    }
  }

  // Stream de conversas salvas do usuário atual
  Stream<List<ConversaSalva>> getConversasSalvasStream() {
    final ref = _getConversasSalvasRef();
    if (ref == null) {
      return Stream.value([]);
    }

    return ref.orderBy('created_at', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return ConversaSalva.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // Buscar uma conversa salva específica por ID
  Future<ConversaSalva?> getConversaSalvaById(String conversaId) async {
    try {
      final ref = _getConversasSalvasRef();
      if (ref == null) return null;

      final doc = await ref.doc(conversaId).get();
      if (!doc.exists) return null;

      return ConversaSalva.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Erro ao buscar conversa salva: $e');
      return null;
    }
  }

  // Deletar uma conversa salva
  Future<bool> deleteConversaSalva(String conversaId) async {
    try {
      final ref = _getConversasSalvasRef();
      if (ref == null) return false;

      await ref.doc(conversaId).delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar conversa salva: $e');
      return false;
    }
  }

  // Atualizar uma conversa salva
  Future<bool> updateConversaSalva({
    required String conversaId,
    String? nome,
    String? descricao,
    String? categoria,
    bool? favorito,
  }) async {
    try {
      final ref = _getConversasSalvasRef();
      if (ref == null) return false;

      final Map<String, dynamic> updates = {};
      if (nome != null) updates['nome'] = nome;
      if (descricao != null) updates['descricao'] = descricao;
      if (categoria != null) updates['categoria'] = categoria;
      if (favorito != null) updates['favorito'] = favorito;

      if (updates.isEmpty) return false;

      await ref.doc(conversaId).update(updates);
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar conversa salva: $e');
      return false;
    }
  }
}
