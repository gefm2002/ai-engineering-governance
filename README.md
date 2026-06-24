# AI Engineering Governance Framework

> La IA puede generar código.  
> No puede inferir contexto de negocio que no existe.  
> Este framework fuerza entendimiento del repositorio antes de cualquier modificación.

---

## Concepto

El framework resuelve un problema concreto: **los agentes de IA modifican código sin entender el sistema**.

La solución es simple: antes de tocar código, el agente debe leer documentación que explique qué hace el sistema, qué reglas de negocio tiene, y qué impacto tiene cada cambio.

Esa documentación vive en `/docs-system/` — una carpeta dentro de cada repositorio que el agente lee como primer paso de cualquier sesión.

---

## Cómo se usa — los dos momentos

### Momento 1 — Primera vez en un repo (documentar el estado actual)

Instalás el framework y el agente documenta el repo desde cero.

**Paso 1:** Instalar el framework en el repositorio.

```bash
# Opción terminal — una línea
curl -fsSL https://raw.githubusercontent.com/gefm2002/ai-engineering-governance/main/install.sh | bash

# Opción terminal — control total
git clone https://github.com/gefm2002/ai-engineering-governance.git /tmp/governance
cd /tu-repositorio
bash /tmp/governance/install.sh
```

Esto instala los adapters para tu herramienta de IA y crea `/docs-system/` con templates vacíos.

**Paso 2:** Pedirle al agente que ejecute la Fase 0.

```
Ejecutá la Fase 0 del Engineering Governance Framework.
No modifiques código.
Leé el repositorio y completá todos los archivos de /docs-system/ con el estado actual.
```

El agente lee el código fuente, infiere el comportamiento real del sistema, y genera los documentos. Los `UNKNOWN` se reemplazan con información real.

**¿Qué genera?** 10 documentos en `/docs-system/`:

| Documento | Qué contiene |
|-----------|-------------|
| `00_INDEX.md` | Tabla de contenido con estado de completitud |
| `PRODUCT_SURFACE.md` | Capabilities reales, actores, reglas de negocio |
| `USER_FLOW_MATRIX.md` | Flujos con criticidad P0/P1/P2/P3 |
| `ARCHITECTURE.md` | Stack, estructura, decisiones técnicas |
| `INTEGRATIONS.md` | APIs, env vars, contratos |
| `OPERATIONS.md` | Build, deploy, runbooks |
| `TECHNICAL_DEBT_ROADMAP.md` | Deuda activa / cerrada / HUMAN_ONLY |
| `GAPS.md` | Items abiertos que bloquean |
| `PLATFORM_STATE.md` | Scorecard por área, bloqueadores |
| `PRODUCT_ROADMAP.md` | Fases con criterio de done |
| `PERFORMANCE_REPORT.md` | Mediciones y cuellos de botella |

**Verificar que funciona:**
```
Ejecutá la Fase 0 del Engineering Governance Framework.
No modifiques código.
Leé /docs-system y generá un Repository Summary.
```
Si el agente genera un summary coherente con el sistema, el framework está operativo.

---

### Momento 2 — Uso diario (hacer cambios con contexto)

Cada vez que abrís una sesión nueva para modificar el repo, el agente carga el contexto antes de actuar.

**Cómo funciona en la práctica:**

```
┌─────────────────────────────────────────────────────────────┐
│  SESIÓN DE TRABAJO                                          │
│                                                             │
│  1. Cargás /docs-system/ como contexto                      │
│     → el agente entiende el sistema antes de tocar código   │
│                                                             │
│  2. Pedís el cambio                                         │
│     → el agente analiza el impacto antes de ejecutar        │
│                                                             │
│  3. El agente implementa                                     │
│     → con evidencia de validación (tests, build)            │
│                                                             │
│  4. El agente actualiza /docs-system/                       │
│     → si el comportamiento cambió, los docs reflejan el     │
│       nuevo estado — en el mismo PR                         │
└─────────────────────────────────────────────────────────────┘
```

**Prompt de inicio de sesión:**

```
Lee /docs-system/ como contexto antes de hacer cualquier cambio.
Cuando hagas una modificación, si el comportamiento cambia, actualizá
el archivo correspondiente de /docs-system/ en el mismo commit.
```

**Prompt para un cambio específico:**

```
Contexto en /docs-system/.
Tarea: [describir el cambio].
Antes de implementar, mostrá el Impact Analysis.
Si el cambio modifica comportamiento existente, actualizá /docs-system/.
```

**El agente responde con:**

