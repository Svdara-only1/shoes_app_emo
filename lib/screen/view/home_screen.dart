import 'dart:ui';
import 'package:computer_store/screen/view/detail_screen.dart';
import 'package:computer_store/service/api_service.dart';
import 'package:computer_store/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:computer_store/model/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:computer_store/bloc/favorite_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedBrand = "All";
  String _search = "";

  Future<List<Product>>? _futureProducts;

  // call once
  @override
  void initState() {
    super.initState();
    _futureProducts = ApiService.getProduct();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureProducts = ApiService.getProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(Colorr.primaryColorBlue);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: FutureBuilder<List<Product>>(
          future: _futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No data"));
            }

            final products = snapshot.data!;
            final brands = <String>[
              "All",
              ...{
                for (final p in products)
                  if ((p.brand ?? "").trim().isNotEmpty) p.brand!.trim(),
              },
            ];

            final filtered = products.where((p) {
              final okBrand =
                  _selectedBrand == "All" || (p.brand == _selectedBrand);
              final q = _search.trim().toLowerCase();
              final okSearch =
                  q.isEmpty ||
                  (p.name ?? "").toLowerCase().contains(q) ||
                  (p.brand ?? "").toLowerCase().contains(q);
              return okBrand && okSearch;
            }).toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ===== Top App Bar (beautiful) =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hi, Sv dara 👋",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Find your next pair",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black.withOpacity(.55),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _CircleIconButton(
                            icon: Icons.notifications_none_rounded,
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          _CircleIconButton(
                            icon: Icons.shopping_bag_outlined,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== Hero Banner =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _HeroBanner(primary: primary),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // ===== Search Bar =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                    color: Colors.black.withOpacity(.06),
                                  ),
                                ],
                              ),
                              child: TextField(
                                onChanged: (v) => setState(() => _search = v),
                                decoration: InputDecoration(
                                  hintText: "Search shoes, brand...",
                                  hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(.35),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.black.withOpacity(.5),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            // margin: EdgeInsets.only(),
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                  color: primary.withOpacity(.25),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.tune, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // ===== Brand Chips =====
                  SliverToBoxAdapter(
                    child: Container(
                      height: 44,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final b = brands[index];
                          final selected = b == _selectedBrand;
                          return InkWell(
                            onTap: () => setState(() => _selectedBrand = b),
                            borderRadius: BorderRadius.circular(999),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected ? primary : Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: selected
                                      ? primary
                                      : Colors.black.withOpacity(.08),
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                          color: primary.withOpacity(.22),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                          color: Colors.black.withOpacity(.05),
                                        ),
                                      ],
                              ),
                              child: Text(
                                b,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.black.withOpacity(.75),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemCount: brands.length,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // ===== Title row =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Popular",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            "${filtered.length} items",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                  // ===== Products Grid =====
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = filtered[index];
                        return _ProductCard(
                          product: product,
                          primary: primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(product: product),
                              ),
                            );
                          },
                        );
                      }, childCount: filtered.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// =====================
// Widgets
// =====================

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(.06),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black.withOpacity(.7)),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final Color primary;
  const _HeroBanner({required this.primary});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withOpacity(.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // soft circles
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -50,
              child: Container(
                height: 170,
                width: 170,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "New Collection",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Up to 30% off\nfor limited time",
                          style: TextStyle(
                            color: Colors.white.withOpacity(.92),
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "Shop now",
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Placeholder shoe image (you can replace with your own asset/network)
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Icons.directions_run,
                      size: 62,
                      color: Colors.white.withOpacity(.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final Color primary;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inStock = (product.stock ?? 0) > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(.06),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image + badges
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.image ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF1F2F6),
                        child: const Icon(Icons.image_not_supported, size: 46),
                      ),
                    ),
                    // dark blur top for icons
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: [
                          _GlassPill(
                            text: inStock ? "In Stock" : "Out",
                            icon: Icons.circle,
                            iconColor: inStock ? Colors.green : Colors.red,
                          ),
                          const Spacer(),
                          const Spacer(),
                          BlocBuilder<FavoriteBloc, FavoriteState>(
                            builder: (context, favState) {
                              final isFav = favState.favorites.any(
                                (p) => p.id == product.id,
                              );

                              return InkWell(
                                onTap: () {
                                  context.read<FavoriteBloc>().add(
                                    ToggleFavorite(product: product),
                                  );
                                },
                                borderRadius: BorderRadius.circular(999),
                                child: _GlassIcon(
                                  icon: isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? "Unknown",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.brand ?? "",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(.45),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "\$${(product.price ?? 0).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: primary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  final IconData icon;
  const _GlassIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(.18)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;

  const _GlassPill({
    required this.text,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(.18)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 10, color: iconColor),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
