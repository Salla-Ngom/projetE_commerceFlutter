import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKeyClient = GlobalKey<FormState>();
  final _formKeyVendeur = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _nomBoutiqueController = TextEditingController();

  bool _isClient = true;

  void _register() async {
  final isValid = _isClient
      ? _formKeyClient.currentState!.validate()
      : _formKeyVendeur.currentState!.validate();

  if (isValid) {
    final String nom = _nomController.text.trim();
    final String prenom = _prenomController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String telephone = _telephoneController.text.trim();
    final String adresse = _adresseController.text.trim();
    final bool actif = true;
    final String? nomBoutique =
        _isClient ? null : _nomBoutiqueController.text.trim();

    try {
      // Créer un compte utilisateur Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String userId = userCredential.user!.uid; // Récupérer l'uid

      // Ajouter le document utilisateur dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'id': userId,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
        'actif': actif,
        'role': _isClient ? 'client' : 'vendeur',
        if (nomBoutique != null) 'nomBoutique': nomBoutique,
      });

      // Créer un panier vide pour l'utilisateur dans la collection 'paniers'
      await FirebaseFirestore.instance.collection('paniers').doc(userId).set({
        'userId': userId,  // ID de l'utilisateur associé
        'produits': [],     // Liste vide de produits (panier vide au début)
        'total': 0.0,       // Total initial du panier
        'dateCreation': FieldValue.serverTimestamp(), // Date de création du panier
      });

      // Succès
      if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription et panier créés avec succès !')),
      );
      }

      // Réinitialiser les champs
      _nomController.clear();
      _prenomController.clear();
      _emailController.clear();
      _passwordController.clear();
      _telephoneController.clear();
      _adresseController.clear();
      _nomBoutiqueController.clear();
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs Firebase Auth
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Cet email est déjà utilisé.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Le mot de passe est trop faible.';
      } else {
        errorMessage = 'Une erreur est survenue.';
      }
      if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      }
    } catch (e) {
      // Erreurs générales
      if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _isClient = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isClient ? Colors.blue[800] : Colors.grey[300],
                ),
                child: const Text('Compte Client'),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 20),
          Form(
            key: _isClient ? _formKeyClient : _formKeyVendeur,
            child: Column(
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _prenomController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre téléphone';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Veuillez entrer un numéro valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _adresseController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse';
                    }
                    return null;
                  },
                ),
                if (!_isClient) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nomBoutiqueController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la Boutique',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom de votre boutique';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.all(16.0),
                    ),
                    child: const Text(
                      'S\'inscrire',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