```
## Summary
[qué se hizo]

## Impact Analysis
[qué módulos, APIs, flujos afecta]

## Files Changed
[lista de archivos de código modificados]

## Documentation Updated
[qué docs de /docs-system/ se actualizaron y por qué]

## Validation Executed
[tests / build / lint corridos con resultado]

## Remaining Risks
[qué no se pudo validar]
```

---

### Momento 3 — Evaluación y plan de trabajo (sin tocar código)

Cuando querés entender el estado real del repo, identificar qué está roto o en deuda, y definir qué trabajar primero — sin necesariamente hacer cambios.

**Cómo funciona en la práctica:**

```
┌─────────────────────────────────────────────────────────────┐
│  SESIÓN DE PLANIFICACIÓN                                    │
│                                                             │
│  1. Cargás /docs-system/ como contexto                      │
│     → el agente lee GAPS, TECHNICAL_DEBT_ROADMAP,           │
│       PLATFORM_STATE, PRODUCT_ROADMAP                       │
│                                                             │
│  2. El agente evalúa el estado actual                       │
│     → cruza gaps, deuda, scorecard y roadmap                │
│     → identifica qué bloquea qué                            │
│                                                             │
│  3. El agente genera un plan de trabajo                     │
│     → priorizado, con dependencias explícitas               │
│     → separa lo que puede hacer solo de lo que              │
│       requiere decisión humana (HUMAN_ONLY)                 │
└─────────────────────────────────────────────────────────────┘
```

**Prompt para evaluación y plan:**

```
Leé /docs-system/ completo. No modifiques código ni documentación.

Con base en GAPS.md, TECHNICAL_DEBT_ROADMAP.md, PLATFORM_STATE.md
y PRODUCT_ROADMAP.md, generá un plan de trabajo priorizado que incluya:

1. Estado actual del sistema (resumen ejecutivo)
2. Qué está bloqueando qué (dependencias entre gaps y deuda)
3. Plan de trabajo ordenado por impacto/esfuerzo
4. Qué items requieren decisión humana antes de poder ejecutarse (HUMAN_ONLY)
5. Qué podés ejecutar vos directamente en la próxima sesión
```

**El agente responde con:**

```
## Estado actual
[resumen del scorecard de PLATFORM_STATE — qué está 🟢/🟡/🔴]

## Mapa de dependencias
[qué gaps bloquean qué items de roadmap, qué deuda bloquea qué gaps]

## Plan de trabajo — ordenado por impacto/esfuerzo
| Prioridad | Item | Tipo | Esfuerzo | Bloquea |
|-----------|------|------|----------|---------|
| 1 | ...  | Gap/Deuda/Roadmap | Alto/Medio/Bajo | ... |

## Requiere decisión humana antes de ejecutar (HUMAN_ONLY)
[lista de items de GAPS.md marcados como HUMAN_ONLY con contexto]

## Podés pedirme en la próxima sesión
[lista de cambios concretos que el agente puede implementar directamente
 una vez que los HUMAN_ONLY estén resueltos]
```

**Cuándo usar este momento:**
- Al empezar un sprint o ciclo de trabajo
- Cuando recibís un repo sin contexto y necesitás entender por dónde empezar
- Antes de planificar refactors o migraciones
- Cuando querés priorizar deuda técnica sin sesgarte por lo más visible

---

### Momento 4 — Re-sincronización de docs (deuda de documentación)

Cuando el código evolucionó en varias sesiones y los docs quedaron desactualizados. Pasa siempre — la pregunta no es si va a pasar, sino cuándo detectarlo y corregirlo.

**Señales de que los docs están stale:**
- Un agente genera código que contradice lo documentado en `/docs-system/`
- `GAPS.md` tiene items que ya fueron resueltos pero no eliminados
- Un runbook describe un proceso que ya no existe en el código
- Alguien nuevo al repo encuentra información incorrecta

**Prompt para re-sincronización:**

```
Leé /docs-system/ completo y compará con el estado actual del código.
No modifiques código.

Para cada documento, indicá:
- Qué información está desactualizada respecto al código real
- Qué falta documentar que ya existe en el código
- Qué está documentado pero ya no existe en el código

Luego actualizá solo los documentos que no reflejan el comportamiento real.
```

**El agente entrega primero un diagnóstico, después actualiza:**

```
## Diagnóstico de stale docs
| Documento | Estado | Qué cambió |
|-----------|--------|------------|
| ARCHITECTURE.md | ⚠️ Desactualizado | Nuevo módulo X no documentado |
| GAPS.md | ⚠️ Desactualizado | GAP-002 ya resuelto en PR #201 |
| INTEGRATIONS.md | ✅ Al día | — |

## Cambios aplicados
[lista de updates realizados con justificación]
```

