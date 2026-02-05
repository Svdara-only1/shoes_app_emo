part of 'favorite_bloc.dart';

@immutable
abstract class FavoriteEvent {}

class ToggleFavorite extends FavoriteEvent {
  final Product product;
  ToggleFavorite({required this.product});
}

class RemoveFavorite extends FavoriteEvent {
  final int index;
  RemoveFavorite({required this.index});
}

class ClearFavorites extends FavoriteEvent {}
