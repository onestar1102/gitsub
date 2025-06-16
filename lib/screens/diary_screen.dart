import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'calendarscreen.dart'; // 캘린더 화면 import
import 'write_diary.dart'; // 일기 작성 화면 import

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일기장')),
      floatingActionButton: FirebaseAuth.instance.currentUser != null
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WriteDiaryScreen()),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: Row(
        children: [
          Container(
            width: 120,
            color: Colors.lightBlue[100],
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CalendarScreen()),
                    );
                  },
                  child: const Text('📅 calendar'),
                ),
                const SizedBox(height: 12),
                const Text('📜 timeline'),
                const SizedBox(height: 12),
                const Text('📷 photocard'),
                const SizedBox(height: 12),
                const Text('💌 guestbook'),
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
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('에러 발생: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('작성된 일기가 없어요.'));
                  }
                  final diariesDocs = List.from(snapshot.data!.docs);
                  diariesDocs.sort((a, b) {
                    final tA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp;
                    final tB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp;
                    return tB.compareTo(tA);
                  });
                  return ListView.builder(
                    itemCount: diariesDocs.length,
                    itemBuilder: (context, index) {
                      final data = diariesDocs[index].data() as Map<String, dynamic>;

                      // 안전하게 timestamp 파싱
                      final rawTimestamp = data['timestamp'];
                      final parsedDate = rawTimestamp is Timestamp
                          ? rawTimestamp.toDate()
                          : DateTime.tryParse(rawTimestamp.toString()) ?? DateTime.now();

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          title: Text(
                            data['title'] ?? '제목 없음',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['content'] ?? '내용 없음',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text('📅 ${parsedDate.toLocal()}'),
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
