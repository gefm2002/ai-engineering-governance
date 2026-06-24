# Product Surface

**Actualizado:** 2026-06-24
**Regla:** si una capability no está acá → no existe comercialmente.

---

## Qué es este sistema

| Dimensión | Descripción |
|-----------|-------------|
| Nombre | `notifications-service` |
| Propósito | Despachar notificaciones multi-canal según preferencias del usuario y reglas de negocio |
| Versión actual | 2.3.1 |
| Estado | Activo en producción |

---

## Capability Reality Matrix

| Capability | Estado real | Situación |
|------------|-------------|-----------|
| Envío de email transaccional | ✅ READY | Via AWS SES con templates Handlebars |
| Envío de push notification | ✅ READY | Via Firebase FCM — iOS y Android |
| Envío de SMS | ⚠️ PARTIAL | Solo números AR/CL — no internacionales |
| Preferencias de usuario por canal | ✅ READY | Opt-in/opt-out por tipo de notificación |
| Retry automático ante fallo | ✅ READY | 3 reintentos con backoff exponencial |
| Historial de notificaciones enviadas | ✅ READY | Tabla `notification_log` — 90 días de retención |
| Notificaciones en batch | ⚠️ PARTIAL | Solo email — push y SMS son uno a uno |
| Templates dinámicos | ✅ READY | Variables por evento inyectadas en el template |
| Unsubscribe global | ✅ READY | Un click desactiva todos los canales |
| Rate limiting por usuario | ❌ NOT IMPLEMENTED | Un usuario puede recibir notificaciones sin límite |

---

## Actores principales

| Actor | Rol | Acciones principales |
|-------|-----|----------------------|
| Servicios upstream | Emisores de eventos | POST /notifications con payload del evento |
| Usuario final | Receptor | Recibe notificaciones, gestiona preferencias |
| Equipo de producto | Configura templates | Crea/edita templates via admin panel |
| SES / FCM / SMS provider | Canales de entrega | Ejecutan el envío físico |

---

## Reglas de negocio críticas

1. **Canal por defecto**: si el usuario no tiene preferencias, se envía por email.
2. **Opt-out global**: si `user.notifications_enabled = false`, no se envía nada — sin excepciones.
3. **Deduplicación**: si el mismo `event_id` ya fue procesado, se ignora (idempotencia).
4. **Retry limit**: máximo 3 reintentos. Al tercer fallo, el mensaje queda en estado `FAILED` y se loggea.
5. **Templates requeridos**: si el template del evento no existe, el envío falla con error explícito — no se envía fallback genérico.
6. **SMS solo para eventos críticos**: el canal SMS está reservado para `priority: HIGH` — no se usa para marketing.

---

## Anti-goals — NO construir

- Este servicio NO gestiona el contenido de marketing — eso es responsabilidad del CMS.
- Este servicio NO almacena contenido de los mensajes enviados — solo metadata (canal, estado, timestamp).
- Este servicio NO envía notificaciones sin un evento upstream — no tiene scheduler propio.
