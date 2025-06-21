// =============================================================================
// lib/providers/auth_provider.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  // ----------------------------------------------------------------- 상수
  static const List<String> _adminEmails = [ // 필요 없으면 지우거나 추가
    'phbyul1102@gmail.com',
    'test@example.com',
    'yesol@gmail.com'
  ];
  static const _kPrefKey = 'is_admin';

  // ----------------------------------------------------------------- 상태
  bool _isAdmin = false;
  bool _initialized = false;

  bool get isAdmin       => _isAdmin;
  bool get isInitialized => _initialized;

  AuthProvider() {
    _restore();
  }

  // --------------------------------------------------------------- 로그인
  Future<bool> login(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      _isAdmin = _adminEmails.contains(email);
      await _save(_isAdmin);
      _initialized = true;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // --------------------------------------------------------------- 로그아웃
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _isAdmin = false;
    await _save(false);
    notifyListeners();
  }

  // ------------------------------------------------------- Prefs 저장·복원
  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAdmin = prefs.getBool(_kPrefKey) ?? false;

    final currentUser = FirebaseAuth.instance.currentUser;
    _isAdmin = savedAdmin && currentUser != null &&
        _adminEmails.contains(currentUser.email);
    _initialized = true;
    notifyListeners();
  }

  Future<void> _save(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefKey, value);
  }
}