**Cuándo hacerlo:** Al inicio de un sprint, antes de una sesión de cambios importantes, o cuando el equipo siente que "los docs no reflejan lo que hay".

**Automatizar con CI:** El `ci/docs-validation-example.yml` bloquea un PR si hay cambios de código sin cambios en `/docs-system/`. El `ci/quality-gate-example.yml` va más lejos — corre los tests completos, detecta bypasses, y audita cobertura por flujo P0. Ver la sección CI más abajo.

---

### Combinación con otros skills

Este framework no reemplaza otros skills — los **potencia**. El framework provee contexto del sistema; los otros skills proveen capacidad especializada. Se usan en capas.

**Cómo funciona:**

```
┌──────────────────────────────────────────────────────────────┐
│  ESTE FRAMEWORK                                              │
│  "qué es el sistema, qué reglas tiene, qué impacta qué"     │
│                          +                                   │
│  OTRO SKILL                                                  │
│  "cómo ejecutar esa tarea específica con profundidad"        │
└──────────────────────────────────────────────────────────────┘
```

**Ejemplos de combinación:**

```
# Code review con contexto de negocio
Leé /docs-system/ como contexto.
Luego ejecutá /code-review sobre los cambios de este PR.
Considerá el impacto en los flujos documentados en USER_FLOW_MATRIX.md.
```

```
# Tech debt con contexto del roadmap
Leé /docs-system/TECHNICAL_DEBT_ROADMAP.md y PRODUCT_ROADMAP.md.
Luego ejecutá /engineering:tech-debt para priorizar qué resolver primero.
```

```
# Diseño de arquitectura con contexto del sistema actual
Leé /docs-system/ARCHITECTURE.md e INTEGRATIONS.md.
Luego ejecutá /engineering:architecture para proponer el cambio.
Cualquier propuesta que contradiga las decisiones documentadas en ARCHITECTURE.md
debe justificarse explícitamente.
```

```
# Testing strategy con contexto de flujos críticos
Leé /docs-system/USER_FLOW_MATRIX.md — los flujos P0 son los que no pueden fallar.
Luego ejecutá /engineering:testing-strategy priorizando cobertura de esos flujos.
```

```
# Incident response con contexto operativo
Leé /docs-system/OPERATIONS.md y GAPS.md antes de diagnosticar.
Luego ejecutá /engineering:incident-response.
Los runbooks en OPERATIONS.md son el punto de partida.
```

**Regla de combinación:**

El framework siempre va primero — carga el contexto antes de que el otro skill actúe. Si el skill genera recomendaciones que contradicen lo documentado en `/docs-system/`, esa contradicción debe resolverse explícitamente antes de implementar.

---

## Instalación — opciones completas

### Opción A — Terminal (una línea)

```bash
curl -fsSL https://raw.githubusercontent.com/gefm2002/ai-engineering-governance/main/install.sh | bash
```

### Opción B — Terminal (control total)

```bash
git clone https://github.com/gefm2002/ai-engineering-governance.git /tmp/governance
cd /tu-repositorio

bash /tmp/governance/install.sh                      # instala todo
bash /tmp/governance/install.sh --tool cursor        # solo Cursor
bash /tmp/governance/install.sh --tool claude        # solo Claude Code
bash /tmp/governance/install.sh --no-docs            # sin crear /docs-system
bash /tmp/governance/install.sh --dry-run            # ver qué haría sin ejecutar
```

### Opción C — El agente lo instala solo

```
Leé https://github.com/gefm2002/ai-engineering-governance/blob/main/AGENT_BOOTSTRAP.md
y seguí las instrucciones de instalación automática en este repositorio.
```

---

## Herramientas soportadas

| Herramienta | Archivo instalado | Adapter |
|-------------|------------------|---------|
| **Cursor** | `.cursor/rules/engineering-governance.mdc` | [`adapters/cursor.mdc`](adapters/cursor.mdc) |
| **GitHub Copilot** | `.github/copilot-instructions.md` | [`adapters/copilot.md`](adapters/copilot.md) |
| **Claude Code** | `CLAUDE.md` | [`adapters/claude.md`](adapters/claude.md) |
| **OpenAI Codex** | `AGENTS.md` | [`adapters/codex.md`](adapters/codex.md) |
| **Windsurf** | `.windsurfrules` | [`adapters/windsurf.md`](adapters/windsurf.md) |
| **Cline / Roo** | `.clinerules` | [`adapters/cline.md`](adapters/cline.md) |
| **Aider** | `.aider.conf.yml` | [`adapters/aider.md`](adapters/aider.md) |

