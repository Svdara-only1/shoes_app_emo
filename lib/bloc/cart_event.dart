part of 'cart_bloc.dart';

@immutable
sealed class CartEvent {}
// ignore: must_be_immutable
class AddtoCart extends CartEvent{
  Product item;
  AddtoCart({required this.item});
}
// ignore: must_be_immutable
class Increments extends CartEvent{
  int index;
  Increments({required this.index});
}
// ignore: must_be_immutable
class Decrements extends CartEvent{
  int index;
  Decrements({required this.index});
}
class RemoveItem extends CartEvent {
  final int index;
  RemoveItem({required this.index});
}