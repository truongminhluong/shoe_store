import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository({ProfileService? profileService})
    : _profileService = profileService ?? ProfileService();

  Future<UserModel> getProfile() {
    return _profileService.getProfile();
  }
}
