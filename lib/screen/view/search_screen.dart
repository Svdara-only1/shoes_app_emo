import 'dart:ui';
import 'package:computer_store/model/product.dart';
import 'package:computer_store/screen/view/detail_screen.dart';
import 'package:computer_store/service/api_service.dart';
import 'package:computer_store/theme/colors.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

enum SortMode { featured, priceLow, priceHigh, nameAZ, stockHigh }

class _SearchScreenState extends State<SearchScreen> {
  Future<List<Product>>? _future;

  String _q = "";
  String _brand = "All";
  SortMode _sort = SortMode.featured;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getProduct();
  }

  Future<void> _refresh() async {
    setState(() => _future = ApiService.getProduct());
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(Colorr.primaryColorBlue);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No products"));
            }

            final products = snapshot.data!;

            final brands = <String>["All", ...{
              for (final p in products)
                if ((p.brand ?? "").trim().isNotEmpty) p.brand!.trim()
            }];

            // filter
            final q = _q.trim().toLowerCase();
            var list = products.where((p) {
              final okBrand = _brand == "All" || (p.brand == _brand);
              final okQ = q.isEmpty ||
                  (p.name ?? "").toLowerCase().contains(q) ||
                  (p.brand ?? "").toLowerCase().contains(q) ||
                  (p.category ?? "").toLowerCase().contains(q) ||
                  (p.color ?? "").toLowerCase().contains(q);
              return okBrand && okQ;
            }).toList();

            // sort
            switch (_sort) {
              case SortMode.featured:
                // keep API order
                break;
              case SortMode.priceLow:
                list.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
                break;
              case SortMode.priceHigh:
                list.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
                break;
              case SortMode.nameAZ:
                list.sort((a, b) => (a.name ?? "").compareTo(b.name ?? ""));
                break;
              case SortMode.stockHigh:
                list.sort((a, b) => (b.stock ?? 0).compareTo(a.stock ?? 0));
                break;
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ===== Header =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Search",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _SortMenu(
                            primary: primary,
                            value: _sort,
                            onChanged: (v) => setState(() => _sort = v),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== Search bar =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
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
                        child: TextField(
                          onChanged: (v) => setState(() => _q = v),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText:
                                "Search shoes, brand, category, color...",
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(.35),
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.black.withOpacity(.5),
                            ),
                            suffixIcon: _q.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () =>
                                        setState(() => _q = ""),
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.black.withOpacity(.55),
                                    ),
                                  ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // ===== Brand chips =====
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final b = brands[index];
                          final selected = b == _brand;
                          return InkWell(
                            onTap: () => setState(() => _brand = b),
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
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                    color: selected
                                        ? primary.withOpacity(.18)
                                        : Colors.black.withOpacity(.05),
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

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // ===== Result count =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              list.isEmpty
                                  ? "No results"
                                  : "${list.length} results",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Colors.black.withOpacity(.80),
                              ),
                            ),
                          ),
                          if (_q.isNotEmpty || _brand != "All")
                            TextButton(
                              onPressed: () =>
                                  setState(() {
                                    _q = "";
                                    _brand = "All";
                                  }),
                              child: Text(
                                "Clear",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                  // ===== Grid =====
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: list.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Center(
                                child: Text(
                                  "Try another keyword 🙂",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black.withOpacity(.55),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final p = list[index];
                                return _ProductCard(
                                  product: p,
                                  primary: primary,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DetailScreen(product: p),
                                      ),
                                    );
                                  },
                                );
                              },
                              childCount: list.length,
                            ),
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

// ===== widgets =====

class _SortMenu extends StatelessWidget {
  final Color primary;
  final SortMode value;
  final ValueChanged<SortMode> onChanged;

  const _SortMenu({
    required this.primary,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortMode>(
          value: value,
          icon: Icon(Icons.sort, color: primary),
          onChanged: (v) => onChanged(v!),
          items: const [
            DropdownMenuItem(
              value: SortMode.featured,
              child: Text("Featured"),
            ),
            DropdownMenuItem(
              value: SortMode.priceLow,
              child: Text("Price: Low"),
            ),
            DropdownMenuItem(
              value: SortMode.priceHigh,
              child: Text("Price: High"),
            ),
            DropdownMenuItem(
              value: SortMode.nameAZ,
              child: Text("Name: A-Z"),
            ),
            DropdownMenuItem(
              value: SortMode.stockHigh,
              child: Text("Stock: High"),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _GlassRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassRoundButton({required this.icon, required this.onTap});

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
            child: Icon(icon, color: Colors.black.withOpacity(.75)),
          ),
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
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
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
                    Positioned(
                      top: 8,
                      left: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.18),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.white.withOpacity(.18)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle,
                                    size: 10,
                                    color: inStock
                                        ? Colors.green
                                        : Colors.red),
                                const SizedBox(width: 6),
                                Text(
                                  inStock ? "In Stock" : "Out",
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
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
