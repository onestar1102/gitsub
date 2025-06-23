// =============================================================================
// lib/widgets/posts_section.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/write_post_screen.dart';
import 'post_detail_dialog.dart';                // ← 공통 다이얼로그

class PostsSection extends StatelessWidget {
  const PostsSection({super.key});

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
                title   : Text(p.title),
                subtitle: Text('${p.date.year}-${p.date.month}-${p.date.day}'),
                onTap   : () => PostDetailDialog.show(context, p), // ★ 변경
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
