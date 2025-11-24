import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Configurações do Cloudinary carregadas do arquivo .env
  static String get _cloudinaryCloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get _cloudinaryUploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  // Em produção, use Cloud Functions para operações que requerem API Secret
  static String get _cloudinaryApiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get _cloudinaryApiSecret =>
      dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

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
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Usuário não autenticado.',
      );
    }

    // Busca a URL antiga para deletar a imagem do Cloudinary
    try {
      final docSnapshot =
          await _firestore.collection('Usuario').doc(user.uid).get();
      final oldPhotoUrl = docSnapshot.data()?['Foto_url'] as String?;

      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        final oldPublicId = _extractPublicIdFromUrl(oldPhotoUrl, 'user_photos');
        if (oldPublicId != null) {
          await _deleteFromCloudinary(oldPublicId);
        }
      }
    } catch (e) {
      debugPrint('Erro ao deletar foto antiga: $e (continuando...)');
    }

    final cloudinary = CloudinaryPublic(
      _cloudinaryCloudName,
      _cloudinaryUploadPreset,
      cache: false,
    );

    // Adiciona timestamp ao publicId para garantir URL única
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final publicIdWithTimestamp = '${user.uid}_$timestamp';

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        photo.path,
        folder: 'user_photos',
        publicId: publicIdWithTimestamp,
        resourceType: CloudinaryResourceType.Image,
      ),
    );

    final photoUrl = response.secureUrl;

    await _firestore.collection('Usuario').doc(user.uid).update({
      'Foto_url': photoUrl,
    });

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
      final docSnapshot =
          await _firestore.collection('Usuario').doc(user.uid).get();
      final oldBannerUrl = docSnapshot.data()?['banner_url'] as String?;

      if (oldBannerUrl != null && oldBannerUrl.isNotEmpty) {
        final oldPublicId = _extractPublicIdFromUrl(
          oldBannerUrl,
          'user_banners',
        );
        if (oldPublicId != null) {
          await _deleteFromCloudinary(oldPublicId);
        }
      }
    } catch (e) {
      debugPrint('Erro ao deletar banner antigo: $e (continuando...)');
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

    return bannerUrl;
  }

  // Extrai o publicId de uma URL do Cloudinary
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

      return withoutExtension;
    } catch (e) {
      debugPrint('Erro ao extrair publicId: $e');
      return null;
    }
  }

  // Deleta uma imagem do Cloudinary usando o publicId
  Future<void> _deleteFromCloudinary(String publicId) async {
    try {
      // Verifica se as credenciais foram configuradas
      if (_cloudinaryApiKey.isEmpty || _cloudinaryApiSecret.isEmpty) {
        debugPrint('API Key/Secret não configurados - skip delete');
        return;
      }

      final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

      // Gera a assinatura SHA-256
      final stringToSign =
          'public_id=$publicId&timestamp=$timestamp$_cloudinaryApiSecret';
      final signature = sha256.convert(utf8.encode(stringToSign)).toString();

      debugPrint('[AuthService] 🗑️ Deletando do Cloudinary: $publicId');

      // Faz requisição para API de destruição
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/destroy',
      );
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
        debugPrint(
          'Erro ao deletar: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Exceção ao deletar do Cloudinary: $e');
    }
  }
}
