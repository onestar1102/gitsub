import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

import 'diary_screen.dart';
import 'tag_search_screen.dart';
import 'write_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  String? _role;
  bool _isUploading = false;

  final List<String> adminEmails = [
    'yesol.dev@gmail.com',
    'phbyul1102@gmail.com'
  ];

  Future<void> _signInWithGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final userCredential = await FirebaseAuth.instance.signInWithPopup(authProvider);
        final user = userCredential.user;
        if (user != null) {
          final role = adminEmails.contains(user.email) ? 'admin' : 'user';
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'role': role,
          }, SetOptions(merge: true));
          setState(() {
            _user = user;
            _role = role;
          });
        }
      } catch (e) {
        debugPrint('Web sign-in error: $e');
      }
    } else {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final role = adminEmails.contains(user.email) ? 'admin' : 'user';
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'role': role,
        }, SetOptions(merge: true));
        setState(() {
          _user = user;
          _role = role;
        });
      }
    }
  }

  void _signOut() {
    FirebaseAuth.instance.signOut();
    setState(() {
      _user = null;
      _role = null;
    });
  }

  Future<void> _changeProfileImage() async {
    if (_user == null || _role != 'admin') return;

    setState(() => _isUploading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        Uint8List imageBytes = result.files.single.bytes!;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${_user!.uid}.jpg');
        await storageRef.putData(imageBytes);

        final downloadUrl = await storageRef.getDownloadURL();
        final uniqueUrl = '$downloadUrl?cachebust=${DateTime.now().millisecondsSinceEpoch}';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .update({'profileImageUrl': downloadUrl});

        setState(() {});
      }
    } catch (e) {
      debugPrint("이미지 업로드 실패: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예솔 블로그'),
        centerTitle: true,
        actions: [
          if (_user != null) ...[
            IconButton(
              icon: const Icon(Icons.book),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryScreen()));
              },
            ),
            if (_role == 'admin') ...[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TagSearchScreen()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WriteScreen()));
                },
              ),
            ],
          ],
          if (_user == null)
            TextButton(
              onPressed: _signInWithGoogle,
              child: const Text('로그인', style: TextStyle(color: Colors.black)),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(_user!.displayName ?? '', style: const TextStyle(color: Colors.white)),
              ),
            ),
            TextButton(
              onPressed: _signOut,
              child: const Text('로그아웃', style: TextStyle(color: Colors.black)),
            ),
          ],
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: _user != null
                      ? FirebaseFirestore.instance.collection('users').doc(_user!.uid).snapshots()
                      : const Stream.empty(),
                  builder: (context, snapshot) {
                    String? imageUrl;
                    if (snapshot.hasData) {
                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      imageUrl = data?['profileImageUrl'];
                    }

                    return _isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : GestureDetector(
                      onTap: _role == 'admin' ? _changeProfileImage : null,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl)
                            : const AssetImage('assets/profile.jpg') as ImageProvider,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('예솔', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Flutter로 만든 감성 블로그입니다.', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                const Text('📮 yesol.dev@gmail.com'),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('feeds').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('아직 피드가 없어요.'));
                }

                final feeds = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: feeds.length,
                  itemBuilder: (context, index) {
                    final data = feeds[index].data() as Map<String, dynamic>;
                    final feedId = feeds[index].id;
                    final commentController = TextEditingController();

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(data['title'] ?? '제목 없음'),
                              subtitle: Text(data['content'] ?? '내용 없음'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('feeds')
                                        .doc(feedId)
                                        .collection('likes')
                                        .snapshots(),
                                    builder: (context, likeSnap) {
                                      final likeCount = likeSnap.data?.docs.length ?? 0;
                                      final hasLiked = likeSnap.data?.docs.any((doc) => doc.id == _user?.uid) ?? false;
                                      return Row(
                                        children: [
                                          Text('$likeCount'),
                                          IconButton(
                                            icon: Icon(
                                              hasLiked ? Icons.favorite : Icons.favorite_border,
                                              color: hasLiked ? Colors.red : null,
                                            ),
                                            onPressed: _user == null
                                                ? null
                                                : () async {
                                              final likeRef = FirebaseFirestore.instance
                                                  .collection('feeds')
                                                  .doc(feedId)
                                                  .collection('likes')
                                                  .doc(_user!.uid);
                                              if (hasLiked) {
                                                await likeRef.delete();
                                              } else {
                                                await likeRef.set({'likedAt': Timestamp.now()});
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  if (_role == 'admin')
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('게시글 삭제'),
                                            content: const Text('정말 이 게시글을 삭제하시겠습니까?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await FirebaseFirestore.instance.collection('feeds').doc(feedId).delete();
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ),
                            const Divider(),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('feeds')
                                  .doc(feedId)
                                  .collection('comments')
                                  .orderBy('timestamp')
                                  .snapshots(),
                              builder: (context, commentSnap) {
                                if (!commentSnap.hasData) return const SizedBox();
                                final comments = commentSnap.data!.docs;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: comments.map((comment) {
                                    final author = comment['author'] ?? '익명';
                                    final text = comment['text'] ?? '';
                                    final commentId = comment.id;
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Text("$author: $text"),
                                          ),
                                        ),
                                        if (_role == 'admin')
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 18),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('feeds')
                                                  .doc(feedId)
                                                  .collection('comments')
                                                  .doc(commentId)
                                                  .delete();
                                            },
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            if (_user != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: commentController,
                                        decoration: const InputDecoration(
                                          hintText: '댓글을 입력하세요',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        onSubmitted: (text) async {
                                          if (text.trim().isEmpty) return;
                                          await FirebaseFirestore.instance
                                              .collection('feeds')
                                              .doc(feedId)
                                              .collection('comments')
                                              .add({
                                            'author': _user!.displayName ?? '익명',
                                            'text': text.trim(),
                                            'timestamp': Timestamp.now(),
                                          });
                                          commentController.clear();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.send),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
