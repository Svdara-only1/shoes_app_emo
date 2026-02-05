import 'package:computer_store/bloc/bottom_navbar_bloc.dart';
import 'package:computer_store/screen/view/favorite_screen.dart';
import 'package:computer_store/screen/view/home_screen.dart';
import 'package:computer_store/screen/view/cart_screen.dart';
import 'package:computer_store/screen/view/profile_screen.dart';
import 'package:computer_store/screen/view/search_screen.dart';
import 'package:computer_store/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavbarScreen extends StatelessWidget {
   BottomNavbarScreen({super.key});

  final List<Widget> screen = [
    HomeScreen(),
    SearchScreen(),
    FavoriteScreen(),
    CartScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavbarBloc, BottomNavbarState>(
      builder: (context, state) {
        return Scaffold(
          body: screen[state.index],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Color(Colorr.primaryColorBlue),
            currentIndex: state.index,
            onTap: (value) {
              context.read<BottomNavbarBloc>().add(SelectedBottomNav(index: value));
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Color(Colorr.primaryColorLitter),
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                label: "Favorite",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: "Cart",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        );
      },
    );
  }
}
