import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bottom_navbar_event.dart';
part 'bottom_navbar_state.dart';

class BottomNavbarBloc extends Bloc<BottomNavbarEvent, BottomNavbarState> {
  BottomNavbarBloc() : super(BottomNavbarState(index: 0)) {
    on<SelectedBottomNav>((event, emit) {
      // TODO: implement event handler
      emit(BottomNavbarState(index: event.index));
    });
  }
}
