# AI-Assisted Engineering Governance Framework

---

## Objetivo

Establecer un proceso estándar para el uso de IA (Cursor, Claude, Codex, Copilot y similares) dentro del ciclo de desarrollo.

El objetivo no es generar más código.

El objetivo es:

- Reducir cambios sin contexto.
- Reducir regresiones.
- Preservar conocimiento.
- Mejorar mantenibilidad.
- Aumentar velocidad sin perder control.
- Permitir que humanos e IA compartan una misma fuente de verdad.

---

## Principios

### 1. Entender antes de modificar

Ningún cambio debe implementarse sin comprender:

- Qué hace el sistema.
- Qué negocio soporta.
- Qué actores impacta.
- Qué dependencias afecta.
- Qué contratos modifica.

### 2. La documentación es parte del producto

La documentación no es opcional.

Si el sistema cambia, la documentación debe cambiar **en el mismo PR**.

Un cambio sin documentación actualizada no está completo.

### 3. La IA no reemplaza entendimiento

La IA puede generar código.
No puede inferir correctamente:

- Reglas de negocio implícitas.
- Dependencias organizacionales.
- Decisiones históricas.
- Restricciones operativas.

Por lo tanto, la IA debe trabajar a partir de documentación explícita.

### 4. Evidencia sobre opiniones

No se considera validado:

- Build exitoso.
- Test unitario exitoso.
- Respuesta HTTP 200.

Se considera validado:

- Flujo ejecutado.
- Resultado verificado.
- Evidencia disponible.

### 5. Source of Truth

Cada repositorio debe poseer una carpeta `/docs-system/` que contiene la documentación oficial.

No deben existir múltiples fuentes contradictorias.

---

## Estructura de /docs-system/

### Documentos requeridos (todos los repositorios)

```
/docs-system
├── 00_INDEX.md                  ← tabla de contenido y resumen del sistema
├── PRODUCT_SURFACE.md           ← capabilities reales, actores, reglas de negocio
├── USER_FLOW_MATRIX.md          ← flujos con criticidad P0/P1/P2/P3
├── ARCHITECTURE.md              ← stack, estructura, decisiones técnicas
├── INTEGRATIONS.md              ← APIs, env vars, contratos
├── OPERATIONS.md                ← build, deploy, runbooks
├── TECHNICAL_DEBT_ROADMAP.md    ← deuda activa / cerrada / HUMAN_ONLY
└── GAPS.md                      ← solo items abiertos que bloquean
```

### Documentos opcionales (según tipo de proyecto)

```
/docs-system
├── PLATFORM_STATE.md            ← scorecard por área, bloqueadores activos
├── PRODUCT_ROADMAP.md           ← fases con entregables y criterio de done
└── PERFORMANCE_REPORT.md        ← mediciones before/after con metodología
```

---

## Los tres momentos de uso

### Momento 1 — Primera vez en un repo

El agente lee el código y genera todos los documentos de `/docs-system/` con el estado actual.

```
Ejecutá la Fase 0 del Engineering Governance Framework.
No modifiques código.
Leé el repositorio y completá todos los archivos de /docs-system/ con el estado actual.
```

### Momento 2 — Cambios diarios

El agente carga el contexto antes de actuar y actualiza los docs en el mismo commit.

```
Leé /docs-system/ como contexto antes de hacer cualquier cambio.
Cuando hagas una modificación, si el comportamiento cambia, actualizá
el archivo correspondiente de /docs-system/ en el mismo commit.
```

### Momento 3 — Evaluación y plan de trabajo

El agente evalúa el estado actual del sistema y genera un plan priorizado sin tocar código.

```
Leé /docs-system/ completo. No modifiques código ni documentación.
Con base en GAPS.md, TECHNICAL_DEBT_ROADMAP.md, PLATFORM_STATE.md
y PRODUCT_ROADMAP.md, generá un plan de trabajo priorizado.
```

### Momento 4 — Re-sincronización de docs

Cuando los docs quedaron desactualizados respecto al código (deuda de documentación acumulada).

