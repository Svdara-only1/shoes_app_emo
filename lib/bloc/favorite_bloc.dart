import 'package:bloc/bloc.dart';
import 'package:computer_store/model/product.dart';
import 'package:meta/meta.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(const FavoriteState(favorites: [])) {
    on<ToggleFavorite>((event, emit) {
      final list = List<Product>.from(state.favorites);

      final exists = list.indexWhere((p) => p.id == event.product.id);
      if (exists >= 0) {
        list.removeAt(exists);
      } else {
        list.add(event.product);
      }

      emit(FavoriteState(favorites: list));
    });

    on<RemoveFavorite>((event, emit) {
      final list = List<Product>.from(state.favorites);
      if (event.index >= 0 && event.index < list.length) {
        list.removeAt(event.index);
      }
      emit(FavoriteState(favorites: list));
    });

    on<ClearFavorites>((event, emit) {
      emit(const FavoriteState(favorites: []));
    });
  }
}
