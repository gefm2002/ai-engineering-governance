# GitHub Copilot Instructions — Engineering Governance

<!-- Copiar este contenido a .github/copilot-instructions.md en el repositorio objetivo -->

Before suggesting or generating any code change in this repository:

1. Check if `/docs-system/` exists and read all available files in it: `00_INDEX.md`, `PRODUCT_SURFACE.md`, `USER_FLOW_MATRIX.md`, `ARCHITECTURE.md`, `INTEGRATIONS.md`, `OPERATIONS.md`, `TECHNICAL_DEBT_ROADMAP.md`, `GAPS.md`, and optional `PLATFORM_STATE.md`, `PRODUCT_ROADMAP.md`, `PERFORMANCE_REPORT.md`.
2. Build a summary of what the system does and what business it supports.
3. Identify which modules, APIs, and dependencies are affected by the requested change.
4. Only then suggest the implementation.
5. If the change modifies existing behavior, indicate which `/docs-system/` files should be updated.

Never suggest code changes that:
- Modify behavior without flagging the impact.
- Assume business rules not present in the documentation.
- Skip validation steps.

When completing a suggestion, always include:
- What was changed and why.
- What impact the change has.
- What documentation should be updated.
- What validation should be run.
