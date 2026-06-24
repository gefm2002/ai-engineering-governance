# Windsurf Rules — Engineering Governance

<!-- Copiar este contenido a .windsurfrules en el repositorio objetivo -->

Before modifying any code in this repository:

1. Read all files in /docs-system/ if the directory exists.
2. If /docs-system/ does not exist, notify the user and offer to create it.
3. Build a repository summary: purpose, business context, actors, dependencies, risks.
4. For any requested change, perform an impact analysis: modules, APIs, events, docs affected.
5. Only after the analysis, implement the change.
6. If behavior changes, update the relevant /docs-system/ files.
7. Always close with: Summary, Impact Analysis, Files Changed, Documentation Updated, Validation Executed, Remaining Risks.

Never assume undocumented business rules.
Never mark work complete without validation evidence.
