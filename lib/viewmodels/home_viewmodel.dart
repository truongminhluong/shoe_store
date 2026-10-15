import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoe_store/models/brand_model.dart';

import '../models/product_model.dart';
import 'home_provider.dart';

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState();
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final productRepository = ref.read(productRepositoryProvider);
      final brandRepository = ref.read(brandRepositoryProvider);

      final results = await Future.wait([
        productRepository.getProducts(),
        brandRepository.getBrands(),
      ]);

      final products = results[0] as List<ProductModel>;
      final brands = results[1] as List<BrandModel>;

      state = state.copyWith(isLoading: false, products: products, brands: brands);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

class HomeState {
  final bool isLoading;
  final List<ProductModel> products;
  final List<BrandModel> brands;
  final String? errorMessage;

  const HomeState({
    this.isLoading = false,
    this.products = const [],
    this.brands = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    List<ProductModel>? products,
    List<BrandModel>? brands,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      brands: brands ?? this.brands,
      errorMessage: errorMessage,
    );
  }
}
