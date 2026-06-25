import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/app_notification.dart';
import '../../models/publication.dart';
import '../../services/api_service.dart';
import '../../services/local_notification_service.dart';
import 'notifications_tab.dart';
import 'publications_status_tab.dart';

class WearableHomeScreen extends StatefulWidget {
  const WearableHomeScreen({
    super.key,
    required this.apiService,
    required this.onLogout,
  });

  final ApiService apiService;
  final VoidCallback onLogout;

  @override
  State<WearableHomeScreen> createState() => _WearableHomeScreenState();
}

class _WearableHomeScreenState extends State<WearableHomeScreen> {
  List<Publication> _publications = [];
  List<AppNotification> _notifications = [];
  bool _loading = true;
  String? _error;
  String? _warnings;
  Timer? _pollTimer;
  final Set<int> _knownNotificationIds = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    // No bloquear la carga de datos por notificaciones del sistema.
    unawaited(LocalNotificationService.instance.initialize());
    await _refreshAll(showLoader: true);
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _pollUpdates());
  }

  Future<void> _refreshAll({bool showLoader = false}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
        _warnings = null;
      });
    }

    String? publicationsError;
    String? notificationsError;
    var publications = <Publication>[];
    var notifications = <AppNotification>[];

    try {
      publications = await widget.apiService.fetchMyPublications();
    } catch (error) {
      publicationsError = error.toString().replaceFirst('Exception: ', '');
    }

    try {
      notifications = await widget.apiService.fetchMyNotifications();
    } catch (error) {
      notificationsError = error.toString().replaceFirst('Exception: ', '');
    }

    if (!mounted) return;

    setState(() {
      _publications = publications;
      _notifications = notifications;
      _loading = false;

      if (publicationsError != null && publications.isEmpty) {
        _error = publicationsError;
      } else {
        _error = null;
      }

      if (notificationsError != null) {
        _warnings = 'Alertas no disponibles: $notificationsError';
      } else {
        _warnings = null;
      }
    });

    _registerKnownNotifications(notifications);
  }

  Future<void> _pollUpdates() async {
    try {
      final notifications = await widget.apiService.fetchMyNotifications();
      if (!mounted) return;

      final freshNotifications =
          notifications.where((item) => !_knownNotificationIds.contains(item.id));

      for (final notification in freshNotifications) {
        await LocalNotificationService.instance.showStatusAlert(
          id: notification.id,
          title: notification.isOpened ? 'Convocatoria abierta' : 'Convocatoria cerrada',
          body: notification.message,
        );
        _knownNotificationIds.add(notification.id);
      }

      final publications = await widget.apiService.fetchMyPublications();
      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _publications = publications;
      });
    } catch (_) {
      // Polling silencioso.
    }
  }

  void _registerKnownNotifications(List<AppNotification> notifications) {
    for (final notification in notifications) {
      _knownNotificationIds.add(notification.id);
    }
  }

  int get _unreadCount => _notifications.where((item) => !item.isRead).length;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monitor de Misiones'),
          actions: [
            IconButton(
              tooltip: 'Recargar',
              onPressed: _loading ? null : () => _refreshAll(showLoader: true),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Salir',
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.article_outlined),
                text: 'Publicaciones (${_publications.length})',
              ),
              Tab(
                icon: Badge(
                  isLabelVisible: _unreadCount > 0,
                  label: Text('$_unreadCount'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                text: 'Alertas (${_notifications.length})',
              ),
            ],
          ),
        ),
        body: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('Conectando con ${widget.apiService.baseUrl}'),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 40),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Text(
                            'API: ${widget.apiService.baseUrl}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => _refreshAll(showLoader: true),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      if (_warnings != null)
                        Container(
                          width: double.infinity,
                          color: const Color(0xFF78350F),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(_warnings!, style: const TextStyle(fontSize: 12)),
                        ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            PublicationsStatusTab(publications: _publications),
                            NotificationsTab(notifications: _notifications),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
