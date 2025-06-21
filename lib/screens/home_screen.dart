// =============================================================================
// lib/screens/home_screen.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/calendar_section.dart';
import '../widgets/profile_section.dart';
import '../widgets/posts_section.dart';
import '../widgets/image_carousel_section.dart';
import '../widgets/qna_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ───────── 레이아웃 상수 ───────────────────────────────
  static const _canvasWidth = 1120.0;
  static const _sideWidth   = 260.0;
  static const _radius      = 12.0;
  static const _borderColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // SharedPreferences 복구 대기
    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // ※ FAB 완전히 제거 -------------------------------

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _canvasWidth),
            child: Row(
              children: [
                // 좌측 패널 -----------------------------------------------------
                SizedBox(
                  width: _sideWidth,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ▸ 프로필 박스 ― 길게(≥2s) 눌러 관리자 토글
                      _box(
                        child: _SecretLongPress(
                          onTrigger: () => _toggleAdmin(context),
                          child: const ProfileSection(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _box(child: const PostsSection()),
                      const SizedBox(height: 16),
                      _box(child: const CalendarSection()),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // 중앙 & 우측 ---------------------------------------------------
                Expanded(
                  child: Column(
                    children: [
                      _box(
                        height: 350,
                        child: const ImageCarouselSection(),
                      ),
                      const SizedBox(height: 24),
                      Expanded(child: _box(child: const QnaSection())),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── 공용 박스 ──────────────────────────────
  Widget _box({required Widget child, double? height}) => Container(
    height: height,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: _borderColor, width: 1.5),
      borderRadius: BorderRadius.circular(_radius),
      color: Colors.white,
    ),
    child: child,
  );

  // ───────── 로그인 / 로그아웃 전환 ─────────
  void _toggleAdmin(BuildContext ctx) async {
    final authProv = ctx.read<AuthProvider>();
    if (authProv.isAdmin) {
      authProv.logout();
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('로그아웃되었습니다')),
      );
    } else {
      showEmailLogin(ctx);
    }
  }
}

// =============================================================================
// 로그인 다이얼로그 (Email + Password) – 기존 내용 동일
// =============================================================================
void showEmailLogin(BuildContext context) {
  final mailCtrl = TextEditingController();
  final pwCtrl   = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('관리자 로그인'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: mailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: pwCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        ElevatedButton(
          onPressed: () async {
            final ok = await context.read<AuthProvider>().login(
              mailCtrl.text.trim(),
              pwCtrl.text.trim(),
            );
            if (ok) {
              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인 성공')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인 실패')));
            }
          },
          child: const Text('로그인'),
        ),
      ],
    ),
  );
}

// =============================================================================
// 내부 위젯 : 1초 이상 길게 누르면 onTrigger 호출
// =============================================================================
class _SecretLongPress extends StatefulWidget {
  final Widget child;
  final VoidCallback onTrigger;

  const _SecretLongPress({
    required this.child,
    required this.onTrigger,
  });

  @override
  State<_SecretLongPress> createState() => _SecretLongPressState();
}

class _SecretLongPressState extends State<_SecretLongPress> {
  DateTime? _start;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onLongPressStart: (_) => _start = DateTime.now(),
    onLongPressEnd: (_) {
      if (_start == null) return;
      final diff = DateTime.now().difference(_start!);
      if (diff >= const Duration(seconds: 1)) widget.onTrigger();
    },
    child: widget.child,
  );
}
