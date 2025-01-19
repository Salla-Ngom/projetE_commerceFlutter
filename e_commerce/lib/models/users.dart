class User {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String password; 
  final String telephone;
  final String adresse;
  final String role; 
  final bool actif;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.telephone,
    required this.adresse,
    required this.role,
    required this.actif,
  });

  
  factory User.fromFirestore(Map<String, dynamic> data, String docId) {
    return User(
      id: docId,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      telephone: data['telephone'] ?? '',
      adresse: data['adresse'] ?? '',
      role: data['role'] ?? 'client',
      actif: data['actif'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      'telephone': telephone,
      'adresse': adresse,
      'role': role,
      'actif': actif,
    };
  }
}
