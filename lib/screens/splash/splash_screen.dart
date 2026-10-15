import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../../core/storage/auth_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      await Future.delayed(
        const Duration(seconds: 2),
      );

      final hasToken =
      await AuthStorage.hasToken();

      debugPrint(
        'AUTH CHECK: hasToken = $hasToken',
      );

      if (!mounted) return;

      if (hasToken) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.main,
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
        );
      }
    } catch (e) {
      debugPrint(
        'AUTH CHECK ERROR: $e',
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.login,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Text(
              'ShoeStore',
              style: AppFonts.headingLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Sneakers & Streetwear',
              style: AppFonts.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}