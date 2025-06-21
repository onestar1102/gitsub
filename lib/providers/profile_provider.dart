// =============================================================================
// lib/providers/profile_provider.dart
// =============================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileProvider extends ChangeNotifier {
  // ───────── 상태값 ─────────
  String _photoUrl = '';
  String _intro    = '';
  List<String> _links = [];                   // 여러 링크 저장

  // ───────── 게터 ─────────
  String get photoUrl => _photoUrl;
  String get intro    => _intro;
  List<String> get links => _links;

  // Firestore 문서 (profile/admin)
  final _doc = FirebaseFirestore.instance
      .collection('profile')
      .doc('admin');

  ProfileProvider() {
    _load();                                  // 생성 시 Firestore 로딩
  }

  // ───────────────── Firestore → 상태 로드 ─────────────────
  Future<void> _load() async {
    final snap = await _doc.get();
    final data = snap.data() ?? {};

    _photoUrl = data['photoUrl'] ?? '';
    _intro    = data['intro']    ?? '';
    _links    = List<String>.from(data['links'] ?? []);
    notifyListeners();
  }

  // ───────── 소개·링크 동시 업데이트 ─────────
  Future<void> updateIntroAndLinks(String intro, List<String> links) async {
    await _doc.set({'intro': intro, 'links': links}, SetOptions(merge: true));
    _intro  = intro;
    _links  = links;
    notifyListeners();
  }

  // ───────── 소개만 단독 수정 (기존 코드 호환) ─────────
  Future<void> editIntro(String newIntro) async {
    await updateIntroAndLinks(newIntro, _links); // 현재 _links 유지
  }

  // ───────── 링크 리스트만 단독 수정 (필요 시) ─────────
  Future<void> editLinks(List<String> newLinks) async {
    await updateIntroAndLinks(_intro, newLinks);
  }

  // ───────── 프로필 사진 편집 ─────────
  Future<void> editPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final ext   = picked.name.split('.').last;
    final ref   = FirebaseStorage.instance.ref('profile/avatar.$ext');

    // 업로드
    final task = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/$ext'),
    );

    // 완료 후 URL
    final url = await task.ref.getDownloadURL();

    await _doc.set({'photoUrl': url}, SetOptions(merge: true));
    _photoUrl = url;
    notifyListeners();
  }
}
