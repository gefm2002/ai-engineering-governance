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

**¿Qué genera?** Hasta 12 documentos en `/docs-system/`:

**Requeridos** (todos los proyectos):

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

**Opcionales** (según necesidad del proyecto):

| Documento | Qué contiene |
|-----------|-------------|
| `PLATFORM_STATE.md` | Scorecard por área, bloqueadores activos |
| `PRODUCT_ROADMAP.md` | Fases con entregables y criterio de done |
| `PERFORMANCE_REPORT.md` | Mediciones before/after con metodología |
| `TESTING_STRATEGY.md` | Flujos vs cobertura real, bypasses documentados, gaps de testing |
| `DIAGRAMS.md` | Diagramas Mermaid: contexto, componentes, secuencias, data flow, dependencias, ER |

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

**Automatizar con CI y hooks:** El framework tiene tres capas de enforcement:

```
1. git pre-push hook (local)
   → bloquea el push si hay código cambiado sin docs-system actualizado
   → escape: git push -o skip-governance-check

2. ci/docs-validation-example.yml (PR)
   → mismo chequeo en el servidor, antes del merge

3. ci/quality-gate-example.yml (PR)
   → tests completos + bypass audit + coverage por criticidad de flujo
```

Ver la sección **CI y hooks** más abajo.

---

### Skills por disciplina embebidos en el framework

El framework ya incluye el criterio de múltiples disciplinas en su regla core. No necesitás invocar skills adicionales para que el agente analice el repo como lo haría un arquitecto, un QA o un tech lead — ese criterio está embebido en cada fase.

| Documento | Criterio embebido |
|-----------|------------------|
| `PRODUCT_SURFACE.md` | Product Manager técnico — capabilities reales vs documentadas |
| `USER_FLOW_MATRIX.md` | QA senior — flujos con criticidad, happy path + error paths |
| `ARCHITECTURE.md` | Arquitecto — decisiones con justificación, trade-offs, fragilidades |
| `INTEGRATIONS.md` | Backend senior — contratos reales, comportamiento en fallo |
| `TECHNICAL_DEBT_ROADMAP.md` | Tech lead — deuda intencional vs accidental, impacto real |
| `GAPS.md` | Code reviewer — qué falta vs qué está mal hecho |
| `TESTING_STRATEGY.md` | QA engineer — cobertura real, bypasses, flujos P0 sin test |
| `DIAGRAMS.md` | Arquitecto de sistemas — contexto, secuencias P0, dependencias con modo de fallo |

---

### Companion skills — para análisis más profundo

Si querés ir más lejos en un área específica, podés invocar el skill correspondiente *después* de cargar el contexto del framework. El agente ya entiende el sistema — el skill agrega profundidad de análisis en esa disciplina.

| Momento | Prompt de ejemplo |
|---------|------------------|
| Antes de Phase 0 en un repo complejo | `Lee /docs-system/ como contexto. Luego ejecutá /engineering:architecture para profundizar en ARCHITECTURE.md` |
| Evaluar deuda técnica | `Contexto en /docs-system/. Ejecutá /engineering:tech-debt para priorizar TECHNICAL_DEBT_ROADMAP.md` |
| Diseñar estrategia de testing | `Contexto en /docs-system/USER_FLOW_MATRIX.md. Ejecutá /engineering:testing-strategy para completar TESTING_STRATEGY.md` |
| Review de un PR con impacto en P0 | `Contexto en /docs-system/. Ejecutá /engineering:code-review — priorizá los flujos P0 de USER_FLOW_MATRIX.md` |
| Incident response | `Contexto en /docs-system/OPERATIONS.md y GAPS.md. Ejecutá /engineering:incident-response` |
| Diseño de nuevo componente | `Contexto en /docs-system/ARCHITECTURE.md. Ejecutá /engineering:system-design para proponer el cambio` |

**Regla:** el framework va primero siempre. El companion skill agrega profundidad, no reemplaza el contexto.

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

