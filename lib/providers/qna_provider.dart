// =============================================================================
// lib/providers/qna_provider.dart
// =============================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String id;
  final String text;
  final bool isAdmin;
  final DateTime date;
  Message(this.id, this.text, this.isAdmin, this.date);
}

class QnaProvider extends ChangeNotifier {
  final _col = FirebaseFirestore.instance.collection('qna');
  List<Message> messages = [];

  QnaProvider() {
    _listen();
  }

  // lib/providers/qna_provider.dart  _listen() 부분 교체
  void _listen() {
    _col.orderBy('time').snapshots().listen((snap) {
      messages = snap.docs.map((d) {
        final rawTime = d['time'];
        DateTime when;
        if (rawTime is Timestamp) {
          when = rawTime.toDate();
        } else if (rawTime is String) {
          // ISO8601 또는 빈 문자열일 수 있음
          when = DateTime.tryParse(rawTime) ?? DateTime.now();
        } else {
          when = DateTime.now();
        }
        final rawIsAdmin = d['isAdmin'];
        final bool isAdminVal =
        rawIsAdmin is bool ? rawIsAdmin : (rawIsAdmin.toString() == 'true');

        return Message(
          d.id,
          d['text'] as String,
          isAdminVal,
          when,
        );
      }).toList();
      notifyListeners();
    });
  }

  Future<void> send(String text, {required bool isAdmin}) async {
    await _col.add({
      'text': text,
      'isAdmin': isAdmin,
      'time': FieldValue.serverTimestamp(),
    });
  }
}