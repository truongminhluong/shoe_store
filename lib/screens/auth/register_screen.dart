import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullNameController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    final fullName = _fullNameController.text.trim();

    final email = _emailController.text.trim();

    final password = _passwordController.text;

    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty) {
      _showMessage('Vui lòng nhập họ và tên');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Vui lòng nhập email');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Vui lòng nhập mật khẩu');
      return;
    }

    if (password.length < 6) {
      _showMessage('Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage('Vui lòng xác nhận mật khẩu');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Mật khẩu xác nhận không khớp');
      return;
    }

    await ref
        .read(authViewModelProvider.notifier)
        .register(fullName: fullName, email: email, password: password);

    if (!mounted) return;

    final state = ref.read(authViewModelProvider);

    if (state.user != null && state.token != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (route) => false,
      );
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
      appBar: AppBar(title: const Text('Đăng ký')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              const Center(
                child: Text('ShoeStore', style: AppFonts.headingLarge),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text('Tạo tài khoản mới', style: AppFonts.body),
              ),

              const SizedBox(height: 40),

              const Text('Họ và tên', style: AppFonts.bodyMedium),

              const SizedBox(height: 8),

              TextField(
                controller: _fullNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Nhập họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 20),

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

              const Text('Mật khẩu', style: AppFonts.bodyMedium),

              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.next,
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

              const SizedBox(height: 20),

              const Text('Xác nhận mật khẩu', style: AppFonts.bodyMedium),

              const SizedBox(height: 8),

              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _register(),
                decoration: InputDecoration(
                  hintText: 'Nhập lại mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
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
                          'Đăng ký',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Đăng nhập'),
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
