import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'checkout_viewmodel.dart';

final checkoutViewModelProvider =
    NotifierProvider<CheckoutViewModel, CheckoutState>(CheckoutViewModel.new);
