// =============================================================================
// lib/widgets/calendar_section.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/post_provider.dart';
import 'post_detail_dialog.dart';   // 공통 상세보기 다이얼로그

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

    /* ───── 날짜별 포스트 매핑 ───── */
    final byDate = <DateTime, List<Post>>{};
    for (final p in postsProv.posts) {
      final key = DateTime(p.date.year, p.date.month, p.date.day);
      byDate.putIfAbsent(key, () => []).add(p);
    }
    List<Post> _events(DateTime d) =>
        byDate[DateTime(d.year, d.month, d.day)] ?? [];

    return TableCalendar<Post>(
      firstDay      : DateTime.utc(2020, 1, 1),
      lastDay       : DateTime.utc(2030, 12, 31),
      focusedDay    : _focusedDay,
      calendarFormat: CalendarFormat.month,

      /* ───── 사이즈 · 스타일 ───── */
      rowHeight       : 38,
      daysOfWeekHeight: 28,
      headerStyle     : const HeaderStyle(
        titleCentered      : true,
        formatButtonVisible: false,
      ),
      calendarStyle: const CalendarStyle(
        defaultTextStyle : TextStyle(fontSize: 14),
        weekendTextStyle : TextStyle(fontSize: 14),
        outsideTextStyle : TextStyle(fontSize: 14, color: Colors.grey),
      ),

      selectedDayPredicate: (day) =>
      _selectedDay != null &&
          day.year  == _selectedDay!.year &&
          day.month == _selectedDay!.month &&
          day.day   == _selectedDay!.day,

      eventLoader : _events,

      /* ───── 날짜 클릭 ───── */
      onDaySelected: (sel, foc) {
        setState(() {
          _selectedDay = sel;
          _focusedDay  = foc;
        });

        final list = _events(sel);
        if (list.isEmpty) return;

        list.length == 1
            ? PostDetailDialog.show(context, list.first)   // 하나면 곧바로 상세
            : _showPostsOfDay(context, list);              // 여러 개면 목록
      },
    );
  }

  /* ───────────────────────
     해당 날짜의 “제목 목록” 다이얼로그
  ─────────────────────── */
  void _showPostsOfDay(BuildContext ctx, List<Post> posts) {
    final d = _selectedDay!;
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('${d.year}-${d.month}-${d.day} 게시글'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: posts
                .map((p) => ListTile(
              title: Text(p.title),
              onTap: () {
                Navigator.pop(ctx);                // 목록 닫기
                PostDetailDialog.show(ctx, p);     // 공통 상세 열기
              },
            ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('닫기')),
        ],
      ),
    );
  }
}
