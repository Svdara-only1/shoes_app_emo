part of 'counter_bloc.dart';

@immutable
sealed class CounterEvent {}
class Decrement extends CounterEvent{}
class Increment extends CounterEvent{}