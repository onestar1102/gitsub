// =============================================================================
// lib/providers/post_provider.dart
// =============================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String? imageUrl;                // ★ 첨부 이미지 URL (nullable)

  Post(
      this.id,
      this.title,
      this.content,
      this.date, {
        this.imageUrl,
      });
}

class PostProvider extends ChangeNotifier {
  final _col = FirebaseFirestore.instance.collection('posts');
  List<Post> posts = [];

  PostProvider() {
    _load();
  }

  // ───────── Firestore → 상태 로드 ─────────
  Future<void> _load() async {
    final snaps = await _col.orderBy('timestamp', descending: true).get();

    posts = snaps.docs.map((d) {
      final data = d.data();
      return Post(
        d.id,
        data['title'] as String,
        data['content'] as String,
        (data['timestamp'] as Timestamp).toDate(),
        imageUrl: data['imageUrl'] as String?,           // ★
      );
    }).toList();

    notifyListeners();
  }
  // lib/providers/post_provider.dart  (추가-수정) 삭제 기능 추가
  Future<void> deletePost(Post post) async {
    await _col.doc(post.id).delete();      // Firestore
    posts.removeWhere((e) => e.id == post.id);
    notifyListeners();
  }

  // ───────── 새 게시글 추가 ─────────
  Future<void> addPost(
      String title,
      String content, {
        String? imageUrl,                                  // ★
      }) async {
    final doc = await _col.add({
      'title'     : title,
      'content'   : content,
      'imageUrl'  : imageUrl,                          // ★ Firestore 저장
      'timestamp' : FieldValue.serverTimestamp(),
    });

    posts.insert(
      0,
      Post(
        doc.id,
        title,
        content,
        DateTime.now(),
        imageUrl: imageUrl,                            // ★
      ),
    );
    notifyListeners();
  }
}
