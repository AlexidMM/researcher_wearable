import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'ui/wearable/wearable_app.dart';
import 'ui/dashboard/dashboard_app.dart';

void main() {
  runApp(const MiracleFlutterApp());
}

class MiracleFlutterApp extends StatelessWidget {
  const MiracleFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Si se compila para Web, mostramos el Dashboard de estadísticas (Práctica 8)
    if (kIsWeb) {
      return const DashboardApp();
    }
    // Si es móvil/reloj, mostramos la app de Wear OS (Práctica 7)
    else {
      return const WearableApp();
    }
  }
}
