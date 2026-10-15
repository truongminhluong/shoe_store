import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showMessage('Vui lòng nhập email');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Vui lòng nhập mật khẩu');
      return;
    }

    await ref
        .read(authViewModelProvider.notifier)
        .login(email: email, password: password);

    if (!mounted) return;

    final state = ref.read(authViewModelProvider);

    if (state.user != null && state.token != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (state.errorMessage != null) {
      _showMessage(state.errorMessage!);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo
              const Center(
                child: Text('ShoeStore', style: AppFonts.headingLarge),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text('Sneakers & Streetwear', style: AppFonts.body),
              ),

              const SizedBox(height: 48),

              const Text('Đăng nhập', style: AppFonts.headingMedium),

              const SizedBox(height: 8),

              const Text('Đăng nhập để tiếp tục mua sắm', style: AppFonts.body),

              const SizedBox(height: 32),

              // Email
              const Text('Email', style: AppFonts.bodyMedium),

              const SizedBox(height: 8),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Nhập email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 20),

              // Password
              const Text('Mật khẩu', style: AppFonts.bodyMedium),

              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Forgot password
                  },
                  child: const Text('Quên mật khẩu?'),
                ),
              ),

              const SizedBox(height: 16),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text('Đăng ký'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