## CI y hooks

### Pre-push hook (gate local)

El hook bloquea el push antes de que llegue al servidor. Se instala automáticamente con `install.sh`.

**5 checks en secuencia:**

```
CHECK 0 — Jira ticket      → el branch debe incluir el ticket (ej: feature/PROJ-123-desc)
                              configurable via JIRA_PROJECT_KEY en .governance/hook-config.sh
CHECK 1 — docs-system      → código cambiado sin docs actualizado → bloqueado
CHECK 2 — bypass audit     → .skip, .only, tests vacíos, continue-on-error → bloqueado
CHECK 3 — full test suite  → tests fallan → bloqueado
CHECK 4 — coverage P0      → flujos P0 sin tests o coverage < 80% → bloqueado
```

**Configurar por repo** — crear `.governance/hook-config.sh`:

```bash
JIRA_PROJECT_KEY="STOCK"         # valida ticket en nombre del branch
TEST_CMD="npm test"
COVERAGE_CMD="npm run test:ci -- --coverage"
COVERAGE_FILE="coverage/coverage-summary.json"
COVERAGE_THRESHOLD=80
```

**Escape hatch** cuando el push es legítimo sin cumplir algún check:
```bash
git push -o skip-governance-check   # queda visible en el historial de git
```

---

## CI — Quality Gate

El framework incluye dos archivos de CI en `ci/`:

| Archivo | Qué hace |
|---------|----------|
| [`ci/docs-validation-example.yml`](ci/docs-validation-example.yml) | Bloquea el PR si hay código cambiado sin docs-system actualizado |
| [`ci/quality-gate-example.yml`](ci/quality-gate-example.yml) | Gate completo: tests + bypass audit + coverage P0 + docs |
| [`ci/release-readiness-example.yml`](ci/release-readiness-example.yml) | Gate en PRs a main: docs completos, sin P0 gaps, P0 flows con tests |
| [`ci/weekly-stale-docs.yml`](ci/weekly-stale-docs.yml) | Job semanal (lunes 9am): detecta drift y abre issue en GitHub automáticamente |

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

## Scripts de operación

### Jira sync — crear tickets desde GAPS y TECHNICAL_DEBT

```bash
# Configurar credenciales (no commitear este archivo — tiene el token)
cp templates/jira-config.sh .governance/jira-config.sh
# Editar: JIRA_BASE_URL, JIRA_PROJECT_KEY, JIRA_TOKEN, JIRA_EMAIL

bash scripts/jira-sync.sh --dry-run   # ver qué crearía
bash scripts/jira-sync.sh             # crear tickets reales
bash scripts/jira-sync.sh --source gaps   # solo gaps
bash scripts/jira-sync.sh --source debt   # solo deuda técnica
```

Mapeo: `GAP P0` → Bug (Highest), `GAP P1` → Story (High), `GAP P2/DEBT` → Task (Medium).
Items HUMAN_ONLY reciben label `human-only`. Idempotente — no duplica tickets existentes.

---

### Drift detector — docs vs código

```bash
bash scripts/drift-detector.sh           # reporte en terminal
bash scripts/drift-detector.sh --fix     # + abre issue en GitHub
```

Detecta: env vars documentadas pero eliminadas del código, docs con +30 días de atraso, flujos P0 sin tests, documentos con demasiados campos UNKNOWN.

---

### Métricas de adopción — estado de todos los repos

```bash
# repos.txt: una ruta local por línea
bash scripts/adoption-metrics.sh --repos-file repos.txt
bash scripts/adoption-metrics.sh --repos-file repos.txt --csv
```

Muestra tabla por repo: framework instalado, docs completos, hook activo, CI instalado, P0 tests cubiertos. Útil para ver el estado de adopción del equipo.

---

### Bulk push — subir docs a múltiples repos

