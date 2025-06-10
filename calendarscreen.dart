import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
// flutter pub add firebase_core firebase_firestore 패치지 추가

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<Map<String, dynamic>> diaries = [
    {
      'title': '첫 번째 일기',
      'content': '오늘은 정말 좋은 날이었어!',
      'timestamp': DateTime(2025, 6, 9),
    },
    {
      'title': '두 번째 일기',
      'content': '비가 왔지만 마음은 맑음.',
      'timestamp': DateTime(2025, 6, 10),
    },
    {
      'title': '세 번째 일기',
      'content': '운동 후 기분 최고!',
      'timestamp': DateTime(2025, 6, 11),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 선택한 날짜에 해당하는 일기 필터링
    List<Map<String, dynamic>> filteredDiaries = diaries.where((diary) {
      DateTime diaryDate = diary['timestamp'];
      return diaryDate.year == _selectedDay.year &&
          diaryDate.month == _selectedDay.month &&
          diaryDate.day == _selectedDay.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('캘린더')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2050),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(formatButtonVisible: false),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDiaries.length,
              itemBuilder: (context, index) {
                final diary = filteredDiaries[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(diary['title']),
                    subtitle: Text(diary['content']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
