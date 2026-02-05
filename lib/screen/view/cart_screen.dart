import 'package:computer_store/bloc/cart_bloc.dart';
import 'package:computer_store/screen/view/confirm_order.dart';
import 'package:computer_store/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          // subtotal
          double subtotal = 0;
          for (var item in state.cartList) {
            subtotal += (item.price ?? 0) * (item.stock ?? 0);
          }

          if (state.cartList.isEmpty) {
            return const Center(
              child: Text(
                "Cart is empty",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.cartList.length,
                  itemBuilder: (context, index) {
                    final item = state.cartList[index];

                    return Dismissible(
                      key: ValueKey("${item.id}-${item.name}-$index"),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE84C4C),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Remove item?"),
                            content: Text("Delete ${item.name}?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                        return ok ?? false;
                      },
                      onDismissed: (_) {
                        context.read<CartBloc>().add(RemoveItem(index: index));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${item.name} removed")),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        height: 92,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 12,
                              color: Color(0x0F000000),
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),

                            /// IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 70,
                                height: 70,
                                color: const Color(0xFFF1F1F1),
                                child: Image.network(
                                  "${item.image}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// NAME + PRICE
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${item.name}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "\$ ${(item.price ?? 0).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// +/- BUTTONS
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Row(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () {
                                      final qty = item.stock ?? 0;
                                      if (qty > 1) {
                                        context
                                            .read<CartBloc>()
                                            .add(Decrements(index: index));
                                      } else {
                                        context
                                            .read<CartBloc>()
                                            .add(RemoveItem(index: index));
                                      }
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFD1D5DB),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.remove,
                                        size: 16,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("${item.stock ?? 0}"),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () {
                                      context
                                          .read<CartBloc>()
                                          .add(Increments(index: index));
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF1F2937),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// SUMMARY
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      color: Color(0x14000000),
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      _row("Subtotal :", "\$ ${subtotal.toStringAsFixed(2)}"),
                      const SizedBox(height: 10),
                      _row("Delivery Fee :", "\$ 0.00"),
                      const SizedBox(height: 10),
                      _row(
                        "Discount :",
                        "10%",
                        valueColor: const Color(0xFFE84C4C),
                      ),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 14),
                      _row(
                        "Total :",
                        "\$ ${subtotal.toStringAsFixed(2)}",
                        big: true,
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(Colorr.primaryColorBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ConfirmOrder(total: subtotal),
                              ),
                            );
                          },
                          child: Text(
                            "Check out",
                            style: TextStyle(
                              color: Color(Colorr.primaryColorLitter),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(
    String title,
    String value, {
    bool big = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontWeight: big ? FontWeight.w700 : FontWeight.w600,
            fontSize: big ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: big ? 16 : 14,
            color: valueColor ?? const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
