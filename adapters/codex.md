# OpenAI Codex — Engineering Governance

<!-- Copiar este contenido a AGENTS.md en el repositorio objetivo -->
<!-- Si ya existe AGENTS.md, agregar esta sección al final -->

# Engineering Governance

Before making any change to this repository:

## Required sequence

**Phase 0 — Read documentation**

Read all files in `/docs-system/` before touching any code:
- `00_INDEX.md`, `PRODUCT_SURFACE.md`, `USER_FLOW_MATRIX.md`, `ARCHITECTURE.md`
- `INTEGRATIONS.md`, `OPERATIONS.md`, `TECHNICAL_DEBT_ROADMAP.md`, `GAPS.md`
- If present: `PLATFORM_STATE.md`, `PRODUCT_ROADMAP.md`, `PERFORMANCE_REPORT.md`, `TESTING_STRATEGY.md`

If `/docs-system/` does not exist, stop and offer to create it.

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
- Which flows from USER_FLOW_MATRIX are affected, and what is their criticality?
- Which documentation must be updated?

**Phase 3 — Execute**

Only after the analysis is complete.
Run tests at the level required by the criticality of the affected flows:
- P0 flow affected → integration test required
- P1 flow affected → unit test of happy path required
Do not declare done without evidence.

**Phase 4 — Update docs**

If behavior changes, update `/docs-system/` accordingly.
If a gap is resolved, remove it from `GAPS.md`.

**Phase 5 — Report**

Always close with:
- Summary
- Impact Analysis
- Files Changed
- Documentation Updated
- Validation Executed (tests run, coverage, flows covered)
- Remaining Risks

## Constraints

- Never assume business rules not present in documentation.
- Never invent integration details.
- Never skip the impact analysis for changes that affect existing behavior.
- Never mark work complete without validation evidence.
- Never use .skip(), .only(), or empty test bodies.
- Never resolve HUMAN_ONLY items in GAPS.md without explicit authorization.
