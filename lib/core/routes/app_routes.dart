import 'package:flutter/material.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/checkout/checkout_screen.dart';
import '../../screens/main/main_screen.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../screens/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String productDetail = '/product-detail';
  static const String checkout = '/checkout';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case productDetail:
        final productId = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId),
        );

      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
