import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_viewmodel.dart';

final authViewModelProvider =
NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);