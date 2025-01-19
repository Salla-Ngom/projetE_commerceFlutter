import 'package:cloud_firestore/cloud_firestore.dart';

class Panier {
  final String id; 
  final String utilisateurId; 
  final List<Map<String, dynamic>> produits; 
  final double montantTotal; 
  final Timestamp dateMiseAJour; 

  Panier({
    required this.id,
    required this.utilisateurId,
    required this.produits,
    required this.montantTotal,
    required this.dateMiseAJour,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateurId': utilisateurId,
      'produits': produits.map((produit) => {
            'nom_produit': produit['nom_produit'],
            'prix': produit['prix'],
            'quantité': produit['quantité'],
          }).toList(),
      'montantTotal': montantTotal,
      'dateMiseAJour': dateMiseAJour,
    };
  }
  factory Panier.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Panier(
      id: doc.id,
      utilisateurId: data['utilisateurId'],
      produits: List<Map<String, dynamic>>.from(data['produits']),
      montantTotal: data['montantTotal'],
      dateMiseAJour: data['dateMiseAJour'],
    );
  }
}
