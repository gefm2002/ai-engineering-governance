# AI Engineering Governance Framework

> AI can generate code.  
> AI cannot infer business context that does not exist.  
> This framework forces repository understanding before repository modification.

---

## Instalación

### Opción A — Terminal (una línea)

```bash
curl -fsSL https://raw.githubusercontent.com/gefm2002/ai-engineering-governance/main/install.sh | bash
```

Instala todos los adapters y crea `/docs-system` con templates vacíos.

### Opción B — Terminal (solo una herramienta)

```bash
# Clonar el framework
git clone https://github.com/gefm2002/ai-engineering-governance.git /tmp/governance

# Ir al repo donde querés instalar
cd /tu-repositorio

# Instalar solo para Cursor
bash /tmp/governance/install.sh --tool cursor

# Instalar solo para Claude Code
bash /tmp/governance/install.sh --tool claude

# Instalar sin crear /docs-system
bash /tmp/governance/install.sh --no-docs

# Ver qué haría sin ejecutar nada
bash /tmp/governance/install.sh --dry-run
```

### Opción C — El agente lo instala solo

Decirle al agente activo:

```
Leé https://github.com/gefm2002/ai-engineering-governance/blob/main/AGENT_BOOTSTRAP.md
y seguí las instrucciones de instalación automática en este repositorio.
```

El agente lee [`AGENT_BOOTSTRAP.md`](AGENT_BOOTSTRAP.md), determina qué herramienta está activa e instala el adapter correspondiente.

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

## Cómo funciona

El framework impone una secuencia antes de cualquier modificación de código:

```
Fase 0 — Context Bootstrap     → leer /docs-system/
Fase 1 — Repository Summary    → entender el sistema
Fase 2 — Impact Analysis       → analizar el cambio
Fase 3 — Execute               → implementar
Fase 4 — Documentation         → actualizar docs si el comportamiento cambia
Fase 5 — Close                 → entregar evidencia
```

Ver el framework completo en [`ENGINEERING_GOVERNANCE.md`](ENGINEERING_GOVERNANCE.md).

---

## Probar que funciona

Después de instalar, pedirle al agente:

```
Ejecutá la Fase 0 del Engineering Governance Framework.
No modifiques código.
Leé /docs-system y generá un Repository Summary.
```

Si el agente genera un summary coherente con el sistema, el framework está operativo.

---

## Estructura del repositorio

```
/
├── AGENT_BOOTSTRAP.md          ← entrada para agentes de IA (auto-instalación)
├── ENGINEERING_GOVERNANCE.md   ← framework completo para humanos y equipos
├── install.sh                  ← instalación por terminal
│
├── rules/
│   └── engineering-governance.md   ← regla core agnóstica
│
├── adapters/
│   ├── cursor.mdc              ← Cursor
│   ├── copilot.md              ← GitHub Copilot
│   ├── claude.md               ← Claude Code
│   ├── windsurf.md             ← Windsurf
│   ├── cline.md                ← Cline / Roo
│   └── aider.md                ← Aider
│
├── templates/                  ← templates para /docs-system
│   ├── PRODUCT_SURFACE.template.md
│   ├── FLOW_MATRIX.template.md
│   ├── ARCHITECTURE.template.md
│   ├── INTEGRATIONS.template.md
│   ├── OPERATIONS.template.md
│   ├── TECHNICAL_DEBT.template.md
│   └── RELEASE_STATE.template.md
│
├── examples/
│   └── docs-system/            ← ejemplo de /docs-system documentado
│
└── ci/
    └── docs-validation-example.yml  ← CI que bloquea código sin docs
```

---

## Niveles de madurez

| Nivel | Nombre | Estado |
|-------|--------|--------|
| 1 | Repository Understanding | ← este framework |
| 2 | Impact Analysis | ← incluido en el framework |
| 3 | Documentation Governance | con CI |
| 4 | Evidence Based QA | a construir |
| 5 | Release Readiness | a construir |
| 6 | AI-Enforced Governance | a construir |
