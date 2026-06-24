# Testing Strategy

**Actualizado:** 2026-06-24

---

## Cobertura actual por criticidad

| Criticidad | Flujos totales | Con test completo | Con test parcial | Sin test |
|------------|---------------|-------------------|------------------|----------|
| P0 | 2 | 1 | 1 | 0 |
| P1 | 2 | 1 | 0 | 1 |
| P2 | 2 | 0 | 1 | 1 |

**Cobertura de líneas:** 74%
**Fecha de última medición:** 2026-06-20

---

## Requisitos mínimos por criticidad

| Criticidad | Tipo de test requerido | Coverage mínimo | Qué debe cubrir |
|------------|------------------------|-----------------|-----------------|
| **P0** | Integration test del flujo completo | 80% | Happy path + error principal |
| **P1** | Unit test del servicio + happy path | 60% | Happy path |
| **P2** | Unit test básico | Sin umbral | Al menos 1 caso |
| **P3** | Nice to have | Sin umbral | — |

---

## Mapa de flujos vs tests

### Flujos P0

| Flujo | ID | Archivo de test | Tipo | Estado |
|-------|----|-----------------|------|--------|
| Recepción y despacho de evento | UF-001 | `src/handler/notificationsHandler.spec.ts` | Integration | ✅ Completo |
| Procesamiento de cola y envío | UF-002 | `src/worker/dispatchWorker.spec.ts` | Unit | ⚠️ Parcial — no cubre el path de FCM token inválido |

### Flujos P1

| Flujo | ID | Archivo de test | Tipo | Estado |
|-------|----|-----------------|------|--------|
| Gestión de preferencias | UF-003 | `src/domain/PreferencesService.spec.ts` | Unit | ✅ Completo |
| Unsubscribe global | UF-004 | — | — | ❌ Sin test |

---

## Bypasses documentados

| Bypass | Archivo | Razón | Plan | ETA |
|--------|---------|-------|------|-----|
| `it.skip('cancels queued messages')` | `dispatchWorker.spec.ts:47` | La funcionalidad aún no está implementada (GAP-001) | Activar cuando se implemente cancelación por user_id | 2026-07-15 |

---

## Gaps de testing

| Flujo / Módulo | Criticidad | Tipo faltante | Complejidad |
|----------------|------------|---------------|-------------|
| UF-002: path FCM token inválido | P0 | Integration test del error path | Baja — el mock de FCM ya existe |
| UF-004: Unsubscribe global | P1 | Unit test del handler | Media |
| `TwilioProvider.ts` | P1 | Unit test del proveedor | Media |

---

## Comandos de testing

```bash
# Suite completa
npm test

# Con coverage
npm run test:ci

# Un archivo específico
npx jest src/handler/notificationsHandler.spec.ts

# Coverage de un módulo
npx jest --coverage --collectCoverageFrom="src/domain/**" src/domain/
```
