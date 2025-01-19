import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/view/commande_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommandePage extends StatelessWidget {
  final String userId;

  const CommandePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    CollectionReference commandes = FirebaseFirestore.instance.collection('commandes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: commandes.where('userId', isEqualTo: userId).orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune commande trouvée.'));
          }

          var commandesData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: commandesData.length,
            itemBuilder: (context, index) {
              var commande = commandesData[index];
              var date = (commande['date'] as Timestamp).toDate();
              var formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(date);
              var total = commande['total'] ?? 'Inconnu';
              var adresse = commande['adresse'] ?? 'Non spécifiée';
              var livree = commande['livraison'] ?? 'non spécifiée';

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Commande #${index + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date : $formattedDate'),
                      Text('Total : $total FCFA'),
                      Text('Adresse : $adresse'),
                      Text('Livraison : $livree'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward, color: Colors.blue),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommandeDetailPage(commandeId: commande.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
