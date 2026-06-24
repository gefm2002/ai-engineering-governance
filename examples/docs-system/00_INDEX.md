# docs-system — Index

> Documentación oficial de `notifications-service`.
> Fuente de verdad para cualquier agente de IA o desarrollador que trabaje en este repo.

---

## Contenido

| Archivo | Descripción | Completitud |
|---------|-------------|-------------|
| [PRODUCT_SURFACE.md](PRODUCT_SURFACE.md) | Capabilities reales, actores, reglas de negocio | Alta |
| [USER_FLOW_MATRIX.md](USER_FLOW_MATRIX.md) | 6 flujos con criticidad P0/P1/P2 | Alta |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Stack, estructura, decisiones técnicas | Alta |
| [INTEGRATIONS.md](INTEGRATIONS.md) | APIs, env vars, contratos | Alta |
| [OPERATIONS.md](OPERATIONS.md) | Build, deploy, runbooks | Alta |
| [TECHNICAL_DEBT_ROADMAP.md](TECHNICAL_DEBT_ROADMAP.md) | Deuda activa / cerrada / HUMAN_ONLY | Alta |
| [GAPS.md](GAPS.md) | Items abiertos que bloquean | Alta |
| [PLATFORM_STATE.md](PLATFORM_STATE.md) | Scorecard por área, bloqueadores | Alta |
| [PRODUCT_ROADMAP.md](PRODUCT_ROADMAP.md) | Fases con criterio de done | Alta |
| [PERFORMANCE_REPORT.md](PERFORMANCE_REPORT.md) | Mediciones antes/después del último cambio | Alta |

---

## Resumen del sistema

**Qué hace:** Servicio de notificaciones multi-canal (email, push, SMS) que recibe eventos de otros servicios y los despacha al canal correcto según preferencias del usuario y reglas de negocio.

**Negocio:** Comunicación con usuarios post-transacción — confirmaciones de compra, alertas de entrega, recordatorios de pago.

**Stack:** Node.js + TypeScript · PostgreSQL · Redis (queue) · AWS SES (email) · Firebase FCM (push)

**Riesgos principales:**
- SES tiene rate limits por cuenta — picos de volumen pueden causar throttling silencioso.
- Las preferencias de usuario se leen en cada envío sin cache — N+1 ante volumen alto.
- `retry_count` no tiene límite máximo configurable — mensajes corruptos pueden loopear indefinidamente.

---

## Regla

Si el sistema cambia, este directorio debe actualizarse en el mismo PR.
Ningún cambio de comportamiento es válido sin documentación actualizada.
