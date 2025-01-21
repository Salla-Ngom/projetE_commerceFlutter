import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
import '../../view/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<ProductLoadRequested>(_onProductLoadRequested);
  }

  Future<void> _onProductLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading()); // Indiquer que les produits sont en cours de chargement
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Product> products = data.map((json) => Product.fromJson(json)).toList();
        emit(ProductLoaded(products)); // Produits chargés avec succès
      } else {
        emit(ProductError('Failed to load products')); // Échec du chargement
      }
    } catch (e) {
      emit(ProductError('Error: $e')); // Gérer l'erreur
    }
  }


}
