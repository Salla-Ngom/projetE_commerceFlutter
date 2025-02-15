import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/services/services_clients/client_bloc.dart';
import 'package:e_commerce/view/connexion/login.dart';
import 'package:e_commerce/view/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'page_notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/services_produits/product_event.dart';
import '../services/services_produits/product_state.dart';
import 'profil.dart';
import 'panier.dart';
import 'package:intl/intl.dart';

class ClientPage extends StatefulWidget {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  const ClientPage(
      {super.key,
      required this.id,
      required this.nom,
      required this.prenom,
      required this.email,
      required this.telephone,
      required this.adresse});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  int _currentIndex = 0;
  // Liste des pages
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ClientHomePage(userIdC: widget.id),
      CommandePageC(userId: widget.id),
      NotificationPage(),
      ProfilPage(
        id: widget.id,
        nom: widget.nom,
        prenom: widget.prenom,
        email: widget.email,
        telephone: widget.telephone,
        adresse: widget.adresse,
      ),
    ];
  }

  Future<void> _deconnecterUtilisateur() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
        );
      }
    }
  }

  void _afficherMenuBurger(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilPage(
                            id: widget.id,
                            nom: widget.nom,
                            prenom: widget.prenom,
                            email: widget.email,
                            telephone: widget.telephone,
                            adresse: widget.adresse,
                          )),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                _deconnecterUtilisateur();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String firstLetterOfNom =
        widget.nom.isNotEmpty ? widget.nom[0].toUpperCase() : '';
    String firstLetterOfPrenom =
        widget.prenom.isNotEmpty ? widget.prenom[0].toUpperCase() : '';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '$firstLetterOfPrenom$firstLetterOfNom',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.prenom,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  widget.nom,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PanierPage(userId: widget.id, adresse: widget.adresse)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _afficherMenuBurger(context);
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          if (index >= 0 && index < _pages.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}

class ClientHomePage extends StatelessWidget {
  final String userIdC;

  const ClientHomePage({super.key, required this.userIdC});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClientBloc()..add(ProductLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Produits disponibles'),
        ),
        body: BlocBuilder<ClientBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductError) {
              return Center(child: Text('Erreur : ${state.message}'));
            } else if (state is ProductLoaded || state is ProductAddedToCart) {
              List<Product> products = state is ProductLoaded
                  ? state.products
                  : (state as ProductAddedToCart).products;

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  Product product = products[index];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported, size: 50),
                      title: Text(product.title),
                      subtitle:
                          Text('Prix : \$${product.price.toStringAsFixed(2)}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          context.read<ClientBloc>().add(AddToCartRequested(
                                product: product,
                                userId: userIdC,
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 27, 161, 27),
                        ),
                        child: const Text('Ajouter'),
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(child: Text('Aucun produit disponible.'));
          },
        ),
      ),
    );
  }
}

class CommandePageC extends StatelessWidget {
  final String userId;

  const CommandePageC({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    CollectionReference commandes =
        FirebaseFirestore.instance.collection('commandes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: commandes
            .where('userId', isEqualTo: userId)
            .orderBy('date', descending: true)
            .snapshots(),
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
                        builder: (context) =>
                            CommandeDetailPageC(commandeId: commande.id),
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

class CommandeDetailPageC extends StatelessWidget {
  final String commandeId;

  const CommandeDetailPageC({super.key, required this.commandeId});

  @override
  Widget build(BuildContext context) {
    CollectionReference commandes =
        FirebaseFirestore.instance.collection('commandes');

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
          var commandeData =
              commande.data() as Map<String, dynamic>; // Cast des données
          var produits =
              List<Map<String, dynamic>>.from(commandeData['produits']);
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Adresse de livraison : $adresse'),
                  const SizedBox(height: 10),
                  Text('Total : ${total.toString()} FCFA',
                      style:
                          const TextStyle(color: Colors.green, fontSize: 18)),
                  const Divider(height: 30, thickness: 1),
                  const Text('Produits :',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const Text('Statut de livraison :',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Livraison : $livraison'),
                  if (dateLivraison != null)
                    Text('Date de livraison : ${dateLivraison.toString()}'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
