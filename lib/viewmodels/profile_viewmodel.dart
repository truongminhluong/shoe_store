import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/profile_repository.dart';

class ProfileViewModel extends Notifier<ProfileState> {
  final ProfileRepository _profileRepository = ProfileRepository();

  @override
  ProfileState build() {
    return const ProfileState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final UserModel user = await _profileRepository.getProfile();

      state = state.copyWith(isLoading: false, user: user, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}

class ProfileState {
  final bool isLoading;
  final UserModel? user;
  final String? errorMessage;

  const ProfileState({this.isLoading = false, this.user, this.errorMessage});

  ProfileState copyWith({
    bool? isLoading,
    UserModel? user,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}
