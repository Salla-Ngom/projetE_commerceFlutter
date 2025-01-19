import 'package:cloud_firestore/cloud_firestore.dart';

class Commande {
  final String id;
  final String utilisateurId;
  final String produitNom;
  final int produitQuantite;
  final double produitPrixUnitaire;
  final String vendeurId;
  final String statut;
  final Timestamp dateCreation;
  final double montantTotal;
  final String adresseLivraison;
  final String moyenPaiement;

  Commande({
    required this.id,
    required this.utilisateurId,
    required this.produitNom,
    required this.produitQuantite,
    required this.produitPrixUnitaire,
    required this.vendeurId,
    required this.statut,
    required this.dateCreation,
    required this.montantTotal,
    required this.adresseLivraison,
    required this.moyenPaiement,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateurId': utilisateurId,
      'produitNom': produitNom,
      'produitQuantite': produitQuantite,
      'produitPrixUnitaire': produitPrixUnitaire,
      'vendeurId': vendeurId,
      'statut': statut,
      'dateCreation': dateCreation,
      'montantTotal': montantTotal,
      'adresseLivraison': adresseLivraison,
      'moyenPaiement': moyenPaiement,
    };
  }
  factory Commande.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Commande(
      id: doc.id,
      utilisateurId: data['utilisateurId'],
      produitNom: data['produitNom'],
      produitQuantite: data['produitQuantite'],
      produitPrixUnitaire: data['produitPrixUnitaire'],
      vendeurId: data['vendeurId'],
      statut: data['statut'],
      dateCreation: data['dateCreation'],
      montantTotal: data['montantTotal'],
      adresseLivraison: data['adresseLivraison'],
      moyenPaiement: data['moyenPaiement'],
    );
  }
}
