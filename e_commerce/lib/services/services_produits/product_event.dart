import'../../view/product.dart';

abstract class ProductEvent {}

class ProductLoadRequested extends ProductEvent {}

class ProductSearchRequested extends ProductEvent {
  final String query;

  ProductSearchRequested(this.query);
}
class AddToCartRequested extends ProductEvent {
  final Product product;
  final String userId;

  AddToCartRequested({required this.userId,required this.product});
}
