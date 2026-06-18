import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/stats_widget.dart';

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  late final ApiService _apiService;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiService = _createApiService();
    _bootstrapSession();
  }

  ApiService _createApiService() {
    final params = Uri.base.queryParameters;
    final apiUrl = params['apiUrl'] ?? ApiConfig.baseUrl;

    return ApiService(baseUrl: apiUrl);
  }

  Future<void> _bootstrapSession() async {
    final token = Uri.base.queryParameters['token'];

    if (token != null && token.isNotEmpty) {
      await _apiService.saveToken(token);
    }

    if (!mounted) return;

    final savedToken = await _apiService.getToken();
    if (savedToken == null || savedToken.isEmpty) {
      setState(() {
        _error = 'Inicia sesión en la web e incrusta este widget con un token válido.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miracle Stats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A2540)),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _error != null
                ? Center(
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFB91C1C)),
                    ),
                  )
                : StatsWidget(apiService: _apiService),
          ),
        ),
      ),
    );
  }
}
