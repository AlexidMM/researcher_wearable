# researcher_wearable

App Flutter para investigadores (Wear OS / Android / Linux desktop para pruebas).

## Arquitectura

```
PostgreSQL → miracle-api → researcher-finder   (web)
PostgreSQL → miracle-api → researcher_wearable (solo lectura)
```

La web y el wearable **no se conectan entre sí**. Ambos hablan con `miracle-api`.

## Cómo levantar (solo 2 terminales)

**Terminal 1 — API**
```bash
cd miracle-api
pnpm run start:dev
```

**Terminal 2 — Wearable**

En **Linux desktop** (tu caso):
```bash
cd researcher_wearable
flutter run -d linux --dart-define=API_URL=http://127.0.0.1:3000
```

En **emulador Android**:
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:3000
```

> No necesitas `flutter run -d web-server`. Ese servicio ya no se usa.

## Migración de notificaciones

Si las alertas fallan, crea la tabla en PostgreSQL:

```bash
psql -U TU_USUARIO -d TU_BD -f miracle-api/migrations/add_notifications.sql
```

## Endpoints consumidos

- `POST /auth/login`
- `GET /publications/mine`
- `GET /notifications/mine`

El wearable refresca cada **8 segundos** para mostrar cambios hechos desde la web.
