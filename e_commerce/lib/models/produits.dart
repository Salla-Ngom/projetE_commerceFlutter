import 'package:cloud_firestore/cloud_firestore.dart';

class Produit {
  final String id; 
  final String nom;
  final String description;
  final double prix;
  final String categorie; 
  final int stock;
  final String vendeurId; 
  final List<String> images; 
  final DateTime dateAjout;

  Produit({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.categorie,
    required this.stock,
    required this.vendeurId,
    required this.images,
    required this.dateAjout,
  });
  factory Produit.fromFirestore(Map<String, dynamic> data, String docId) {
    return Produit(
      id: docId,
      nom: data['nom'] ?? '',
      description: data['description'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      categorie: data['categorie'] ?? '',
      stock: data['stock'] ?? 0,
      vendeurId: data['vendeurId'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      dateAjout: (data['dateAjout'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'prix': prix,
      'categorie': categorie,
      'stock': stock,
      'vendeurId': vendeurId,
      'images': images,
      'dateAjout': dateAjout,
    };
  }
}