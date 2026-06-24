# Cline / Roo Rules — Engineering Governance

<!-- Copiar este contenido a .clinerules en el repositorio objetivo -->

Engineering Governance Framework is active in this repository.

Before any code modification:

STEP 1 - Read /docs-system/ directory completely.
If it does not exist, stop and offer to create it using bootstrap-docs procedure.

STEP 2 - Generate repository summary:
- System purpose
- Business context
- Key actors
- Critical dependencies
- Main risks

STEP 3 - Impact analysis for the requested change:
- Modules affected
- APIs affected
- Events affected
- Dependencies affected
- Docs that must be updated

STEP 4 - Execute change only after steps 1-3 are complete.
Run available tests and validations.

STEP 5 - Update /docs-system/ files if behavior changes.

STEP 6 - Deliver closing report:
Summary / Impact Analysis / Files Changed / Documentation Updated / Validation Executed / Remaining Risks

CONSTRAINTS:
Do not assume undocumented business rules.
Do not invent system information.
Do not mark complete without validation evidence.
