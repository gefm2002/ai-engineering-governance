# User Flow Matrix

**Actualizado:** 2026-06-24

---

## Resumen de criticidad

| Criticality | Cantidad |
|-------------|----------|
| P0 | 2 |
| P1 | 2 |
| P2 | 2 |

---

## Flujos P0 — Core

### UF-001: Recepción y despacho de evento

**Actor:** Servicio upstream
**Trigger:** POST /notifications
**Criticality:** P0

| Paso | Descripción | Estado |
|------|-------------|--------|
| 1 | Validar schema del payload (event_id, event_type, user_id, data) | ✅ |
| 2 | Verificar idempotencia: si `event_id` ya existe en `notification_log` → 200 sin procesar | ✅ |
| 3 | Leer preferencias del usuario desde PostgreSQL | ✅ |
| 4 | Verificar `user.notifications_enabled` | ✅ |
| 5 | Determinar canal según preferencias + reglas de negocio | ✅ |
| 6 | Encolar mensaje en Redis con TTL 24h | ✅ |
| 7 | Retornar `{ status: "queued", notification_id }` | ✅ |

**Edge cases:**
- `notifications_enabled = false` → 200 con `{ status: "skipped", reason: "opt-out" }`
- Template no existe → 422 con error explícito
- Redis no disponible → 503, el upstream debe reintentar

---

### UF-002: Procesamiento de cola y envío

**Actor:** Worker interno (cron cada 5s)
**Trigger:** Mensaje en cola Redis
**Criticality:** P0

| Paso | Descripción | Estado |
|------|-------------|--------|
| 1 | Leer mensaje de la cola | ✅ |
| 2 | Renderizar template con variables del evento | ✅ |
| 3 | Llamar al proveedor del canal (SES / FCM / SMS) | ✅ |
| 4 | Si éxito: registrar en `notification_log` con estado `SENT` | ✅ |
| 5 | Si fallo: incrementar `retry_count`, re-encolar con backoff | ✅ |
| 6 | Si `retry_count >= 3`: estado `FAILED`, no re-encolar, alertar | ✅ |

**Edge cases:**
- SES throttling → fallo tratado como retriable
- FCM token inválido → fallo **no** retriable, estado `FAILED` inmediato

---

## Flujos P1 — Importantes

### UF-003: Gestión de preferencias de usuario

**Actor:** Usuario final
**Trigger:** PUT /users/:id/preferences
**Criticality:** P1

| Paso | Descripción | Estado |
|------|-------------|--------|
| 1 | Autenticar request (JWT) | ✅ |
| 2 | Validar estructura de preferencias | ✅ |
| 3 | Actualizar en PostgreSQL | ✅ |
| 4 | Invalidar cache de preferencias en Redis | ⚠️ Cache no implementado aún — no hay nada que invalidar |

---

### UF-004: Unsubscribe global (one-click)

**Actor:** Usuario final
**Trigger:** GET /unsubscribe?token=...
**Criticality:** P1

| Paso | Descripción | Estado |
|------|-------------|--------|
| 1 | Validar token HMAC (expira en 30 días) | ✅ |
| 2 | Setear `user.notifications_enabled = false` | ✅ |
| 3 | Retornar página de confirmación | ✅ |
| 4 | Cancelar mensajes pendientes en cola para ese usuario | ❌ No implementado — mensajes ya encolados se procesan igual |

**Riesgo:** el usuario hace unsubscribe pero aún puede recibir notificaciones encoladas previas.

---

## Flujos P2 — Secundarios

### UF-005: Consulta de historial

**Actor:** Servicio upstream o admin
**Trigger:** GET /notifications?user_id=...
**Criticality:** P2

### UF-006: Reenvío manual de notificación fallida

**Actor:** Admin
**Trigger:** POST /notifications/:id/retry
**Criticality:** P2
