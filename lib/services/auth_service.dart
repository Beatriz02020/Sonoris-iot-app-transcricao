import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Configure seus dados do Cloudinary aqui (ou injete via construtor)
  // IMPORTANTE: Use um upload preset UNSIGNED configurado no painel do Cloudinary
  static const String _cloudinaryCloudName = 'dqliwz988';
  static const String _cloudinaryUploadPreset = 'sonoris_unsigned';
  // ATENÇÃO: API_KEY e API_SECRET são confidenciais! 
  // Em produção, use Cloud Functions para operações que requerem API Secret
  static const String _cloudinaryApiKey = '963947484274447'; // Substitua pelo seu API Key
  static const String _cloudinaryApiSecret = '9tVK38V5ryWQ3ZHOB7b-53U_nvA'; // Substitua pelo seu API Secret

  // Métod padrão (camelCase) para autenticação
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Alias legado para evitar quebra caso em algum ponto do código tenha sido usado Login
  Future<UserCredential> Login({
    required String email,
    required String password,
  }) => signIn(email: email, password: password);

  Future<UserCredential> signUp({
    required String name,
    required String birthDate,
    required String email,
    required String password,
    File? photo,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String? photoUrl;
    if (photo != null) {
      final cloudinary = CloudinaryPublic(
        _cloudinaryCloudName,
        _cloudinaryUploadPreset,
        cache: false,
      );

      // PublicId com uid para evitar duplicidade; folder ajuda a organizar
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          photo.path,
          folder: 'user_photos',
          publicId: userCredential.user!.uid,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      photoUrl = response.secureUrl;
    }

    await _firestore.collection('Usuario').doc(userCredential.user!.uid).set({
      'Nome': name,
      'DataNasc': birthDate,
      'Email': email,
      'Foto_url': photoUrl,
      'Criado_em': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  // Atualiza a foto de perfil do usuário no Cloudinary e salva a URL no Firestore
  // Retorna a URL segura (https) da imagem
  Future<String> updateProfilePhoto(File photo) async {
    debugPrint('[AuthService] 🔵 updateProfilePhoto INICIADO');
    debugPrint('[AuthService] 🔵 Arquivo: ${photo.path}');
    debugPrint('[AuthService] 🔵 Arquivo existe: ${await photo.exists()}');
    
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[AuthService] ❌ Usuário não autenticado');
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Usuário não autenticado.',
      );
    }
    
    debugPrint('[AuthService] 🔵 UID do usuário: ${user.uid}');

    // Busca a URL antiga para deletar a imagem do Cloudinary
    try {
      final docSnapshot = await _firestore.collection('Usuario').doc(user.uid).get();
      final oldPhotoUrl = docSnapshot.data()?['Foto_url'] as String?;
      
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        debugPrint('[AuthService] 🗑️ Deletando foto antiga: $oldPhotoUrl');
        final oldPublicId = _extractPublicIdFromUrl(oldPhotoUrl, 'user_photos');
        if (oldPublicId != null) {
          await _deleteFromCloudinary(oldPublicId);
        }
      }
    } catch (e) {
      debugPrint('[AuthService] ⚠️ Erro ao deletar foto antiga: $e (continuando...)');
    }

    debugPrint('[AuthService] 🔵 Iniciando upload para Cloudinary...');

    final cloudinary = CloudinaryPublic(
      _cloudinaryCloudName,
      _cloudinaryUploadPreset,
      cache: false,
    );

    debugPrint('[AuthService] 🔵 CloudinaryPublic criado - cloudName: $_cloudinaryCloudName, preset: $_cloudinaryUploadPreset');

    // Adiciona timestamp ao publicId para garantir URL única
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final publicIdWithTimestamp = '${user.uid}_$timestamp';
    
    debugPrint('[AuthService] 🔵 PublicId: $publicIdWithTimestamp');

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        photo.path,
        folder: 'user_photos',
        publicId: publicIdWithTimestamp,
        resourceType: CloudinaryResourceType.Image,
      ),
    );

    debugPrint('[AuthService] ✅ Upload para Cloudinary concluído!');
    debugPrint('[AuthService] 📦 Response secureUrl: ${response.secureUrl}');

    final photoUrl = response.secureUrl;

    debugPrint('[AuthService] 🔵 Atualizando Firestore...');
    await _firestore.collection('Usuario').doc(user.uid).update({
      'Foto_url': photoUrl,
    });

    // Log para depuração: confirma que o Firestore foi atualizado
    // (o listener nas screens deve receber essa mudança)
    debugPrint('[AuthService] ✅ updateProfilePhoto: saved Foto_url=$photoUrl for uid=${user.uid}');

    return photoUrl;
  }

  // Atualiza a imagem de banner do perfil no Cloudinary e salva a URL em 'banner_url' no Firestore
  Future<String> updateBannerPhoto(File photo) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Usuário não autenticado.',
      );
    }

    // Busca a URL antiga para deletar a imagem do Cloudinary
    try {
      final docSnapshot = await _firestore.collection('Usuario').doc(user.uid).get();
      final oldBannerUrl = docSnapshot.data()?['banner_url'] as String?;
      
      if (oldBannerUrl != null && oldBannerUrl.isNotEmpty) {
        debugPrint('[AuthService] 🗑️ Deletando banner antigo: $oldBannerUrl');
        final oldPublicId = _extractPublicIdFromUrl(oldBannerUrl, 'user_banners');
        if (oldPublicId != null) {
          await _deleteFromCloudinary(oldPublicId);
        }
      }
    } catch (e) {
      debugPrint('[AuthService] ⚠️ Erro ao deletar banner antigo: $e (continuando...)');
    }

    final cloudinary = CloudinaryPublic(
      _cloudinaryCloudName,
      _cloudinaryUploadPreset,
      cache: false,
    );

    // Adiciona timestamp ao publicId para garantir URL única
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final publicIdWithTimestamp = '${user.uid}_banner_$timestamp';

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        photo.path,
        folder: 'user_banners',
        publicId: publicIdWithTimestamp,
        resourceType: CloudinaryResourceType.Image,
      ),
    );

    final bannerUrl = response.secureUrl;

    await _firestore.collection('Usuario').doc(user.uid).update({
      'banner_url': bannerUrl,
    });

    debugPrint('[AuthService] updateBannerPhoto: saved banner_url=$bannerUrl for uid=${user.uid}');

    return bannerUrl;
  }

  // Extrai o publicId de uma URL do Cloudinary
  // Exemplo: https://res.cloudinary.com/cloud/image/upload/v123/user_photos/uid_123.jpg
  // Retorna: user_photos/uid_123
  String? _extractPublicIdFromUrl(String url, String folder) {
    try {
      // Remove query params (?v=...)
      final cleanUrl = url.split('?').first;
      
      // Procura pela pasta no caminho
      final folderIndex = cleanUrl.indexOf('/$folder/');
      if (folderIndex == -1) return null;
      
      // Extrai tudo depois da pasta até a extensão
      final afterFolder = cleanUrl.substring(folderIndex + 1);
      final withoutExtension = afterFolder.split('.').first;
      
      debugPrint('[AuthService] 🔍 Extracted publicId: $withoutExtension');
      return withoutExtension;
    } catch (e) {
      debugPrint('[AuthService] ❌ Erro ao extrair publicId: $e');
      return null;
    }
  }

  // Deleta uma imagem do Cloudinary usando o publicId
  Future<void> _deleteFromCloudinary(String publicId) async {
    try {
      // Verifica se as credenciais foram configuradas
      if (_cloudinaryApiKey == 'YOUR_API_KEY' || _cloudinaryApiSecret == 'YOUR_API_SECRET') {
        debugPrint('[AuthService] ⚠️ API Key/Secret não configurados - skip delete');
        debugPrint('[AuthService] ℹ️ Para deletar imagens antigas, configure as credenciais do Cloudinary');
        return;
      }

      final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      
      // Gera a assinatura SHA-256
      final stringToSign = 'public_id=$publicId&timestamp=$timestamp$_cloudinaryApiSecret';
      final signature = sha256.convert(utf8.encode(stringToSign)).toString();
      
      debugPrint('[AuthService] 🗑️ Deletando do Cloudinary: $publicId');
      
      // Faz requisição para API de destruição
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/destroy');
      final response = await http.post(
        url,
        body: {
          'public_id': publicId,
          'signature': signature,
          'api_key': _cloudinaryApiKey,
          'timestamp': timestamp.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        debugPrint('[AuthService] ✅ Imagem deletada: ${result['result']}');
      } else {
        debugPrint('[AuthService] ❌ Erro ao deletar: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('[AuthService] ❌ Exceção ao deletar do Cloudinary: $e');
    }
  }
}
