// =============================================================================
// lib/screens/login_screen.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  String? _error;

  void _login() async {
    final ok = await context.read<AuthProvider>().login(
      _idCtrl.text.trim(),
      _pwCtrl.text.trim(),
    );
    if (ok) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _error = '잘못된 자격증명');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _idCtrl, decoration: const InputDecoration(labelText: 'ID')),
              TextField(controller: _pwCtrl, decoration: const InputDecoration(labelText: 'PW'), obscureText: true),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _login, child: const Text('로그인')),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}