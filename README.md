# researcher_wearable

App Flutter para el ecosistema Miracle Finder.

## Modos de ejecución

- **Wear OS / Android (Práctica 7):** pantalla de login + lista de publicaciones con `SwitchListTile` para activar o cerrar misiones.
- **Flutter Web (Práctica 8):** widget de estadísticas (`StatsWidget`) embebido en el dashboard React de `researcher-finder`.

## Configuración

La URL de la API se define con `--dart-define`:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:3000
```

Para un dispositivo físico usa la IP de tu máquina, por ejemplo `http://192.168.1.50:3000`.

## Wear OS / Android

```bash
cd researcher_wearable
flutter pub get
flutter run --dart-define=API_URL=http://10.0.2.2:3000
```

## Flutter Web (dashboard embebido)

```bash
cd researcher_wearable
flutter pub get
flutter run -d chrome --web-port=8080 --dart-define=API_URL=http://localhost:3000
```

Luego levanta `researcher-finder` con `VITE_FLUTTER_STATS_URL=http://localhost:8080` en `.env`.

## Endpoints usados

- `POST /auth/login`
- `GET /publications/mine`
- `PATCH /publications/:id/status`
- `GET /publications/stats/mine`
