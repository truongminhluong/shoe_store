import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoe_store/core/storage/auth_storage.dart';

import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends Notifier<AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final AuthResponse response =
      await _authRepository.login(
        email: email,
        password: password,
      );

      await AuthStorage.saveToken(response.token);

      state = state.copyWith(
        isLoading: false,
        user: response.user,
        token: response.token,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String phone = '',
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final AuthResponse response =
      await _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );

      await AuthStorage.saveToken(response.token);

      state = state.copyWith(
        isLoading: false,
        user: response.user,
        token: response.token,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> logout() async {
    await AuthStorage.removeToken();

    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(
      errorMessage: null,
    );
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.token,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }
}