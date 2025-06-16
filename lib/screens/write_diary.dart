import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WriteDiaryScreen extends StatefulWidget {
  const WriteDiaryScreen({super.key});

  @override
  _WriteDiaryScreenState createState() => _WriteDiaryScreenState();
}

class _WriteDiaryScreenState extends State<WriteDiaryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  void _saveDiary() async {
    try {
      await FirebaseFirestore.instance.collection('feeds').add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'tag': _tagController.text.trim(),
        'type': 'diary',
        'timestamp': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일기 저장 완료')),
      );
      Navigator.pop(context); // 작성 후 뒤로 가기
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 일기 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: '내용'),
              maxLines: 5,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagController,
              decoration: const InputDecoration(labelText: '태그'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveDiary,
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