```
Leé /docs-system/ y compará con el estado actual del código.
Identificá qué documentos están desactualizados.
Actualizá solo los docs que no reflejan el comportamiento real — sin modificar código.
```

---

## Flujo de trabajo con IA

```
Fase 0 — Context Bootstrap
  Lee /docs-system/ completo antes de cualquier acción.
  Si no existe, lo crea desde el código.
       ↓
Fase 1 — Repository Summary
  Entiende el sistema: propósito, negocio, actores, dependencias, riesgos.
       ↓
Fase 2 — Impact Analysis
  Para el cambio solicitado: módulos, APIs, eventos, docs afectados.
       ↓
Fase 3 — Ejecución
  Solo después del análisis. Con validaciones. Sin declarar done sin evidencia.
       ↓
Fase 4 — Documentación
  Si el comportamiento cambia, actualiza /docs-system/ en el mismo commit.
       ↓
Fase 5 — Cierre
  Entrega: Summary / Impact Analysis / Files Changed /
           Documentation Updated / Validation Executed / Remaining Risks
```

---

## Gobernanza de testing

### Principio

Un test que siempre pasa no aporta nada. Lo que importa no es que los tests corran — es que prueben comportamiento real con assertions reales.

### Qué nivel de test exige cada criticidad

| Criticidad | Tipo de test requerido | Cobertura mínima | Qué debe cubrir |
|------------|------------------------|------------------|-----------------|
| **P0** — el sistema no funciona sin este flujo | Integration test del flujo completo | 80% de líneas del módulo | Happy path + error principal |
| **P1** — afecta revenue o experiencia principal | Unit test del servicio + happy path | 60% de líneas del módulo | Happy path |
| **P2** — funcionalidad de soporte | Unit test básico | Sin umbral | Al menos 1 caso |
| **P3** — nice to have | Nice to have | Sin umbral | — |

Los flujos y su criticidad están documentados en `USER_FLOW_MATRIX.md`.

### Lo que NO cuenta como validado

- `continue-on-error: true` en CI — los tests que fallan llegan a producción
- `.skip()`, `xit()`, `xdescribe()` — el test no corre
- `.only()` — solo ese test corre, el resto no
- Tests con cuerpo vacío — `it('should work', () => {})`
- Fake assertions — `expect(true).toBe(true)`
- `--passWithNoTests` — un suite vacío cuenta como exitoso

Cualquiera de estos patrones detectados en un PR debe estar **documentado en `TESTING_STRATEGY.md`** con justificación y plan de resolución.

### Qué hacer al hacer un cambio

Antes de declarar el cambio como completo:

1. Identificar qué flujos del `USER_FLOW_MATRIX.md` afecta el cambio
2. Verificar que esos flujos tienen tests al nivel requerido por su criticidad
3. Si no los tienen: crearlos en el mismo PR o documentar el gap en `TESTING_STRATEGY.md`
4. Reportar en el cierre (Fase 5): qué se corrió, cobertura, si hubo flujos P0/P1 afectados sin test

### Prompt para evaluar cobertura antes de un cambio

```
Leé /docs-system/USER_FLOW_MATRIX.md y /docs-system/TESTING_STRATEGY.md.
Identificá qué flujos P0 y P1 afecta el cambio que voy a pedir.
Verificá si esos flujos tienen cobertura de test al nivel requerido.
Reportá los gaps antes de implementar.
```

### Prompt para generar tests de un cambio

```
El cambio afecta el flujo [UF-00X] del USER_FLOW_MATRIX — criticidad [P0/P1].
Generá los tests requeridos según el nivel de criticidad:
- Si P0: integration test del flujo completo (happy path + error principal)
- Si P1: unit test del servicio (happy path)
Sin .skip, sin .only, sin fake assertions.
```

---

## Qué documento actualizar según el tipo de cambio

