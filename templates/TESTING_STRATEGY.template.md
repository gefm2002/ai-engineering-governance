# Testing Strategy

**Actualizado:** UNKNOWN
**Regla:** este documento mapea los flujos del sistema a su cobertura de tests real — no la cobertura ideal, sino la que existe hoy.

---

## Cobertura actual por criticidad

| Criticidad | Flujos totales | Con test completo | Con test parcial | Sin test |
|------------|---------------|-------------------|------------------|----------|
| P0 | 0 | 0 | 0 | 0 |
| P1 | 0 | 0 | 0 | 0 |
| P2 | 0 | 0 | 0 | 0 |

**Cobertura de líneas:** UNKNOWN%
**Fecha de última medición:** UNKNOWN

---

## Requisitos mínimos por criticidad

| Criticidad | Tipo de test requerido | Coverage mínimo | Qué debe cubrir |
|------------|------------------------|-----------------|-----------------|
| **P0** | Integration test del flujo completo | 80% de líneas del módulo | Happy path + error principal |
| **P1** | Unit test del servicio + happy path | 60% de líneas del módulo | Happy path |
| **P2** | Unit test básico | Sin umbral | Al menos 1 caso |
| **P3** | Nice to have | Sin umbral | — |

---

## Mapa de flujos vs tests

> Completar con los flujos del USER_FLOW_MATRIX.md.
> Para cada flujo P0/P1, indicar qué archivo de test lo cubre.

### Flujos P0

| Flujo | ID en USER_FLOW_MATRIX | Archivo de test | Tipo | Estado |
|-------|------------------------|-----------------|------|--------|
| UNKNOWN | UF-001 | UNKNOWN | Integration / Unit / E2E | ✅ Completo / ⚠️ Parcial / ❌ Sin test |

### Flujos P1

| Flujo | ID en USER_FLOW_MATRIX | Archivo de test | Tipo | Estado |
|-------|------------------------|-----------------|------|--------|
| UNKNOWN | UF-00X | UNKNOWN | Unit | ✅ / ⚠️ / ❌ |

---

## Bypasses documentados

> Si hay tests saltados, forzados o con cobertura falsa, documentarlos acá
> con la razón y el plan de resolución.

| Bypass | Archivo | Razón | Plan | ETA |
|--------|---------|-------|------|-----|
| UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |

---

## Gaps de testing

> Items que deberían tener test pero no lo tienen.
> Si el gap es crítico, agregar también a GAPS.md.

| Flujo / Módulo | Criticidad | Tipo faltante | Complejidad de agregar |
|----------------|------------|---------------|------------------------|
| UNKNOWN | P0/P1/P2 | Integration / Unit | Alta / Media / Baja |

---

## Comandos de testing

```bash
# Correr suite completa
UNKNOWN

# Coverage
UNKNOWN

# Un flujo específico
UNKNOWN
```
