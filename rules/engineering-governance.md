# Engineering Governance — Core Rule

> Regla agnóstica. Válida para cualquier agente de IA.
> Los adapters en `/adapters/` traducen esta regla al formato nativo de cada herramienta.

---

## Regla principal

Antes de modificar cualquier archivo de código en este repositorio:

1. Leer la documentación disponible en `/docs-system/`.
2. Construir un entendimiento del sistema.
3. Realizar un análisis de impacto del cambio solicitado.
4. Recién entonces ejecutar el cambio.
5. Actualizar documentación si el comportamiento cambia.
6. Reportar evidencia de validación.

**No existe excepción a esta secuencia.**

---

## Fase 0 — Context Bootstrap

Buscar y leer, en orden:

```
/docs-system/00_INDEX.md
/docs-system/PRODUCT_SURFACE.md
/docs-system/USER_FLOW_MATRIX.md
/docs-system/ARCHITECTURE.md
/docs-system/INTEGRATIONS.md
/docs-system/OPERATIONS.md
/docs-system/TECHNICAL_DEBT_ROADMAP.md
/docs-system/GAPS.md
```

Documentos opcionales si existen:
```
/docs-system/PLATFORM_STATE.md
/docs-system/PRODUCT_ROADMAP.md
/docs-system/PERFORMANCE_REPORT.md
```

Si algún archivo no existe: continuar con los disponibles y registrar qué falta.  
Si `/docs-system/` no existe: notificar al usuario y ofrecer crearlo con la Fase 0.

**No modificar código hasta completar esta fase.**

---

## Fase 1 — Repository Summary

Generar internamente (no necesariamente mostrar, pero sí tener disponible):

```
Sistema: [nombre]
Propósito: [qué hace]
Negocio que soporta: [qué área / proceso]
Actores: [quién lo usa]
Dependencias críticas: [qué rompe si falla]
Riesgos principales: [qué puede salir mal]
```

---

## Fase 2 — Impact Analysis

Para cualquier cambio solicitado, antes de ejecutarlo:

```
Cambio solicitado: [descripción]
Módulos afectados: [lista]
APIs afectadas: [lista]
Eventos afectados: [lista]
Dependencias afectadas: [lista]
Documentación que debe actualizarse: [lista]
Riesgos del cambio: [lista]
```

Si el análisis revela riesgos no contemplados en la solicitud, comunicarlos antes de continuar.

---

## Fase 3 — Ejecución

Solo después de completar Fases 0, 1 y 2:

- Implementar el cambio.
- Ejecutar validaciones disponibles (tests, builds, linters).
- No declarar el cambio como completo sin evidencia.

---

## Fase 4 — Documentación

Si el cambio modifica comportamiento observable:

Actualizar los archivos de `/docs-system/` que correspondan:

| Tipo de cambio | Documentos a actualizar |
|----------------|------------------------|
| Nueva funcionalidad | PRODUCT_SURFACE, USER_FLOW_MATRIX |
| Cambio de arquitectura | ARCHITECTURE, DIAGRAMS |
| Nueva integración / cambio de contrato | INTEGRATIONS, DIAGRAMS |
| Cambio operativo | OPERATIONS |
| Introducción de deuda técnica | TECHNICAL_DEBT_ROADMAP |
| Gap resuelto | GAPS (eliminar el item cerrado) |
| Cambio de estado del producto | PLATFORM_STATE |
| Nuevo hito de roadmap | PRODUCT_ROADMAP |
| Cambio en cobertura o flujos P0/P1 | TESTING_STRATEGY |
| Cambio en modelo de datos o secuencias | DIAGRAMS |

---

## Fase 5 — Cierre y evidencia

Siempre entregar al finalizar. Si existe `.governance/evidence/`, crear un archivo `YYYY-MM-DD-{short-hash}.md` usando el template `templates/EVIDENCE_REPORT.template.md`. Si no existe esa carpeta, entregar el reporte en el chat con esta estructura:

