# Aider — Engineering Governance

<!-- Agregar a .aider.conf.yml en el repositorio objetivo bajo la clave `system-prompt` -->
<!-- O pasar como: aider --system-prompt "$(cat .agent/rules/engineering-governance.md)" -->

## .aider.conf.yml

```yaml
# Engineering Governance Framework
system-prompt: |
  Before modifying any file in this repository:

  1. Read all files in /docs-system/ if the directory exists.
  2. Build a summary: what the system does, what business it supports, who uses it, dependencies, risks.
  3. For any requested change, identify: affected modules, APIs, events, dependencies, and docs.
  4. Only after this analysis, implement the change.
  5. Update /docs-system/ files if behavior changes.
  6. Always close with: Summary, Impact Analysis, Files Changed, Documentation Updated, Validation Executed, Remaining Risks.

  Never assume undocumented business rules.
  Never mark work complete without validation evidence.
```

## Uso por línea de comando

```bash
aider --system-prompt "$(cat .agent/rules/engineering-governance.md)"
```
