# Product Roadmap

**Actualizado:** 2026-06-24

---

## Estado actual

**Fase en curso:** Fase 2 — Estabilización
**Próximo hito:** Rate limiting por usuario (GAP-002)
**Bloqueadores:** HO-02 en GAPS.md requiere decisión de producto antes de implementar

---

## Secuencia de fases

### Fase 1 — Core multi-canal ✅

**Objetivo:** Enviar notificaciones transaccionales por email, push y SMS.

**Criterio de done:**
- [x] Email via SES funcionando en producción
- [x] Push via FCM para iOS y Android
- [x] SMS via Twilio para AR/CL
- [x] Preferencias por usuario y canal
- [x] Unsubscribe global
- [x] Retry con backoff

---

### Fase 2 — Estabilización 🔄

**Objetivo:** Cerrar los gaps que afectan confiabilidad y experiencia del usuario.

**Criterio de done:**
- [ ] Unsubscribe cancela mensajes ya encolados (GAP-001)
- [ ] Rate limiting por usuario configurado (GAP-002) — bloqueado por HO-02
- [ ] Cache de preferencias en Redis para reducir N+1 (TD-01)

---

### Fase 3 — Flexibilidad operativa ⏳

**Objetivo:** Reducir fricción operativa para el equipo de producto.

**Criterio de done:**
- [ ] Templates en base de datos con hot reload — bloqueado por HO-01
- [ ] Batch push y SMS
- [ ] Retry limit configurable por tipo de evento (TD-02)

---

### Fase 4 — Cobertura internacional ⏳

**Objetivo:** SMS disponible para todos los países donde opera el negocio.

**Criterio de done:**
- [ ] SMS funcionando para BR, CO, PE
- [ ] Mecanismo de renovación de tokens FCM

---

## Anti-roadmap

| Item | Razón |
|------|-------|
| Scheduler propio de notificaciones | Fuera de scope — este servicio reacciona a eventos, no los programa |
| Almacenamiento del contenido de mensajes | Riesgo legal de privacidad — solo metadata |
