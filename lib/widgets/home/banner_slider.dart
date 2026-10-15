import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class BannerSlider extends StatefulWidget {
  final VoidCallback onExplorePressed;

  const BannerSlider({super.key, required this.onExplorePressed});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _banners = [
    (
      image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
      title: 'Mỗi bước,\nmột dấu ấn.',
    ),
    (
      image: 'https://images.unsplash.com/photo-1552346154-21d32810aba3',
      title: 'Sneaker cho\nchất riêng của bạn.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth >= 600 ? 300.0 : 260.0;
        return Column(
          children: [
            SizedBox(
              height: height,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _banners.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final banner = _banners[index];
                  return _BannerItem(
                    imageUrl: banner.image,
                    title: banner.title,
                    height: height,
                    onExplorePressed: widget.onExplorePressed,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Trang ${_currentPage + 1} trên ${_banners.length}',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_banners.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BannerItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double height;
  final VoidCallback onExplorePressed;

  const _BannerItem({
    required this.imageUrl,
    required this.title,
    required this.height,
    required this.onExplorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = height >= 300 ? 36.0 : 30.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            errorBuilder: (context, error, stackTrace) =>
                const ColoredBox(color: AppColors.primary),
          ),
          const ColoredBox(color: Color(0x6608172F)),
          Padding(
            padding: EdgeInsets.all(height >= 300 ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    height: 1.05,
                    letterSpacing: -0.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: onExplorePressed,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Khám phá hàng mới'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
