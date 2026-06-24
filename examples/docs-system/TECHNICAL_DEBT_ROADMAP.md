# Technical Debt Roadmap

**Actualizado:** 2026-06-24

---

## Deuda activa

### Crítica

| ID | Descripción | Impacto | Ubicación |
|----|-------------|---------|-----------|
| TD-01 | Preferencias de usuario leídas desde DB en cada envío sin cache | N+1 ante volumen alto — cada mensaje genera 1 SELECT de preferencias | `NotificationService.ts:getPreferences` |
| TD-02 | `retry_count` sin límite máximo configurable por evento | Mensajes corruptos pueden loopear — el límite de 3 es hardcodeado, no configurable por tipo | `dispatchWorker.ts:RETRY_LIMIT` |

### Mayor

| ID | Descripción | Impacto | Ubicación |
|----|-------------|---------|-----------|
| TD-10 | Mensajes ya encolados no se cancelan al hacer unsubscribe | El usuario puede recibir notificaciones después de opt-out si ya estaban en la cola | `RedisQueue.ts` — no existe método de cancelación por user_id |
| TD-11 | Templates en filesystem — cambiarlos requiere deploy | Sin hot reload de templates — cada cambio de copy implica pipeline completo | `src/templates/` |
| TD-12 | No existe rate limiting por usuario | Un usuario puede recibir notificaciones ilimitadas — riesgo de spam | `NotificationService.ts` |

### Menor

| ID | Descripción |
|----|-------------|
| TD-20 | `console.log` en `TwilioProvider.ts` en lugar del logger estándar |
| TD-21 | Tests de integración no cubren el worker — solo unit tests del handler |

---

## Paridad pendiente

| Feature | Descripción | Prioridad |
|---------|-------------|-----------|
| SMS internacional | Solo AR/CL — falta soporte para otros países | Media |
| Batch push | Solo email soporta batch — push y SMS son uno a uno | Baja |

---

## HUMAN_ONLY

| ID | Acción requerida | Por qué no automatizable |
|----|------------------|--------------------------|
| HO-01 | Decidir si los templates deben moverse a DB o mantenerse en filesystem | Afecta el proceso editorial del equipo de producto — decisión organizacional |
| HO-02 | Definir rate limit por usuario por canal | Requiere decisión de producto sobre UX de notificaciones |

---

## Cerrado en QA / Producción

| ID | Descripción | Solución | Fecha | PR |
|----|-------------|----------|-------|-----|
| TD-00 | Envío duplicado cuando el worker procesaba el mismo mensaje dos veces | Idempotencia por `event_id` en `notification_log` | 2026-03-10 | #142 |

---

## Decisiones conscientes de deuda

| ID | Descripción | Razón | Fecha |
|----|-------------|-------|-------|
| DC-01 | Redis como queue sin persistencia | Simplicidad operativa — pérdida de mensajes en caída de Redis es aceptable para el volumen actual | 2025-09-01 |
