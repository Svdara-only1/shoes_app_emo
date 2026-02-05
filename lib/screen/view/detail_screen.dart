import 'dart:ui';
import 'package:computer_store/bloc/cart_bloc.dart';
import 'package:computer_store/bloc/counter_bloc.dart';
import 'package:computer_store/model/product.dart';
import 'package:computer_store/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:computer_store/bloc/favorite_bloc.dart';

class DetailScreen extends StatelessWidget {
  final Product product;
  const DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final primary = Color(Colorr.primaryColorBlue);
    final lite = Color(Colorr.primaryColorLitter);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: BlocBuilder<CounterBloc, CounterState>(
        builder: (context, state) {
          final inStock = (product.stock ?? 0) > 0;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ===== Hero image + glass appbar =====
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    expandedHeight: 360,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            product.image ?? "",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFE9ECF5),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 60,
                              ),
                            ),
                          ),
                          // gradient overlay (for text contrast)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(.35),
                                    Colors.black.withOpacity(.10),
                                    Colors.black.withOpacity(.55),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // top glass buttons
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            left: 16,
                            right: 16,
                            child: Row(
                              children: [
                                _GlassRoundButton(
                                  icon: Icons.arrow_back,
                                  onTap: () => Navigator.pop(context),
                                ),
                                const Spacer(),
                                BlocBuilder<FavoriteBloc, FavoriteState>(
                                  builder: (context, favState) {
                                    final isFav = favState.favorites.any(
                                      (p) => p.id == product.id,
                                    );

                                    return _GlassRoundButton(
                                      icon: isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      onTap: () {
                                        context.read<FavoriteBloc>().add(
                                          ToggleFavorite(product: product),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // bottom title overlay
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 18,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _Chip(
                                      text: product.brand ?? "-",
                                      icon: Icons.verified,
                                    ),
                                    const SizedBox(width: 10),
                                    _Chip(
                                      text: product.category ?? "-",
                                      icon: Icons.local_offer_outlined,
                                    ),
                                    const Spacer(),
                                    _Chip(
                                      text: inStock ? "In Stock" : "Out",
                                      icon: Icons.circle,
                                      iconColor: inStock
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  product.name ?? "Unknown",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Color: ${product.color ?? "-"} • Size: ${product.size ?? "-"}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.9),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== Content =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price + qty row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _PriceCard(
                                  primary: primary,
                                  price: product.price ?? 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _QtyPill(
                                count: state.count,
                                onMinus: () {
                                  if (state.count > 1) {
                                    context.read<CounterBloc>().add(
                                      Decrement(),
                                    );
                                  }
                                },
                                onPlus: () {
                                  context.read<CounterBloc>().add(Increment());
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Description (optional text)
                          Text(
                            "Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black.withOpacity(.85),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Premium quality shoes built for comfort and style. Perfect for daily wear and performance. "
                            "Choose your quantity and add to cart.",
                            style: TextStyle(
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withOpacity(.55),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Specs
                          Text(
                            "Specifications",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black.withOpacity(.85),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _SpecsGrid(
                            primary: primary,
                            items: [
                              ("Brand", product.brand ?? "-"),
                              ("Category", product.category ?? "-"),
                              ("Size", product.size ?? "-"),
                              ("Color", product.color ?? "-"),
                              ("Stock", (product.stock ?? 0).toString()),
                              ("Quantity", state.count.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ===== Bottom sticky bar =====
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                        color: Colors.black.withOpacity(.06),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black.withOpacity(.45),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${((product.price ?? 0) * state.count).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: inStock
                                ? () {
                                    context.read<CartBloc>().add(
                                      AddtoCart(
                                        item: Product(
                                          id: product.id,
                                          name: product.name,
                                          brand: product.brand,
                                          category: product.category,
                                          size: product.size,
                                          color: product.color,
                                          price: product.price,
                                          stock: state.count, // qty saved here
                                          image: product.image,
                                          createdAt: product.createdAt,
                                          updatedAt: product.updatedAt,
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              disabledBackgroundColor: Colors.black.withOpacity(
                                .15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              inStock ? "Add to Cart" : "Out of Stock",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: lite,
                              ),
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
}

// ===== UI helpers =====

class _GlassRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _GlassRoundButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.20),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(.18)),
            ),
            child: Icon(icon, color: iconColor ?? Colors.white),
          ),
        ),
      ),
    );
  }
}


class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;

  const _Chip({required this.text, required this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.20),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: iconColor ?? Colors.white),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyPill({
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: Row(
        children: [
          _SmallIconBtn(icon: Icons.remove, onTap: onMinus),
          const SizedBox(width: 10),
          Text(
            "$count",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 10),
          _SmallIconBtn(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _SmallIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final Color primary;
  final double price;

  const _PriceCard({required this.primary, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_rounded, color: primary),
          const SizedBox(width: 10),
          Text(
            "\$${price.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  final Color primary;
  final List<(String, String)> items;

  const _SpecsGrid({required this.primary, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.7,
      ),
      itemBuilder: (context, i) {
        final (title, value) = items[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(.06)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withOpacity(.05),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.info_outline, color: primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(.45),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