| Tipo de cambio | Documentos a actualizar |
|----------------|------------------------|
| Nueva funcionalidad | PRODUCT_SURFACE, USER_FLOW_MATRIX |
| Cambio de arquitectura | ARCHITECTURE, **DIAGRAMS** |
| Nueva integración o cambio de contrato | INTEGRATIONS, **DIAGRAMS** (diagrama de dependencias) |
| Cambio operativo (deploy, runbook) | OPERATIONS |
| Introducción de deuda técnica | TECHNICAL_DEBT_ROADMAP |
| Gap resuelto | GAPS (eliminar el item) |
| Cambio de estado del producto | PLATFORM_STATE |
| Nuevo hito de roadmap completado | PRODUCT_ROADMAP |
| Cambio en flujos P0/P1 o cobertura de tests | TESTING_STRATEGY |
| Cambio en modelo de datos | DIAGRAMS (diagrama ER) |
| Cambio en secuencia de componentes | DIAGRAMS (diagrama de secuencia) |

---

## Pull Requests

Todo PR debe responder:

1. Qué cambia.
2. Por qué cambia.
3. Qué impacto tiene.
4. Qué documentación se actualizó.
5. Qué evidencia valida el cambio.

Un PR que modifica comportamiento sin actualizar `/docs-system/` no está completo.

---

## Enforcement — tres capas

El framework tiene enforcement en tres niveles para que la disciplina no dependa solo de la voluntad del equipo:

| Capa | Cuándo actúa | Cómo |
|------|-------------|------|
| **pre-push hook** | Antes del push local | 5 checks: Jira ticket en branch, docs actualizado, bypass audit, tests, coverage P0. Escape: `git push -o skip-governance-check` |
| **CI docs-validation** | En el PR (GitHub Actions) | Mismo chequeo en el servidor. Escape: título del PR incluye `[skip-docs]` |
| **CI quality-gate** | En el PR (GitHub Actions) | Tests completos + bypass audit + coverage por criticidad de flujo |
| **CI release-readiness** | En PRs a main | Docs completos, sin P0 gaps, P0 flows con tests, sin bypasses |
| **CI weekly stale-docs** | Lunes 9am UTC (schedule) | Detecta drift entre docs y código, crea issue automáticamente |

Los escape hatches son intencionales: deben existir para no bloquear trabajo legítimo. La condición es que sean visibles — en el historial de commits o en el título del PR — y no silenciosos.

---

## Integración con Jira

Configurar `.governance/jira-config.sh` en cada repo (no commitear — contiene el token):

```bash
JIRA_BASE_URL="https://empresa.atlassian.net"
JIRA_PROJECT_KEY="STOCK"
JIRA_TOKEN="api-token"
JIRA_EMAIL="dev@empresa.com"
```

**Crear tickets desde GAPS.md y TECHNICAL_DEBT_ROADMAP.md:**

```bash
bash scripts/jira-sync.sh --dry-run   # preview
bash scripts/jira-sync.sh             # crear tickets reales
```

**Requerir ticket Jira en el branch** — agregar a `.governance/hook-config.sh`:

```bash
JIRA_PROJECT_KEY="STOCK"
```

El hook CHECK 0 bloqueará pushes desde branches sin ticket: `feature/STOCK-123-descripcion`. Branches exentos: main, master, develop, release/*, hotfix/*, chore/governance-*.

---

## Herramientas de operación

```bash
# Detectar drift entre docs y código
bash scripts/drift-detector.sh
bash scripts/drift-detector.sh --fix    # + abre issue en GitHub

# Ver estado de adopción en todos los repos
bash scripts/adoption-metrics.sh --repos-file repos.txt

# Subir docs a múltiples repos en bulk
bash scripts/bulk-push-docs.sh --repos-file repos.txt --pr
```

---

## HUMAN_ONLY

Algunos items en `GAPS.md` y `TECHNICAL_DEBT_ROADMAP.md` están marcados como `HUMAN_ONLY`.

Esto significa:
- Ningún agente de IA debe resolver ese item sin autorización explícita.
- La decisión involucra consecuencias operativas, de negocio, o de seguridad que requieren juicio humano.
- El agente debe presentar las opciones y esperar instrucción.

---

## Regla final

> Ningún cambio puede implementarse sin demostrar comprensión funcional del comportamiento que está modificando.
