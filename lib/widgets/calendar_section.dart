// =============================================================================
// lib/widgets/calendar_section.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/post_provider.dart';

class CalendarSection extends StatefulWidget {
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final postsProv = context.watch<PostProvider>();

    // 날짜별 포스트 매핑
    final map = <DateTime, List<Post>>{};
    for (final p in postsProv.posts) {
      final key = DateTime(p.date.year, p.date.month, p.date.day);
      map.putIfAbsent(key, () => []).add(p);
    }
    List<Post> _events(DateTime d) =>
        map[DateTime(d.year, d.month, d.day)] ?? [];

    return TableCalendar<Post>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay:  DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,

      // ───── 표시 크기 조정 ─────
      rowHeight: 38,             // 셀 높이
      daysOfWeekHeight: 28,      // 요일 행 높이

      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),

      calendarStyle: const CalendarStyle(
        defaultTextStyle: TextStyle(fontSize: 14),
        weekendTextStyle: TextStyle(fontSize: 14),
        outsideTextStyle: TextStyle(fontSize: 14, color: Colors.grey),
      ),

      selectedDayPredicate: (day) =>
      _selectedDay != null &&
          day.year  == _selectedDay!.year &&
          day.month == _selectedDay!.month &&
          day.day   == _selectedDay!.day,

      eventLoader: _events,

      onDaySelected: (sel, foc) {
        setState(() {
          _selectedDay = sel;
          _focusedDay  = foc;
        });
        final list = _events(sel);
        if (list.isNotEmpty) _detail(context, list.first);
      },
    );
  }

  void _detail(BuildContext ctx, Post p) => showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: Text(p.title),
      content: SingleChildScrollView(child: Text(p.content)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}