```
## Summary
[qué se hizo]

## Impact Analysis
[módulos, APIs, flujos afectados]

## Files Changed
[lista de archivos de código modificados]

## Documentation Updated
[lista de docs de /docs-system/ actualizados, o "ninguno requerido" con justificación]

## Validation Executed
Comando: [comando exacto que se corrió]
Resultado: [N passed, N failed, N skipped]
Cobertura total: N%
Cobertura flujos P0 afectados: N%

## Bypasses presentes
[lista con justificación, o "Ninguno"]

## Remaining Risks
[qué no se pudo validar y por qué]

## Criterio de done
- [ ] Tests pasan sin continue-on-error
- [ ] No hay bypasses nuevos sin documentar
- [ ] Coverage flujos P0 >= 80%
- [ ] docs-system actualizado si el comportamiento cambió
- [ ] Riesgos identificados documentados
```

**No entregar el cierre con checkboxes sin marcar sin explicar por qué.**

---

## Restricciones absolutas

- No asumir reglas de negocio que no estén documentadas.
- No inventar información sobre el sistema.
- No marcar una tarea como completada sin evidencia de validación.
- No modificar código si no se completó la Fase 0.
- No omitir el Impact Analysis si el cambio afecta comportamiento existente.
- No resolver items de `GAPS.md` marcados como `HUMAN_ONLY` sin autorización explícita.

---

## Verificación de precondiciones (AI-Enforced)

Antes de ejecutar cualquier tarea que modifique código, verificar activamente:

### Precondición 1 — docs-system existe y está poblado
```
¿Existe /docs-system/?
¿Tiene al menos los 7 archivos requeridos?
¿USER_FLOW_MATRIX.md tiene flujos con criticidad asignada?

Si alguna respuesta es NO:
  → Detener. Notificar al usuario.
  → Ofrecer crear /docs-system/ con la Fase 0 antes de continuar.
  → No continuar con el cambio hasta que el usuario acepte o rechace explícitamente.
```

### Precondición 2 — el cambio no toca HUMAN_ONLY sin autorización
```
¿El cambio solicitado resuelve o modifica algo marcado HUMAN_ONLY en GAPS.md
o TECHNICAL_DEBT_ROADMAP.md?

Si SÍ:
  → Detener. Mostrar el item HUMAN_ONLY con su justificación.
  → Preguntar: "¿Confirmás que tenés autorización para proceder con este cambio?"
  → Solo continuar si el usuario responde afirmativamente de forma explícita.
```

### Precondición 3 — los flujos P0 afectados tienen tests
```
¿El cambio afecta flujos marcados P0 en USER_FLOW_MATRIX.md?

Si SÍ y no hay tests para esos flujos:
  → Advertir antes de implementar: "Este cambio afecta el flujo P0 [ID]. 
    Actualmente no hay tests para ese flujo. ¿Querés que genere los tests
    primero, o procedemos asumiendo ese riesgo?"
  → Documentar la decisión en el Evidence Report.
```

### Precondición 4 — no introducir bypasses sin documentar
```
¿La implementación requiere usar .skip(), .only(), continue-on-error,
o dejar tests sin escribir para un flujo P0/P1?

Si SÍ:
  → No introducir el bypass silenciosamente.
  → Notificar: "Para completar esto necesito usar [bypass] porque [razón].
    ¿Confirmás que lo documente en TESTING_STRATEGY.md con un plan de resolución?"
  → Solo proceder si el usuario acepta explícitamente.
```

---

## Qué hacer si docs-system no existe

```
1. Notificar al usuario que /docs-system/ no existe.
2. Ofrecer ejecutar la Fase 0 para crearlo.
3. Si el usuario acepta: crear /docs-system/ con templates vacíos y documentar el estado actual.
4. Si el usuario rechaza: continuar indicando que se opera sin contexto documentado.
5. En ningún caso modificar código de negocio antes de este paso.
```
