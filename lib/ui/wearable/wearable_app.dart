import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'login_screen.dart';
import 'missions_screen.dart';

class WearableApp extends StatefulWidget {
  const WearableApp({super.key});

  @override
  State<WearableApp> createState() => _WearableAppState();
}

class _WearableAppState extends State<WearableApp> {
  final ApiService _apiService = ApiService();
  bool _checkingSession = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await _apiService.getToken();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _checkingSession = false;
    });
  }

  Future<void> _handleLoginSuccess() async {
    setState(() {
      _isLoggedIn = true;
    });
  }

  Future<void> _handleLogout() async {
    await _apiService.clearToken();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interruptor de Misiones',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF6C844),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: _checkingSession
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _isLoggedIn
              ? MissionsScreen(apiService: _apiService, onLogout: _handleLogout)
              : LoginScreen(apiService: _apiService, onLoginSuccess: _handleLoginSuccess),
    );
  }
}
