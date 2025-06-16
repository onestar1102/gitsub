import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_homepage/firebase_options.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_homepage/screens/home_screen.dart';

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

// screens/tag_search_screen.dart

class TagSearchScreen extends StatefulWidget {
  const TagSearchScreen({super.key});

  @override
  State<TagSearchScreen> createState() => _TagSearchScreenState();
}

class _TagSearchScreenState extends State<TagSearchScreen> {
  final TextEditingController _tagController = TextEditingController();
  String? _searchTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('태그 검색')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(labelText: '태그 입력 (예: #일상)'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _searchTag = _tagController.text.trim();
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
            if (_searchTag != null && _searchTag!.isNotEmpty)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('feeds')
                      .where('tag', isEqualTo: _searchTag)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('에러 발생: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('해당 태그의 피드가 없어요.'));
                    }
                    final results = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final data = results[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: ListTile(
                            title: Text(data['title'] ?? '제목 없음'),
                            subtitle: Text(data['content'] ?? '내용 없음'),
                            trailing: Text(data['tag'] ?? ''),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
