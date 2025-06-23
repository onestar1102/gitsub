// =============================================================================
// lib/widgets/post_detail_dialog.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';             // ★
import '../providers/post_provider.dart';

class PostDetailDialog {
  /* 외부에서 호출 */
  static void show(BuildContext ctx, Post post) {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => _PostDialogBg(child: _PostDialogBody(post: post)),
    );
  }
}

/* 1) 라운드 + 연보라 배경 */
class _PostDialogBg extends StatelessWidget {
  const _PostDialogBg({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding   : const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      backgroundColor: Colors.purple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: child,
    );
  }
}

/* 2) 실제 내용 — Post 주입 */
class _PostDialogBody extends StatelessWidget {
  const _PostDialogBody({required this.post});
  final Post post;

  static const _border   = BorderSide(color: Colors.grey, width: 1.2);
  static const _previewH = 300.0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth : 700,
        minWidth : 500,
        maxHeight: MediaQuery.of(context).size.height * .8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /* ───── 우측 상단 동작 버튼 ───── */             // ★
            Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(                       // 삭제
                    tooltip: '삭제',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('삭제 확인'),
                          content: const Text('정말 이 게시글을 삭제하시겠어요?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );
                      if (ok != true) return;

                      await context.read<PostProvider>().deletePost(post); // ★
                      if (context.mounted) Navigator.pop(context);         // 상세 닫기
                    },
                  ),
                  IconButton(                       // 닫기
                    tooltip: '닫기',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),             // ★ 버튼과 제목 사이 여백

            /* ───── 제목 박스 ───── */
            Container(
              width : double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              decoration: BoxDecoration(
                border      : Border.all(color: _border.color, width: _border.width),
                borderRadius: BorderRadius.circular(12),
                color       : Colors.white,
              ),
              child: Text(
                post.title,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            /* ───── 이미지 (있을 때만) ───── */
            if (post.imageUrl != null) ...[
              GestureDetector(
                onTap: () => _showFullImage(context, post.imageUrl!),
                child: Container(
                  height: _previewH,
                  width : double.infinity,
                  decoration: BoxDecoration(
                    color       : Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(post.imageUrl!, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            /* ───── 본문 박스 ───── */
            Expanded(
              child: Container(
                width : double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border      : Border.all(color: _border.color, width: _border.width),
                  borderRadius: BorderRadius.circular(12),
                  color       : Colors.white,
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Text(post.content,
                        style: const TextStyle(fontSize: 18, height: 1.5)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* 확대 보기 */
  void _showFullImage(BuildContext ctx, String url) {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding   : const EdgeInsets.all(16),
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
