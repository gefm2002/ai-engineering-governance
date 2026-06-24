# Claude Code — Engineering Governance

<!-- Agregar esta sección a CLAUDE.md en el repositorio objetivo -->
<!-- Si no existe CLAUDE.md, crear el archivo con este contenido -->

# Engineering Governance

Before making any change to this repository:

## Required sequence

**Phase 0 — Read documentation**

Read all files in `/docs-system/` before touching any code:
- `00_INDEX.md`, `PRODUCT_SURFACE.md`, `USER_FLOW_MATRIX.md`, `ARCHITECTURE.md`
- `INTEGRATIONS.md`, `OPERATIONS.md`, `TECHNICAL_DEBT_ROADMAP.md`, `GAPS.md`
- If present: `PLATFORM_STATE.md`, `PRODUCT_ROADMAP.md`, `PERFORMANCE_REPORT.md`

If the directory does not exist, stop and offer to create it.

**Phase 1 — Understand**

Before executing any task, derive:
- What does this system do?
- What business does it support?
- Who uses it?
- What are the critical dependencies?

**Phase 2 — Analyze impact**

For any requested change, identify:
- Which modules are affected?
- Which APIs are affected?
- Which events or side effects are triggered?
- Which documentation must be updated?

**Phase 3 — Execute**

Only after the analysis is complete. Run tests and validations. Do not declare done without evidence.

**Phase 4 — Update docs**

If behavior changes, update `/docs-system/` accordingly.

**Phase 5 — Report**

Always close with:
- Summary
- Impact Analysis
- Files Changed
- Documentation Updated
- Validation Executed
- Remaining Risks

## Constraints

- Never assume business rules not present in documentation.
- Never invent integration details.
- Never skip the impact analysis for changes that affect existing behavior.
- Never mark work complete without validation evidence.
