import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class AjoutPage extends StatefulWidget {
  const AjoutPage({super.key});

  @override
  State<AjoutPage> createState() => _AjoutPageState();
}

class _AjoutPageState extends State<AjoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String? selectedCategory;
  File? selectedImage;

  final List<String> categories = [
    'Vêtements',
    'Électronique',
    'Accessoires',
    'Maison',
  ];

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToStorage(File image) async {
    try {
      final String fileName = const Uuid().v4();
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('produits/$fileName');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
       if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'upload de l\'image : $e')),
      );
       }
      return null;
    }
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String? imageUrl;
      if (selectedImage != null) {
        imageUrl = await _uploadImageToStorage(selectedImage!);
      }
      await FirebaseFirestore.instance.collection('produits').add({
        'nom': nameController.text,
        'description': descriptionController.text,
        'prix': double.parse(priceController.text),
        'quantite': int.parse(quantityController.text),
        'categorie': selectedCategory,
        'image': imageUrl ?? '',
        'dateCreation': Timestamp.now(),
      });
if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit ajouté avec succès !')),
      );
}
      setState(() {
        nameController.clear();
        descriptionController.clear();
        priceController.clear();
        quantityController.clear();
        selectedCategory = null;
        selectedImage = null;
      });
    } catch (e) {
      if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Produit'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Ajout produit',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _selectImage,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.upload_file, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  "Téléversez une image",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du produit',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom de produit.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Prix
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prix.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un prix valide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une quantité.';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Veuillez entrer une quantité valide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une catégorie.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _addProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Ajouter',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
