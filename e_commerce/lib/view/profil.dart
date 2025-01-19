import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;

  const ProfilPage({
    super.key,
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.adresse,
  });

  @override
  Widget build(BuildContext context) {
    String firstLetterOfNom = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    String firstLetterOfPrenom = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                '$firstLetterOfPrenom$firstLetterOfNom',
                style: const TextStyle(color: Colors.white, fontSize: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nom : $nom',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Email : $email', 
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Téléphone : $telephone',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Adresse : $adresse',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
 