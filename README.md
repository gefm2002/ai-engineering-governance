# AI Engineering Governance Framework

> AI can generate code.  
> AI cannot infer business context that does not exist.  
> This framework forces repository understanding before repository modification.

---

## El problema

En equipos con múltiples repositorios, el uso de IA sin contexto produce:

- Cambios sin comprensión del negocio.
- Regresiones en flujos críticos.
- Pérdida de conocimiento organizacional.
- Documentación ausente o desactualizada.

## La solución

Un framework de gobernanza que obliga a entender antes de modificar.

## Estructura del repo

```
/
├── README.md
├── ENGINEERING_GOVERNANCE.md       ← Framework completo para compartir con el equipo
├── examples/
│   ├── docs-system/                ← Ejemplo de documentación baseline
│   └── sample-repository/          ← Ejemplo de repo documentado
├── cursor/
│   ├── engineering-governance.mdc  ← Cursor Rule para aplicar en cada repo
│   └── bootstrap-docs.md           ← Comando para generar docs-system
├── templates/
│   ├── PRODUCT_SURFACE.template.md
│   ├── FLOW_MATRIX.template.md
│   ├── ARCHITECTURE.template.md
│   ├── INTEGRATIONS.template.md
│   ├── OPERATIONS.template.md
│   ├── TECHNICAL_DEBT.template.md
│   └── RELEASE_STATE.template.md
└── ci/
    └── docs-validation-example.yml ← Ejemplo de validación en CI
```

## Cómo usar

### Paso 1 — Aplicar la Cursor Rule globalmente

Copiar el contenido de `cursor/engineering-governance.mdc` en:

```
Cursor → Settings → Rules → User Rules
```

Esto aplica el framework a **todos** los repos.

### Paso 2 — Documentar un repo existente

Abrir el repo en Cursor y ejecutar:

```
Aplicá únicamente la Fase 0 del Engineering Governance Framework.

No modifiques código.

Generá la estructura /docs-system.

Documentá el estado actual.

Marcá UNKNOWN cuando no puedas inferir información.

Abrí un PR exclusivamente documental.
```

### Paso 3 — Validar el resultado

Verificar que el PR generado:

- No modifica código.
- Crea `/docs-system` con todos los archivos requeridos.
- Usa `UNKNOWN` donde no puede inferir información.
- Describe el sistema con precisión.

### Paso 4 — Agregar CI (opcional, después de validar)

Ver `ci/docs-validation-example.yml` para una validación que falla si cambia código sin actualizar docs.

---

## Niveles de madurez

| Nivel | Nombre | Descripción |
|-------|--------|-------------|
| 1 | Repository Understanding | Documentar antes de modificar |
| 2 | Impact Analysis | Analizar impacto antes de ejecutar |
| 3 | Documentation Governance | Mantener docs sincronizadas con código |
| 4 | Evidence Based QA | Validar con evidencia, no con opinión |
| 5 | Release Readiness | Release gates documentados |
| 6 | AI-Enforced Governance | CI bloquea cambios sin contexto |

## Hoja de ruta sugerida

**Semana 1**
- Crear repo público con framework.
- Aplicar Cursor Rule global.
- Documentar 1 repo existente (solo docs, sin código).

**Después de validar**
- Extender a más repos.
- Agregar CI/hooks de validación.
- Enforcement en PR templates.
