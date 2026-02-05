part of 'cart_bloc.dart';

@immutable
// ignore: must_be_immutable
class CartState {
  List <Product> cartList;
  // int counter;
  CartState({required this.cartList});
}
// class CartCounter{
//   int counter;
//   CartCounter({required this.counter});
// }