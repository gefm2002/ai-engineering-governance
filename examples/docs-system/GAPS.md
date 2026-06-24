# Gaps

**Regla:** solo items ABIERTOS. Cuando se cierra, se elimina (el historial queda en git).

---

## Gaps activos

### GAP-001: Unsubscribe no cancela mensajes ya encolados

**Área:** Cola / preferencias de usuario
**Severidad:** P1
**Detectado:** 2026-05-12
**Descripción:** Cuando un usuario hace unsubscribe global, los mensajes que ya estaban en la cola Redis se procesan y envían igual. El opt-out solo aplica a mensajes nuevos.
**Impacto:** Usuarios que se dan de baja pueden recibir notificaciones posteriores al opt-out.
**Bloqueante para:** Cumplimiento de expectativas de UX y potencialmente regulatorio (CAN-SPAM).

---

### GAP-002: Sin rate limiting por usuario

**Área:** Despacho de notificaciones
**Severidad:** P1
**Detectado:** 2026-06-01
**Descripción:** No existe ningún mecanismo que limite cuántas notificaciones puede recibir un usuario en un período de tiempo.
**Impacto:** Un bug upstream que emita eventos en loop puede spamear a todos los usuarios hasta que se detecte manualmente.
**Bloqueante para:** Lanzamiento de cualquier integración con servicio de alta frecuencia.

---

### GAP-003: FCM tokens inválidos sin mecanismo de actualización

**Área:** Proveedor push
**Severidad:** P2
**Detectado:** 2026-04-20
**Descripción:** Cuando FCM retorna `registration-token-not-registered`, el mensaje queda `FAILED` pero no hay ningún mecanismo para que el token se actualice. El cliente debe abrir la app para regenerarlo.
**Impacto:** Usuarios que no abren la app por tiempo prolongado dejan de recibir push sin saberlo.
**Bloqueante para:** Métricas de entrega push confiables.

---

## HUMAN_ONLY

| ID | Acción requerida | Responsable | Contexto |
|----|------------------|-------------|---------|
| HO-01 | Confirmar si GAP-001 requiere acción regulatoria urgente | Legal / Product | Depende de jurisdicción y tipo de notificaciones enviadas |
| HO-02 | Definir límite de rate por usuario y canal | Product | Sin esta decisión, no se puede implementar GAP-002 |

---

## Gaps en proceso de cierre

| ID | Gap | Plan de cierre | ETA |
|----|-----|----------------|-----|
| GAP-001 | Unsubscribe no cancela cola | Agregar índice en Redis por user_id + método `cancelByUser` en `RedisQueue` | 2026-07-15 |