```bash
bash scripts/bulk-push-docs.sh --repos-file repos.txt          # push directo a main
bash scripts/bulk-push-docs.sh --repos-file repos.txt --pr     # crear PR por repo
bash scripts/bulk-push-docs.sh --repos-file repos.txt --dry-run
```

Solo commitea `docs-system/`. Safety check aborta si hay archivos fuera de docs-system en el stage.

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
├── templates/                  ← templates para /docs-system y configuración
│   ├── PRODUCT_SURFACE.template.md
│   ├── USER_FLOW_MATRIX.template.md
│   ├── ARCHITECTURE.template.md
│   ├── INTEGRATIONS.template.md
│   ├── OPERATIONS.template.md
│   ├── TECHNICAL_DEBT_ROADMAP.template.md
│   ├── GAPS.template.md
│   ├── PLATFORM_STATE.template.md
│   ├── PRODUCT_ROADMAP.template.md
│   ├── PERFORMANCE_REPORT.template.md
│   ├── TESTING_STRATEGY.template.md
│   ├── DIAGRAMS.template.md
│   ├── ONBOARDING.template.md  ← guía para devs nuevos, generada desde docs-system
│   ├── CHANGELOG.template.md   ← historial de cambios, actualizado en Phase 5
│   ├── EVIDENCE_REPORT.template.md  ← artefacto de evidencia por sesión
│   ├── hook-config.sh          ← configuración del pre-push hook por repo
│   └── jira-config.sh          ← credenciales de Jira (no commitear)
│
├── examples/
│   └── docs-system/            ← docs-system completo de notifications-service
│       ├── 00_INDEX.md
│       ├── PRODUCT_SURFACE.md
│       ├── USER_FLOW_MATRIX.md
│       ├── ARCHITECTURE.md
│       ├── INTEGRATIONS.md
│       ├── OPERATIONS.md
│       ├── TECHNICAL_DEBT_ROADMAP.md
│       ├── GAPS.md
│       ├── PLATFORM_STATE.md
│       ├── PRODUCT_ROADMAP.md
│       ├── PERFORMANCE_REPORT.md
│       ├── TESTING_STRATEGY.md
│       └── DIAGRAMS.md
│
├── hooks/
│   └── pre-push                ← 5 checks: Jira ticket + docs + bypass + tests + coverage P0
│
├── scripts/
│   ├── jira-sync.sh            ← crea tickets Jira desde GAPS.md y TECHNICAL_DEBT_ROADMAP.md
│   ├── drift-detector.sh       ← detecta divergencia entre docs-system y el código
│   ├── adoption-metrics.sh     ← estado de adopción del framework en múltiples repos
│   └── bulk-push-docs.sh       ← pushea docs-system a múltiples repos
│
└── ci/
    ├── docs-validation-example.yml    ← bloquea PR sin docs actualizados
    ├── quality-gate-example.yml       ← tests + bypass audit + coverage P0 + docs
    ├── release-readiness-example.yml  ← gate en PRs a main
    └── weekly-stale-docs.yml          ← job semanal: detecta drift, abre issue
```

---

## Niveles de madurez

| Nivel | Nombre | Cómo se implementa |
|-------|--------|--------------------|
| 1 | Repository Understanding | `docs-system/` + Fase 0 |
| 2 | Impact Analysis | Fase 2 en la regla core — obligatoria antes de ejecutar |
| 3 | Documentation Governance | `hooks/pre-push` + `ci/docs-validation-example.yml` |
| 4 | Evidence Based QA | `templates/EVIDENCE_REPORT.template.md` + Fase 5 estructurada |
| 5 | Release Readiness | `ci/release-readiness-example.yml` — gate en PRs a main |
| 6 | AI-Enforced Governance | Sección "Verificación de precondiciones" en `rules/engineering-governance.md` |

Todos los niveles están implementados. La adopción es incremental — podés instalar el framework y activar los niveles de CI a medida que el equipo los necesite.
