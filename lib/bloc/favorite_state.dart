part of 'favorite_bloc.dart';

@immutable
class FavoriteState {
  final List<Product> favorites;
  const FavoriteState({required this.favorites});
}
