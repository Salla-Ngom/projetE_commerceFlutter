import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommandeDetailPage extends StatelessWidget {
  final String commandeId;

  const CommandeDetailPage({super.key, required this.commandeId});

  @override
  Widget build(BuildContext context) {
    CollectionReference commandes = FirebaseFirestore.instance.collection('commandes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Commande'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: commandes.doc(commandeId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Commande introuvable.'));
          }

          // Récupération des données de la commande
          var commande = snapshot.data!;
          var commandeData = commande.data() as Map<String, dynamic>; // Cast des données
          var produits = List<Map<String, dynamic>>.from(commandeData['produits']);
          var total = commandeData['total'];
          var adresse = commandeData['adresse'];
          var date = (commandeData['date'] as Timestamp).toDate();
          var livraison = commandeData['livraison'];
          var dateLivraison = commandeData.containsKey('dateLivraison') 
              ? (commandeData['dateLivraison'] as Timestamp).toDate() 
              : null;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commande passée le ${date.toString()}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Adresse de livraison : $adresse'),
                  const SizedBox(height: 10),
                  Text('Total : ${total.toString()} FCFA', style: const TextStyle(color: Colors.green, fontSize: 18)),
                  const Divider(height: 30, thickness: 1),
                  const Text('Produits :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: produits.length,
                    itemBuilder: (context, index) {
                      var produit = produits[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: Image.network(
                            produit['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(produit['nom']),
                          subtitle: Text(
                              'Prix : ${produit['prix']} FCFA\nQuantité : ${produit['quantite']}'),
                          trailing: Text(
                            '${produit['prix'] * produit['quantite']} FCFA',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 30, thickness: 1),
                  const Text('Statut de livraison :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Livraison : $livraison'),
                  if (dateLivraison != null) Text('Date de livraison : ${dateLivraison.toString()}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Mise à jour du champ 'dateLivraison'
                      await commandes.doc(commandeId).update({
                        'livraison': 'livrée',
                        'dateLivraison': FieldValue.serverTimestamp(),
                      });

                      // Affichage d'un message de confirmation
                      if(context.mounted){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Date de livraison mise à jour avec succès')),
                      );
                      }
                      // Rafraîchissement de la page
                      if(context.mounted){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => CommandeDetailPage(commandeId: commandeId)),
                      );
                      }
                    },
                    child: const Text('Marquer comme livrée'),
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
