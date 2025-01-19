import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/view/Pages_Ajout/ajout_produit.dart';
import 'package:e_commerce/view/commande_detail.dart';
import 'package:e_commerce/view/connexion/login.dart';
import 'package:e_commerce/view/profil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PageAdmin extends StatefulWidget {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  const PageAdmin(
      {super.key,
      required this.id,
      required this.nom,
      required this.prenom,
      required this.email,
      required this.telephone,
      required this.adresse});
  @override
  State<PageAdmin> createState() => _PageAdminState();
}

class _PageAdminState extends State<PageAdmin> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const CommandesPage(),
    const ProduitsPage(),
    const UsersPage(),
  ];
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
                            prenom: widget
                                .prenom, 
                            email:
                                widget.email, 
                            telephone: widget
                                .telephone, 
                            adresse: widget
                                .adresse, 
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
    String firstLetterOfNom = widget.nom.isNotEmpty
        ? widget.nom[0].toUpperCase()
        : ''; 
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 7,),
              Text(
                widget.nom, 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
             ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu), 
            onPressed: () {
              _afficherMenuBurger(context);
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Commandes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Produits'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Utilisateurs'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('users').snapshots(),
        builder: (context, usersSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('commandes').snapshots(),
            builder: (context, commandesSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('produits').snapshots(),
                builder: (context, produitsSnapshot) {
                  if (usersSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      commandesSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      produitsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (usersSnapshot.hasError ||
                      commandesSnapshot.hasError ||
                      produitsSnapshot.hasError) {
                    return const Center(
                        child: Text('Erreur de chargement des données'));
                  }

                  int totalUsers = usersSnapshot.data?.size ?? 0;
                  int totalCommandes = commandesSnapshot.data?.size ?? 0;
                  int totalProduits = produitsSnapshot.data?.size ?? 0;

                  return Column(
                    children: [
                      _buildStatCard(
                          'Total Utilisateurs', totalUsers, Colors.blue),
                      _buildStatCard(
                          'Total Commandes', totalCommandes, Colors.green),
                      _buildStatCard(
                          'Total Produits', totalProduits, Colors.orange),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            count.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(title),
      ),
    );
  }
}

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
              child: Text('Erreur de chargement des utilisateurs'));
        }

        List<QueryDocumentSnapshot> users = snapshot.data?.docs ?? [];
        List<QueryDocumentSnapshot> clients =
            users.where((doc) => doc['role'] == 'client').toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Clients',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              ...clients.map((doc) {
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                doc['prenom'][0], 
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['prenom'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  doc['nom'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.info, color: Colors.blueAccent),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              const Text(
                'Admins',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class ProduitsPage extends StatefulWidget {
  const ProduitsPage({super.key});

  @override
  State<ProduitsPage> createState() => _ProduitsPageState();
}

class _ProduitsPageState extends State<ProduitsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 20;

  List<QueryDocumentSnapshot> produits = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadProduits();
  }

  Future<void> _loadProduits() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query =
          _firestore.collection('produits').orderBy('nom').limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          produits.addAll(snapshot.docs);
          _lastDocument = snapshot.docs.last;
          if (snapshot.docs.length < _pageSize) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduit(String produitId) async {
    try {
      await _firestore.collection('produits').doc(produitId).delete();
      setState(() {
        produits.removeWhere((produit) => produit.id == produitId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit supprimé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : $e')),
        );
      }
    }
  }

  void _showDetails(BuildContext context, QueryDocumentSnapshot produit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(produit['nom']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              produit['image'] != null
                  ? Image.network(produit['image'])
                  : const Icon(Icons.image, size: 50, color: Colors.grey),
              const SizedBox(height: 10),
              Text('Description: ${produit['description'] ?? 'N/A'}'),
              Text('Prix: ${produit['prix']}'),
              Text('Quantité: ${produit['quantite']}'),
              Text('Catégorie: ${produit['categorie'] ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<QueryDocumentSnapshot>> produitsParCategorie = {};

    for (var produit in produits) {
      String categorie = produit['categorie'] ?? 'Autre';
      produitsParCategorie.putIfAbsent(categorie, () => []).add(produit);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ...produitsParCategorie.entries.map((entry) {
            return ExpansionTile(
              title: Text(entry.key),
              children: entry.value.map((produit) {
                return ListTile(
                  leading: produit['image'] != null
                      ? Image.network(
                          produit['image'],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.shopping_bag),
                  title: Text(produit['nom']),
                  subtitle: Text('Prix: ${produit['prix']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info, color: Colors.blue),
                        onPressed: () => _showDetails(context, produit),
                        tooltip: 'Voir les détails',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduit(produit.id),
                        tooltip: 'Supprimer',
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_hasMore && !_isLoading)
            ElevatedButton(
              onPressed: _loadProduits,
              child: const Text('Charger plus'),
            ),
          if (!_hasMore && !_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('Tous les produits ont été chargés.')),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AjoutPage()),
          );
        },
        tooltip: 'Ajouter Produit',
        backgroundColor: Colors.blue, 
        child: const Icon(Icons.add, color: Colors.white), 
      ),
    );
  }
}

class CommandesPage extends StatelessWidget {
  const CommandesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('commandes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
              child: Text('Erreur de chargement des commandes'));
        }

        List<QueryDocumentSnapshot> commandes = snapshot.data?.docs ?? [];

        return ListView.builder(
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              var commande = commandes[index];
              var date = (commande['date'] as Timestamp).toDate();
              var formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(date);
              var total = commande['total'] ?? 'Inconnu';
              var adresse = commande['adresse'] ?? 'Non spécifiée';

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
    );
  }
}
