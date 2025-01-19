import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PanierPage extends StatefulWidget {
  final String userId;
  final String adresse;
  const PanierPage({super.key, required this.userId,required this.adresse});

  @override
  State<PanierPage> createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  late final FirebaseFirestore _firestore;
  late final String userId;
  late final String adresse;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    userId = widget.userId;
    adresse = widget.adresse;
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _updateQuantite(String produitId, int nouvelleQuantite) async {
    try {
      if (nouvelleQuantite < 1) return;

      DocumentSnapshot panierSnapshot =
          await _firestore.collection('paniers').doc(userId).get();

      if (panierSnapshot.exists) {
        Map<String, dynamic> panierData =
            panierSnapshot.data() as Map<String, dynamic>;
        List produits = panierData['produits'] ?? [];

        for (var produit in produits) {
          if (produit['id'] == produitId) {
            produit['quantite'] = nouvelleQuantite;
            break;
          }
        }
        double nouveauTotal = produits.fold(
          0.0,
          (som, produit) =>
              som + ((produit['prix'] ?? 0.0) * (produit['quantite'] ?? 0)),
        );
        await _firestore.collection('paniers').doc(userId).update({
          'produits': produits,
          'total': nouveauTotal,
        });
        setState(() {});
      }
    } catch (e) {
      showSnackBar('Erreur lors de la mise à jour de la quantité: $e');
    }
  }

  Future<void> _viderPanier() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous vraiment vider le panier ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        await _firestore.collection('paniers').doc(userId).update({
          'produits': [],
          'total': 0.0,
        });
        setState(() {});
      } catch (e) {
        showSnackBar('Erreur lors de la mise à jour du panier: $e');
      }
    }
  }

  Future<void> _validerCommande(List produits, double total) async {
    if (produits.isEmpty) {
      showSnackBar('Votre panier est vide. Impossible de valider la commande.');
      return;
    }

    try {
      await _firestore.collection('commandes').add({
        'userId': userId,
        'produits': produits,
        'total': total,
        'date': FieldValue.serverTimestamp(),
        'adresse': adresse,
        'livraison': 'en attente'
      });

      await _viderPanier();

      showSnackBar('Paiement réussi et commande validée !');
    } catch (e) {
      showSnackBar(
          'Erreur lors du paiement ou de la validation de la commande: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('paniers').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Aucun panier trouvé.'));
          }

          var panierData = snapshot.data!.data() as Map<String, dynamic>;
          List produits = panierData['produits'] ?? [];
          double total = panierData['total'] ?? 0.0;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails du panier',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  if (produits.isEmpty)
                    const Center(child: Text('Votre panier est vide.'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: produits.length,
                      itemBuilder: (context, index) {
                        var produit = produits[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Column(
                            children: [
                              ListTile(
                                leading: produit['image'] != null
                                    ? Image.network(produit['image'], width: 50)
                                    : const Icon(Icons.image_not_supported),
                                title:
                                    Text(produit['nom'] ?? 'Produit sans nom'),
                                subtitle: Text('Prix: ${produit['prix']} fcfa'),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (produit['quantite'] > 1) {
                                        _updateQuantite(
                                          produit['id'] ?? '',
                                          produit['quantite'] - 1,
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text('${produit['quantite']}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _updateQuantite(
                                        produit['id'] ?? '',
                                        produit['quantite'] + 1,
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Total: ${total.toStringAsFixed(2)} fcfa',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _viderPanier,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Vider le panier'),
                      ),
                      ElevatedButton(
                        onPressed: () => _validerCommande(produits, total),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Valider la commande'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
