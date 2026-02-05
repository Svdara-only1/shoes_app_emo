part of 'bottom_navbar_bloc.dart';

@immutable
sealed class BottomNavbarEvent {}
// ignore: must_be_immutable
class SelectedBottomNav extends BottomNavbarEvent{
  int index;
  SelectedBottomNav({required this.index});
}