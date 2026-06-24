# Evidence Report

**Fecha:** 2026-06-20
**Sesión:** a3f92c1
**Autor:** gasferna
**Tipo de cambio:** feature

---

## Resumen del cambio

Se implementó procesamiento paralelo de notificaciones en el `DispatchWorker`.
Antes se procesaba de a 1 mensaje por ciclo; ahora de a 10 en paralelo con `Promise.allSettled`.
Motivación: throughput insuficiente para el volumen de `order_confirmed` en peak de ventas.

---

## Flujos afectados

| Flujo ID | Nombre | Criticidad | Impacto |
|----------|--------|------------|---------|
| UF-001 | Recepción y despacho de evento | P0 | modificado — procesamiento paralelo |
| UF-002 | Procesamiento de cola y envío | P0 | modificado — batch size 1→10 |
| UF-003 | Gestión de preferencias | P1 | sin cambio |

---

## Tests ejecutados

**Comando:**
```
npm run test:ci -- --coverage
```

**Resultado:**
```
Test Suites: 8 passed, 0 failed
Tests:       47 passed, 0 failed, 1 skipped
Snapshots:   0
Time:        12.4s
```

**Cobertura total:** 78%
**Cobertura de flujos P0 afectados:** 84%

---

## Flujos P0 cubiertos por tests

| Flujo ID | Archivo de test | Tipo de test | Estado |
|----------|-----------------|--------------|--------|
| UF-001 | `src/handler/notificationsHandler.spec.ts` | Integration | ✅ completo |
| UF-002 | `src/worker/dispatchWorker.spec.ts` | Unit | ⚠️ parcial — el path de error con Promise.allSettled no está cubierto |

---

## Bypasses presentes

| Bypass | Archivo | Justificación | Plan de resolución |
|--------|---------|---------------|--------------------|
| `it.skip('cancels queued messages')` | `dispatchWorker.spec.ts:47` | Funcionalidad no implementada (GAP-001) | Activar cuando se implemente cancelación — sprint siguiente |

---

## Documentación actualizada

| Documento | Qué cambió |
|-----------|------------|
| ARCHITECTURE.md | Agregado: DispatchWorker ahora usa Promise.allSettled con batch de 10 |
| PERFORMANCE_REPORT.md | Actualizado con medición before/after: 12 → 47 msgs/seg |
| DIAGRAMS.md | Secuencia del worker actualizada — antes sequential, ahora parallel |

---

## Riesgos identificados

- El path de error en `Promise.allSettled` (cuando 1 de 10 mensajes falla) no está cubierto por test de integración. Si un provider falla, los otros 9 mensajes del batch se procesan igual — eso es el comportamiento esperado, pero no está verificado automáticamente.
- Si Redis devuelve menos de 10 mensajes, el batch funciona bien — fue validado manualmente pero no hay test para batch parcial.

---

## Criterio de done

- [x] Tests pasan sin `continue-on-error`
- [x] No hay bypasses nuevos no documentados
- [x] Coverage de flujos P0 afectados >= 80% (84%)
- [x] docs-system actualizado si el comportamiento cambió
- [x] Riesgos identificados documentados
