import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserCredential> Login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

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
      final storageRef = _storage.ref().child(
        'user_photos/${userCredential.user!.uid}.jpg',
      );
      await storageRef.putFile(photo);
      photoUrl = await storageRef.getDownloadURL();
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
}
