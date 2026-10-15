import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart_viewmodel.dart';


final cartViewModelProvider = NotifierProvider<CartViewModel, CartState>(
  CartViewModel.new,
);