Todos los adapters implementan la misma regla core: [`rules/engineering-governance.md`](rules/engineering-governance.md).

---

## CI — Quality Gate

El framework incluye dos archivos de CI en `ci/`:

| Archivo | Qué hace |
|---------|----------|
| [`ci/docs-validation-example.yml`](ci/docs-validation-example.yml) | Bloquea el PR si hay código cambiado sin docs-system actualizado |
| [`ci/quality-gate-example.yml`](ci/quality-gate-example.yml) | Gate completo: tests + bypass audit + coverage + docs |

### El quality gate tiene 5 jobs

```
Job 1 — Bypass audit       → detecta .skip, .only, continue-on-error,
                              tests vacíos, fake assertions, --passWithNoTests
Job 2 — Full test suite    → corre los tests SIN continue-on-error
                              si fallan, el PR no puede mergearse
Job 3 — Coverage audit     → coverage mínimo según criticidad de flujos
                              P0 exige 80%, P1 exige 60%
Job 4 — Docs validation    → docs-system actualizado si el código cambió
Job 5 — Quality summary    → resultado consolidado del gate
```

### Cómo instalar

```bash
cp ci/quality-gate-example.yml .github/workflows/quality-gate.yml
# Ajustar en el yml: TEST_CMD, COVERAGE_CMD, COVERAGE_FILE según tu stack
```

### Escape hatches (documentados, no silenciosos)

| Escape | Cómo usarlo | Cuándo aplica |
|--------|-------------|---------------|
| `[skip-docs]` en título del PR | Omite validación de docs | Refactor interno sin cambio de comportamiento |
| `[skip-tests]` en título del PR | Omite el test suite | Nunca debería ser necesario — si los tests fallan, arreglarlos |

Cualquier uso de escape hatch debe quedar visible en el historial de PRs como decisión consciente.

---

## Las 5 fases

```
Fase 0 — Context Bootstrap     → leer /docs-system/ completo
Fase 1 — Repository Summary    → construir entendimiento del sistema
Fase 2 — Impact Analysis       → identificar qué afecta el cambio pedido
Fase 3 — Execute               → implementar con validaciones
Fase 4 — Documentation         → actualizar /docs-system/ si el comportamiento cambia
Fase 5 — Close                 → entregar evidencia: summary, impact, files, docs, validation, risks
```

Ver el framework completo en [`ENGINEERING_GOVERNANCE.md`](ENGINEERING_GOVERNANCE.md).

---

## Estructura del repositorio

```
/
├── README.md                   ← este archivo
├── AGENT_BOOTSTRAP.md          ← entrada para agentes de IA (auto-instalación)
├── ENGINEERING_GOVERNANCE.md   ← framework completo para humanos y equipos
├── install.sh                  ← instalación por terminal
│
├── rules/
│   └── engineering-governance.md   ← regla core agnóstica (todas las fases)
│
├── adapters/
│   ├── cursor.mdc              ← Cursor (.cursor/rules/)
│   ├── copilot.md              ← GitHub Copilot (.github/copilot-instructions.md)
│   ├── claude.md               ← Claude Code (CLAUDE.md)
│   ├── codex.md                ← OpenAI Codex (AGENTS.md)
│   ├── windsurf.md             ← Windsurf (.windsurfrules)
│   ├── cline.md                ← Cline / Roo (.clinerules)
│   └── aider.md                ← Aider (.aider.conf.yml)
│
├── templates/                  ← templates para /docs-system (11 archivos)
│   ├── PRODUCT_SURFACE.template.md
│   ├── USER_FLOW_MATRIX.template.md
│   ├── ARCHITECTURE.template.md
│   ├── INTEGRATIONS.template.md
│   ├── OPERATIONS.template.md
│   ├── TECHNICAL_DEBT_ROADMAP.template.md
│   ├── GAPS.template.md
│   ├── PLATFORM_STATE.template.md
│   ├── PRODUCT_ROADMAP.template.md
│   └── PERFORMANCE_REPORT.template.md
│
├── examples/
│   └── docs-system/            ← ejemplo de /docs-system documentado
│
└── ci/
    └── docs-validation-example.yml  ← CI que bloquea código sin docs actualizados
```

---

## Niveles de madurez

| Nivel | Nombre | Estado |
|-------|--------|--------|
| 1 | Repository Understanding | ✅ este framework |
| 2 | Impact Analysis | ✅ incluido en el framework |
| 3 | Documentation Governance | con CI (`ci/docs-validation-example.yml`) |
| 4 | Evidence Based QA | a construir |
| 5 | Release Readiness | a construir |
| 6 | AI-Enforced Governance | a construir |
