import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoe_store/viewmodels/review_viewmodel.dart';

final reviewViewModelProvider = NotifierProvider<ReviewViewmodel, ReviewState>(
  ReviewViewmodel.new,
);
