import '../core/network/api_client.dart';
import '../models/user_model.dart';

class ProfileService {
  Future<UserModel> getProfile() async {
    final response = await ApiClient.get(
      '/users/profile',
    );

    return UserModel.fromJson(
      response['data'],
    );
  }
}