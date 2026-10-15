import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/brand_repository.dart';
import '../repositories/product_repository.dart';
import 'home_viewmodel.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  return BrandRepository();
});

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
