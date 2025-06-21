// =============================================================================
// lib/main.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/post_provider.dart';
import 'providers/carousel_provider.dart';
import 'providers/qna_provider.dart';

import 'screens/login_screen.dart'; // 옵션: 다이얼로그 방식이면 제거 가능
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => CarouselProvider()),
        ChangeNotifierProvider(create: (_) => QnaProvider()),
      ],
      child: MaterialApp(
        title: 'Homepage',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),

        // ───────── 홈이 기본 진입 화면 ─────────
        home: const HomeScreen(),

        // 필요하면 라우트 테이블 유지
        routes: {
          '/home': (_) => const HomeScreen(),
          '/login': (_) => const LoginScreen(), // 다이얼로그 방식이면 생략 가능
        },
      ),
    );
  }
}
