// =============================================================================
// lib/widgets/posts_section.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/write_post_screen.dart';

class PostsSection extends StatelessWidget {
  const PostsSection({super.key});

  static const double _previewH = 300;                          // 이미지 고정 높이
  static const _border = BorderSide(color: Colors.grey, width: 1.2);

  @override
  Widget build(BuildContext context) {
    final postsProv = context.watch<PostProvider>();
    final isAdmin   = context.watch<AuthProvider>().isAdmin;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade600, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───── 헤더 ─────
          Row(
            children: [
              const Text('게시글',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WritePostScreen()),
                  ),
                ),
            ],
          ),

          // ───── 목록 (제목·날짜만) ─────
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('목록 보기'),
            children: postsProv.posts.map((p) {
              return ListTile(
                title: Text(p.title),
                subtitle:
                Text('${p.date.year}-${p.date.month}-${p.date.day}'),
                onTap: () => _showPostDetail(context, p),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── 상세 다이얼로그 ───────────────────────
  void _showPostDetail(BuildContext context, Post p) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 700,
            minWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───── 제목 박스 ─────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: _border.color, width: _border.width),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Text(
                    p.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ───── 이미지 (Letter-Box) ─────
                if (p.imageUrl != null)
                  GestureDetector(
                    onTap: () => _showFullImage(context, p.imageUrl!),
                    child: Container(
                      height: _previewH,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          p.imageUrl!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                if (p.imageUrl != null) const SizedBox(height: 20),

                // ───── 본문 박스 (제목과 같은 전폭) ─────
                Expanded(
                  child: Container(
                    width: double.infinity,                   // ✦ 전폭
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: _border.color, width: _border.width),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    // ▸ 스크롤은 컨테이너 내부에서
                    child: SingleChildScrollView(
                      child: Text(
                        p.content,
                        style: const TextStyle(fontSize: 18, height: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── 원본 이미지 확대 ───────────────────────
  void _showFullImage(BuildContext ctx, String url) {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          minScale: .5,
          maxScale: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
