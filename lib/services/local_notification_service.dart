import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<void> initialize() async {
    if (_initialized || !isSupported) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: androidSettings);

      await _plugin.initialize(settings).timeout(const Duration(seconds: 5));
      _initialized = true;
    } catch (_) {
      // En Linux/desktop las notificaciones del sistema no están disponibles.
      _initialized = false;
    }
  }

  Future<void> showStatusAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!isSupported || !_initialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'publication_status_channel',
        'Estado de convocatorias',
        channelDescription: 'Avisos cuando se abren o cierran tus publicaciones',
        importance: Importance.high,
        priority: Priority.high,
      );

      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(android: androidDetails),
      );
    } catch (_) {
      // Ignorar si el SO no soporta notificaciones locales.
    }
  }
}
