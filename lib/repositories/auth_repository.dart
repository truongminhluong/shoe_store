import '../models/auth_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _authService.login(email: email, password: password);
  }

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    String phone = '',
  }) {
    return _authService.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
    );
  }
}
