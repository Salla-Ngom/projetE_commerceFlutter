import'../../view/product.dart';
abstract class ClientEvent {}

class ClientPageChanged extends ClientEvent {
  final int newIndex;

  ClientPageChanged(this.newIndex);
}

class ClientLogoutRequested extends ClientEvent {}
class AddToCartRequested extends ClientEvent {
  final Product product;
  final String userId;

  AddToCartRequested({required this.userId,required this.product});
}