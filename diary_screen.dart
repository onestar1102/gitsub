import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_homepage/firebase_options.dart';

import 'home_screen.dart';
import 'tag_search_screen.dart';
import 'write_screen.dart';
import 'diary_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'write_diary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyBlogApp());
}

class MyBlogApp extends StatelessWidget {
  const MyBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yesol Blog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.lightBlue[50],
        primarySwatch: Colors.lightBlue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// screens/diary_screen.dart

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일기장')),
      body: Row(
        children: [
          Container(
            width: 120,
            color: Colors.lightBlue[100],
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('📅 calendar'),
                SizedBox(height: 12),
                Text('📜 timeline'),
                SizedBox(height: 12),
                Text('📷 photocard'),
                SizedBox(height: 12),
                Text('💌 guestbook'),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('feeds')
                    .where('type', isEqualTo: 'diary')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('작성된 일기가 없어요.'));
                  }

                  final diaries = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: diaries.length,
                    itemBuilder: (context, index) {
                      final data = diaries[index].data() as Map<String, dynamic>;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          title: Text(data['title'] ?? '제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['content'] ?? '내용 없음', maxLines: 3, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('📅 ${(data['timestamp'] as Timestamp).toDate().toLocal()}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}