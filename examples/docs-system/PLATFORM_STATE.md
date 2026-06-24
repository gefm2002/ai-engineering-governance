# Platform State

**Actualizado:** 2026-06-24

---

## Scorecard por área

| Área | Estado | Comentario |
|------|--------|------------|
| Envío email (SES) | 🟢 | Operativo — sin incidentes recientes |
| Envío push (FCM) | 🟡 | Funcional — tokens inválidos acumulándose sin mecanismo de renovación |
| Envío SMS (Twilio) | 🟡 | Solo AR/CL — falta cobertura internacional |
| Cola Redis | 🟢 | Operativa — TTL correcto, no hay acumulación |
| Preferencias de usuario | 🟡 | Funcional — sin cache, riesgo N+1 a escala |
| Unsubscribe | 🟡 | Funcional — no cancela mensajes ya encolados (GAP-001) |
| Worker de despacho | 🟢 | Operativo — intervalo 5s, sin errores críticos |
| Rate limiting | 🔴 | No implementado — riesgo de spam ante bug upstream |
| CI/CD | 🟢 | GitHub Actions funcionando — coverage > 80% |

---

## Estado del producto

### Lo que funciona hoy

- Despacho email, push y SMS para eventos transaccionales
- Preferencias por canal por tipo de evento
- Idempotencia por `event_id`
- Retry con backoff exponencial (máximo 3)
- Unsubscribe global one-click
- Historial de notificaciones (90 días)

### Lo que está parcialmente implementado

- **Unsubscribe**: funciona para nuevos mensajes, no cancela los encolados
- **SMS**: funciona para AR/CL, no para otros países
- **Batch**: solo email — push y SMS son uno a uno

### Lo que NO existe

- Rate limiting por usuario
- Hot reload de templates
- Cancelación de mensajes por user_id en la cola

---

## Bloqueadores activos

| ID | Bloqueador | Área | Responsable |
|----|------------|------|-------------|
| BL-01 | Sin rate limiting — un loop upstream puede spamear usuarios | Despacho | Equipo Notificaciones |

---

## Dependencias externas críticas

| Dependencia | Estado | Impacto si falla |
|-------------|--------|------------------|
| AWS SES | 🟢 | Sin email — mensajes en cola se reintentan |
| Firebase FCM | 🟢 | Sin push — mensajes en cola se reintentan |
| Twilio | 🟢 | Sin SMS — mensajes en cola se reintentan |
| PostgreSQL | 🟢 | Servicio completo caído — no se pueden leer preferencias |
| Redis | 🟡 | Cola perdida — mensajes en vuelo se pierden (sin persistencia, DC-01) |
