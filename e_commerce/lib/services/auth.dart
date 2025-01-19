import 'package:e_commerce/view/connexion/login.dart';
import 'package:e_commerce/view/page_administrateur.dart';
import 'package:e_commerce/view/page_client.dart';
import 'package:e_commerce/view/page_super_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer'; 

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

 Future<void> signInWithEmailAndPassword({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final role = data['role'];
        final actif = data['actif'];
         final nom = data['nom'];
          final prenom = data['prenom'];
          final email = data['email'];
          final id = data['id'];
          final tel = data['telephone'];
          final adresse = data['adresse'];


        if (!context.mounted) return; 

        if (actif == true) {
          if (role == 'client') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  ClientPage(id:id,nom: nom,prenom: prenom,email:email,telephone:tel,adresse: adresse)),
            );
          } else if (role == 'Admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PageAdmin(id:id,nom: nom,prenom: prenom,email:email,telephone:tel,adresse: adresse)),
            );
          } else if(role == 'SuperAdmin'){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PageSuperAdmin(id:id,nom: nom,prenom: prenom,email:email,telephone:tel,adresse: adresse)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rôle utilisateur non pris en charge.')),
            );
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  LoginPage()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Votre compte est désactivé.')),
          );
           Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  LoginPage()),
            );
        }
      } else {
        if (!context.mounted) return; 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre compte n\'existe pas!')),
        );
         Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  LoginPage()),
            );
      }
    }
  } catch (e) {
    if (!context.mounted) return; 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('informations Incorrectes!.')),
    );
     Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  LoginPage()),
            );
  }
}


  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      log('Erreur lors de la déconnexion : $e', error: e);
    }
  }
}
