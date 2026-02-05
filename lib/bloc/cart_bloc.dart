import 'package:bloc/bloc.dart';
import 'package:computer_store/model/product.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState(cartList: [],)) {
    // on<CartEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on<AddtoCart>((event, emit) {
      // emit(CartState(cartList: state.cartList.add(event.item)));
      emit(CartState(cartList: [...state.cartList,event.item]));
    },);
    on<Increments>((event, emit) {
      state.cartList[event.index].stock=state.cartList[event.index].stock!+1;
      emit(CartState(cartList: state.cartList));
    },);
    on<Decrements>((event, emit) {
      state.cartList[event.index].stock=state.cartList[event.index].stock!-1;
      emit(CartState(cartList: state.cartList));
    },);
    // ✅ NEW remove
    on<RemoveItem>((event, emit) {
      final list = List<Product>.from(state.cartList);
      if (event.index >= 0 && event.index < list.length) {
        list.removeAt(event.index);
      }
      emit(CartState(cartList: list));
    });
  }
  
}
