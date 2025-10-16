import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Configure seus dados do Cloudinary aqui (ou injete via construtor)
  // IMPORTANTE: Use um upload preset UNSIGNED configurado no painel do Cloudinary
  static const String _cloudinaryCloudName = 'dqliwz988';
  static const String _cloudinaryUploadPreset = 'sonoris_unsigned';

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

    final cloudinary = CloudinaryPublic(
      _cloudinaryCloudName,
      _cloudinaryUploadPreset,
      cache: false,
    );

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        photo.path,
        folder: 'user_photos',
        publicId: user.uid,
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

    final cloudinary = CloudinaryPublic(
      _cloudinaryCloudName,
      _cloudinaryUploadPreset,
      cache: false,
    );

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        photo.path,
        folder: 'user_banners',
        publicId: '${user.uid}_banner',
        resourceType: CloudinaryResourceType.Image,
      ),
    );

    final bannerUrl = response.secureUrl;

    await _firestore.collection('Usuario').doc(user.uid).update({
      'banner_url': bannerUrl,
    });

    return bannerUrl;
  }
}
