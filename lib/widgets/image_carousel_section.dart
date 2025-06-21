// =============================================================================
// lib/widgets/image_carousel_section.dart
// (박스 크기 = 높이 300, 가변 가로; 이미지가 박스 안에 꽉 차게)
// =============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carousel_provider.dart';
import '../providers/auth_provider.dart';

class ImageCarouselSection extends StatefulWidget {
  const ImageCarouselSection({super.key});

  @override
  State<ImageCarouselSection> createState() => _ImageCarouselSectionState();
}

class _ImageCarouselSectionState extends State<ImageCarouselSection> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final carousel = context.watch<CarouselProvider>();
    final isAdmin  = context.watch<AuthProvider>().isAdmin;

    // ───────── 이미지가 없을 때 ─────────
    if (carousel.images.isEmpty) {
      return Center(
        child: isAdmin
            ? TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('이미지 추가'),
          onPressed: carousel.addImage,
        )
            : const Text('이미지가 없습니다'),
      );
    }

    // ───────── 캐러셀 ─────────
    return SizedBox(                      // 높이 고정(= 박스 높이)
      height: 300,
      child: Stack(
        children: [
          // ───── PageView ─────
          PageView.builder(
            controller: _pageController,
            itemCount: carousel.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.black,
                  child: FittedBox(          // 이미지가 박스를 넘지 않도록
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: Image.network(
                      carousel.images[i]['url']!,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ───── 좌/우 화살표 ─────
          _navButton(
            left: true,
            onTap: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            ),
          ),
          _navButton(
            left: false,
            onTap: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            ),
          ),

          // ───── 삭제 버튼 ─────
          if (isAdmin)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => carousel.deleteImage(
                  carousel.images[_index]['id']!,
                  carousel.images[_index]['url']!,
                ),
              ),
            ),

          // ───── 추가 FAB ─────
          if (isAdmin)
            Positioned(
              bottom: 12,
              right: 12,
              child: FloatingActionButton(
                heroTag: 'add-image-fab',
                mini: true,
                backgroundColor: Colors.white,       // ← 흰 배경
                foregroundColor: Colors.black87,     // 아이콘 색 (선택)
                onPressed: carousel.addImage,
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }

  // ───────── 좌/우 이동 버튼 헬퍼 ─────────
  Widget _navButton({required bool left, required VoidCallback onTap}) {
    return Positioned(
      left: left ? 4 : null,
      right: left ? null : 4,
      top: 0,
      bottom: 0,
      child: IconButton(
        icon: Icon(
          left ? Icons.chevron_left : Icons.chevron_right,
          size: 32,
          color: Colors.white70,
        ),
        onPressed: onTap,
      ),
    );
  }
}
