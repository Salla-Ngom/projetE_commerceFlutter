import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/view/connexion/login.dart';
import 'package:e_commerce/view/profil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PageSuperAdmin extends StatefulWidget {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  const PageSuperAdmin(
      {super.key,
      required this.id,
      required this.nom,
      required this.prenom,
      required this.email,
      required this.telephone,
      required this.adresse});
  @override
  State<PageSuperAdmin> createState() => _PageAdminState();
}

class _PageAdminState extends State<PageSuperAdmin> {
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
        List<QueryDocumentSnapshot> admins =
            users.where((doc) => doc['role'] == 'Admin').toList();

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
              ...admins.map((doc) {
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
                              backgroundColor: Colors.orangeAccent,
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
                          icon: const Icon(Icons.info,
                              color: Colors.orangeAccent),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AjouterAdminForm(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Ajouter Admin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProduitsPage extends StatelessWidget {
  const ProduitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('produits').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erreur de chargement des produits'));
        }

        List<QueryDocumentSnapshot> produits = snapshot.data?.docs ?? [];
        Map<String, List<QueryDocumentSnapshot>> produitsParCategorie = {};

        for (var produit in produits) {
          String categorie = produit['categorie'] ?? 'Autre';
          produitsParCategorie.putIfAbsent(categorie, () => []).add(produit);
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ...produitsParCategorie.entries.map((entry) {
                return ExpansionTile(
                  title: Text(entry.key),
                  children: entry.value.map((produit) {
                    return ListTile(
                      title: Text(produit['nom']),
                      subtitle: Text('Prix: ${produit['prix']}'),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      },
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
            var commande = commandes[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text('Commande ${index + 1}'),
              subtitle: Text('Total: ${commande['total']}'),
            );
          },
        );
      },
    );
  }
}

class AjouterAdminForm extends StatefulWidget {
  const AjouterAdminForm({super.key});
  @override
  State<AjouterAdminForm> createState() => _AjouterAdminFormState();
}

class _AjouterAdminFormState extends State<AjouterAdminForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();

  Future<void> _ajouterAdmin() async {
    final String nom = _nomController.text.trim();
    final String prenom = _prenomController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String telephone = _telephoneController.text.trim();
    final String adresse = _adresseController.text.trim();
    final bool actif = true;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String userId = userCredential.user!.uid; 
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'id': userId,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
        'actif': actif,
        'role': 'Admin',
      });
      _nomController.clear();
      _prenomController.clear();
      _emailController.clear();
      _passwordController.clear();
      _telephoneController.clear();
      _adresseController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin ajouté avec succès !')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Cet email est déjà utilisé.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Le mot de passe est trop faible.';
      } else {
        errorMessage = 'Une erreur est survenue.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un Admin'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un nom' : null,
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un prénom' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty || !value.contains('@')
                    ? 'Veuillez entrer un email valide'
                    : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'Le mot de passe doit contenir au moins 6 caractères'
                    : null,
              ),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un téléphone' : null,
              ),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer une adresse' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _ajouterAdmin,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
