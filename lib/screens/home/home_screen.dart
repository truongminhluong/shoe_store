import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../viewmodels/home_provider.dart';
import '../../widgets/home/banner_slider.dart';
import '../../widgets/home/brand_section.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/product_section.dart';
import '../../widgets/home/search_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onCartPressed;

  const HomeScreen({super.key, this.onCartPressed});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _productsKey = GlobalKey();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(homeViewModelProvider.notifier).loadHomeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return products;

    return products.where((product) {
      final name = product.name.toLowerCase();
      final brand = (product.brand?.name ?? '').toLowerCase();
      return name.contains(query) || brand.contains(query);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _scrollToProducts() {
    final productContext = _productsKey.currentContext;
    if (productContext == null) return;
    Scrollable.ensureVisible(
      productContext,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: HomeHeader(onCartPressed: widget.onCartPressed),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: HomeSearchBar(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      onClear: _clearSearch,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: BannerSlider(onExplorePressed: _scrollToProducts),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: BrandSection(brands: state.brands),
                  ),
                ),
                SliverPadding(
                  key: _productsKey,
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  sliver: ProductSection(
                    products: _filterProducts(state.products),
                    isLoading: state.isLoading,
                    errorMessage: state.errorMessage,
                    searchQuery: _searchQuery,
                    onClearSearch: _clearSearch,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
