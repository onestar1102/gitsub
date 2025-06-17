// feed 백업용 파일. 이전 HomeScreen 코드에서 피드 관련 부분만 분리
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedBackup extends StatelessWidget {
  const FeedBackup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('백업된 게시글 보기')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feeds')
            .where('type', isEqualTo: 'general')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final docs = snapshot.data!.docs;
          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title'] ?? '제목 없음'),
                subtitle: Text(data['content'] ?? '내용 없음'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
