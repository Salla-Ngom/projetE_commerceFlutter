// client_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/services/services_produits/product_event.dart';
import 'package:e_commerce/services/services_produits/product_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:e_commerce/view/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ClientBloc extends Bloc<ProductEvent, ProductState> {
  List<Product> _products = []; // Stocker la liste des produits localement

  ClientBloc() : super(ProductInitial()) {
    on<ProductLoadRequested>(_onProductLoadRequested);
    on<AddToCartRequested>(_onAddToCartRequested);
  }

  Future<void> _onProductLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
      if (response.statusCode == 200) {
        _products = json.decode(response.body).map<Product>((json) => Product.fromJson(json)).toList();
        emit(ProductLoaded(_products));
      } else {
        emit(ProductError('Failed to load products'));
      }
    } catch (e) {
      emit(ProductError('Error: $e'));
    }
  }

    Future<void> _onAddToCartRequested(
  AddToCartRequested event,
  Emitter<ProductState> emit,
) async {
  try {
    final CollectionReference paniers = FirebaseFirestore.instance.collection('paniers');
    DocumentSnapshot panierSnapshot = await paniers.doc(event.userId).get();
    
    if (panierSnapshot.exists) {
      Map<String, dynamic> panierData = panierSnapshot.data() as Map<String, dynamic>;
      List produits = panierData['produits'] ?? [];
      int indexProduit = produits.indexWhere((produit) => produit['id'] == event.product.id);
      if (indexProduit != -1) {
        produits[indexProduit]['quantite'] += 1;
      } else {
        produits.add({
          'id': event.product.id,
          'nom': event.product.title,
          'prix': event.product.price * 500,
          'quantite': 1,
          'image': event.product.imageUrl,
        });
      }

      double montantTotal = produits.fold(0, (total, produit) => total + produit['prix'] * produit['quantite']);

      await paniers.doc(event.userId).update({
        'produits': produits,
        'total': montantTotal,
      });

      emit(ProductAddedToCart(products: _products, product: event.product));
    } else {
      await paniers.doc(event.userId).set({
        'produits': [
          {
            'id': event.product.id,
            'nom': event.product.title,
            'prix': event.product.price * 500,
            'quantite': 1,
          }
        ],
        'total': event.product.price * 500,
      });

      emit(ProductAddedToCart(products: _products, product: event.product));
    }
  } catch (e) {
    emit(ProductAddToCartError('Erreur lors de l\'ajout au panier : $e'));
  }
}


}
