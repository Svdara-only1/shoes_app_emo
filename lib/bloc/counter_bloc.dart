import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(count: 1)) {
    // on<CounterEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on<Decrement>((event, emit) {
      emit(CounterState(count: state.count-1));
    },);
    on<Increment>((event, emit) {
      emit(CounterState(count: state.count+1));
    },);
  }
}
