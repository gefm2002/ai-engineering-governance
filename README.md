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
| **Windsurf** | `.windsurfrules` | [`adapters/windsurf.md`](adapters/windsurf.md) |
| **Cline / Roo** | `.clinerules` | [`adapters/cline.md`](adapters/cline.md) |
| **Aider** | `.aider.conf.yml` | [`adapters/aider.md`](adapters/aider.md) |

Todos los adapters implementan la misma regla core: [`rules/engineering-governance.md`](rules/engineering-governance.md).

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
