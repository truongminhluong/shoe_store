import '../core/network/api_client.dart';
import '../models/auth_response.dart';

class AuthService {
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/users/login',
      body: {'email': email, 'password': password},
    );

    return AuthResponse.fromJson(response['data']);
  }

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    String phone = '',
  }) async {
    final response = await ApiClient.post(
      '/users/register',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      },
    );

    return AuthResponse.fromJson(response['data']);
  }
}
