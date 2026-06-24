# Integrations

**Actualizado:** 2026-06-24

---

## Variables de entorno

| Variable | Obligatoria | Descripción |
|----------|-------------|-------------|
| `DATABASE_URL` | ✅ | Connection string PostgreSQL |
| `REDIS_URL` | ✅ | URL Redis para queue |
| `AWS_REGION` | ✅ | Región SES |
| `AWS_SES_FROM` | ✅ | Email remitente verificado en SES |
| `FIREBASE_CREDENTIALS` | ✅ | JSON de credenciales Firebase Admin SDK |
| `TWILIO_ACCOUNT_SID` | ✅ | SID de cuenta Twilio |
| `TWILIO_AUTH_TOKEN` | ✅ | Token de autenticación Twilio |
| `TWILIO_FROM_NUMBER` | ✅ | Número origen Twilio |
| `UNSUBSCRIBE_SECRET` | ✅ | Clave HMAC para tokens de unsubscribe |
| `WORKER_INTERVAL_MS` | No | Intervalo del worker (default: 5000ms) |
| `RETRY_LIMIT` | No | Máximo de reintentos (default: 3) |

---

## Integraciones externas

### AWS SES

**SDK:** `@aws-sdk/client-ses` v3
**Operación:** `SendEmailCommand`
**Rate limit conocido:** 14 emails/segundo en cuenta sandbox, 200/segundo en producción
**Fallo retriable:** sí (excepto bounces permanentes)

### Firebase FCM

**SDK:** `firebase-admin` 12.x
**Operación:** `messaging.send()`
**Token inválido:** error `messaging/registration-token-not-registered` → NO retriable

### Twilio SMS

**SDK:** `twilio` 5.x
**Operación:** `client.messages.create()`
**Países soportados:** AR, CL (ver PRODUCT_SURFACE — SMS PARTIAL)

### PostgreSQL (Prisma)

Tablas principales:

| Tabla | Descripción |
|-------|-------------|
| `users` | `id`, `email`, `phone`, `fcm_token`, `notifications_enabled` |
| `notification_preferences` | `user_id`, `event_type`, `channel`, `enabled` |
| `notification_log` | `event_id`, `user_id`, `channel`, `status`, `retry_count`, `sent_at` |
| `templates` | No existe — los templates son archivos en `src/templates/` |

### Redis

**Uso:** Queue de mensajes pendientes con TTL 24h
**Clave:** `notification:{notification_id}`
**Formato del valor:** JSON serializado con `{ event_type, user_id, channel, data, retry_count }`
