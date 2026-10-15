import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_viewmodel.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);
