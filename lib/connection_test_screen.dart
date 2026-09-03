import 'package:flutter/material.dart';
import 'core/services/connection_test_service.dart';
import 'core/services/auth_service.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  final _service = ConnectionTestService();
  final _authService = AuthService();
  String _status = 'Not tested yet';
  String _authStatus = 'Not tested yet';
  bool _loading = false;

  Future<void> _runTest() async {
    setState(() {
      _loading = true;
      _status = 'Writing to Firestore...';
    });
    try {
      await _service.writeTestDocument();
      final message = await _service.readTestDocument();
      setState(() => _status = message != null ? '✅ Success: "$message"' : '⚠️ No data returned.');
    } catch (e) {
      setState(() => _status = '❌ Failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _runAuthTest() async {
    setState(() => _authStatus = 'Creating test user...');
    try {
      final credential = await _authService.signUp(
        email: 'test-${DateTime.now().millisecondsSinceEpoch}@studyflow.dev',
        password: 'TestPassword123!',
      );
      setState(() => _authStatus = '✅ Auth works! UID: ${credential.user?.uid}');
    } catch (e) {
      setState(() => _authStatus = '❌ Auth failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Connection Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: _runTest, child: const Text('Test Firestore')),
              const SizedBox(height: 32),
              Text(_authStatus, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _runAuthTest, child: const Text('Test Auth (create user)')),
            ],
          ),
        ),
      ),
    );
  }
}