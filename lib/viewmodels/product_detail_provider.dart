import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'product_detail_viewmodel.dart';

final productDetailViewModelProvider =
    NotifierProvider<ProductDetailViewModel, ProductDetailState>(
      ProductDetailViewModel.new,
    );
