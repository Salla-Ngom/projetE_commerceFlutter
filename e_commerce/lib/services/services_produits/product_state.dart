import '../../view/product.dart';
abstract class ProductState {}
class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductLoaded extends ProductState {
  final List<Product> products;

  ProductLoaded(this.products);
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}

class ProductSearchResult extends ProductState {
  final List<Product> filteredProducts;

  ProductSearchResult(this.filteredProducts);
}
class ProductAddedToCart extends ProductState {
  final List<Product> products; // Liste des produits chargés
  final Product product; // Produit ajouté au panier

  ProductAddedToCart({required this.products, required this.product});
}


class ProductAddToCartError extends ProductState {
  final String message;

  ProductAddToCartError(this.message);
}

