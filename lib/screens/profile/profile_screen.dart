import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/auth_provider.dart';
import '../../viewmodels/profile_provider.dart';
import '../../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(profileViewModelProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tài khoản')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.errorMessage != null) {
      return _buildError(state.errorMessage!);
    }

    final user = state.user;

    if (user == null) {
      return const Center(child: Text('Không có thông tin tài khoản'));
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref.read(profileViewModelProvider.notifier).loadProfile();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildProfileHeader(user),

          const SizedBox(height: 24),

          _buildSectionTitle('Tài khoản'),

          const SizedBox(height: 10),

          _buildMenuCard(
            children: [
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                subtitle: 'Xem và chỉnh sửa thông tin',
                onTap: () {
                  // TODO: Edit Profile
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'Địa chỉ giao hàng',
                subtitle: 'Quản lý địa chỉ nhận hàng',
                onTap: () {
                  // TODO: Address
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.favorite_border,
                title: 'Sản phẩm yêu thích',
                subtitle: 'Danh sách sản phẩm đã lưu',
                onTap: () {
                  // TODO: Favorite
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Mua sắm'),

          const SizedBox(height: 10),

          _buildMenuCard(
            children: [
              _buildMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Đơn hàng của tôi',
                subtitle: 'Theo dõi và quản lý đơn hàng',
                onTap: () {
                  // TODO: Orders
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.confirmation_number_outlined,
                title: 'Voucher',
                subtitle: 'Xem voucher và ưu đãi',
                onTap: () {
                  // TODO: Voucher
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.notifications_none,
                title: 'Thông báo',
                subtitle: 'Xem thông báo mới',
                onTap: () {
                  // TODO: Notifications
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Cài đặt'),

          const SizedBox(height: 10),

          _buildMenuCard(
            children: [
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Cài đặt',
                subtitle: 'Cài đặt ứng dụng',
                onTap: () {
                  // TODO: Settings
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Trợ giúp',
                subtitle: 'Câu hỏi thường gặp và hỗ trợ',
                onTap: () {
                  // TODO: Help
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'Về ShoeStore',
                subtitle: 'Thông tin ứng dụng',
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildLogoutButton(),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'ShoeStore v1.0.0',
              style: AppFonts.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildAvatar(user.avatar),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.title,
                ),

                const SizedBox(height: 5),

                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body.copyWith(color: AppColors.textSecondary),
                ),

                if (user.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: AppFonts.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatar) {
    if (avatar.isEmpty) {
      return const CircleAvatar(
        radius: 35,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person, size: 36, color: AppColors.white),
      );
    }

    return CircleAvatar(radius: 35, backgroundImage: NetworkImage(avatar));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 21),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppFonts.bodyMedium),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 72,
      endIndent: 16,
      color: AppColors.border,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: const Text(
          'Đăng xuất',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await ref.read(authViewModelProvider.notifier).logout();

                if (!mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'ShoeStore',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.shopping_bag_outlined, size: 36),
      children: const [
        Text(
          'Ứng dụng thương mại điện tử '
          'sneakers và streetwear.',
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),

            const SizedBox(height: 16),

            Text(message, textAlign: TextAlign.center),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                ref.read(profileViewModelProvider.notifier).loadProfile();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
