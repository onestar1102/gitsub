// =============================================================================
// lib/screens/write_post_screen.dart
// =============================================================================
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../providers/post_provider.dart';

class WritePostScreen extends StatefulWidget {
  const WritePostScreen({super.key});

  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final _titleCtrl   = TextEditingController();
  final _contentCtrl = TextEditingController();

  XFile?     _picked;      // 선택한 이미지 파일
  Uint8List? _preview;     // 미리보기용 바이트

  // ───────── 이미지 선택 ─────────
  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final bytes = await img.readAsBytes();
    setState(() {
      _picked  = img;
      _preview = bytes;
    });
  }

  // ───────── 저장 ─────────
  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final body  = _contentCtrl.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('제목과 내용을 모두 입력하세요')));
      return;
    }

    String? imageUrl;
    if (_picked != null) {
      final ext  = _picked!.name.split('.').last;
      final path = 'posts/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final ref  = FirebaseStorage.instance.ref(path);

      final task = await ref.putData(
        await _picked!.readAsBytes(),
        SettableMetadata(contentType: 'image/$ext'),
      );
      imageUrl = await task.ref.getDownloadURL();
    }

    await context
        .read<PostProvider>()
        .addPost(title, body, imageUrl: imageUrl);   // ← imageUrl 전달

    if (mounted) Navigator.pop(context);
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 게시글')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // 폭 고정
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // ───── 이미지 미리보기 ─────
                if (_preview != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _preview!,
                      height: 160,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),

                // ───── 이미지 선택 버튼 ─────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: Text(_picked == null ? '이미지 첨부' : '이미지 변경'),
                    onPressed: _pickImage,
                  ),
                ),

                Expanded(
                  child: TextField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(
                      labelText: '내용',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    expands: true,
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('저장'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
