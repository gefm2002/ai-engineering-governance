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

Pensar como **ingeniero senior + product owner técnico**: el objetivo no es listar archivos sino entender qué problema de negocio resuelve el sistema y qué lo hace frágil.

Generar internamente (no necesariamente mostrar, pero sí tener disponible):

```
Sistema: [nombre]
Propósito: [qué hace en términos de negocio, no técnicos]
Negocio que soporta: [qué área / proceso / decisión depende de este sistema]
Actores: [quién lo usa directamente y quién depende de él indirectamente]
Dependencias críticas: [qué rompe el sistema si falla — con impacto de negocio]
Fragilidades conocidas: [qué partes del código o del diseño son propensas a errores]
Riesgos principales: [qué puede salir mal en producción]
```

---

## Criterio por disciplina — cómo analizar cada documento

Al generar o actualizar cada documento de `/docs-system/`, aplicar el criterio de la disciplina correspondiente:

### Al generar PRODUCT_SURFACE.md — criterio de Product Manager técnico
- Identificar capabilities reales (lo que el sistema *hace*, no lo que *debería* hacer)
- Distinguir entre lo que está implementado, lo que está parcialmente implementado y lo que está documentado pero no existe
- Identificar actores reales (incluyendo sistemas upstream/downstream, no solo usuarios humanos)
- Capturar reglas de negocio implícitas en el código (condicionales, constantes, enums con semántica de negocio)

### Al generar USER_FLOW_MATRIX.md — criterio de QA senior
- Pensar en términos de caminos del usuario/sistema, no de funciones del código
- Asignar criticidad P0/P1/P2/P3 basada en: impacto económico si falla, frecuencia de uso, imposibilidad de recuperación manual
- P0 = falla silenciosa o con impacto en revenue/datos sin posibilidad de retry manual
- Identificar happy path Y error paths para cada flujo
- Señalar flujos sin cobertura de tests o con cobertura parcial

### Al generar ARCHITECTURE.md — criterio de arquitecto de software
- Documentar decisiones de diseño con su justificación (no solo "qué es" sino "por qué es así")
- Identificar trade-offs activos: qué se sacrificó para lograr qué
- Señalar fragilidades arquitectónicas: acoplamiento alto, falta de abstracción, dependencias circulares
- Documentar patrones usados y dónde se rompen
- Distinguir entre decisiones conscientes y deuda acumulada sin decisión

### Al generar INTEGRATIONS.md — criterio de ingeniero de backend senior
- Documentar el contrato real (payload, tipos, errores posibles) no el contrato ideal
- Identificar qué pasa cuando la integración falla: ¿el sistema falla silenciosamente? ¿hace retry? ¿alerta?
- Documentar timeouts, rate limits y comportamiento en degradación
- Señalar integraciones sin circuit breaker o sin manejo de error documentado

### Al generar TECHNICAL_DEBT_ROADMAP.md — criterio de tech lead
- Distinguir deuda intencional (decisión consciente con plan de pago) de deuda accidental (nadie la decidió, simplemente está)
- Evaluar impacto en: mantenibilidad, performance, seguridad, onboarding de nuevos devs
- No listar todo como deuda — solo lo que tiene costo real hoy o en el futuro próximo
- Identificar items que requieren decisión humana (HUMAN_ONLY) vs los que el agente puede resolver

### Al generar GAPS.md — criterio de code reviewer senior
- Un gap es funcionalidad que el sistema debería tener según su propósito pero no tiene
- No confundir con deuda técnica (cómo está hecho) ni con roadmap (qué se quiere agregar)
- Distinguir gaps que bloquean flujos P0/P1 (críticos) de los que afectan flujos P2/P3 (nice to have)
- Documentar el impacto real de cada gap, no solo su existencia

### Al generar TESTING_STRATEGY.md — criterio de QA engineer
- Mapear cada flujo de USER_FLOW_MATRIX a sus archivos de test existentes
- Evaluar si los tests cubren el happy path Y los error paths principales
- Detectar bypasses (.skip, .only, continue-on-error) y documentar si son conscientes o accidentales
- Identificar flujos P0 sin tests o con cobertura insuficiente — estos son riesgos de release

### Al generar DIAGRAMS.md — criterio de arquitecto de sistemas
- El diagrama de contexto debe poder ser entendido por alguien sin contexto técnico
- El diagrama de secuencia debe mostrar los flujos P0 con sus caminos de error
- El diagrama de dependencias debe indicar qué pasa cuando cada dependencia falla
- Preferir claridad sobre completitud — un diagrama útil es mejor que uno exhaustivo e ilegible

---

## Fase 2 — Impact Analysis

Pensar como **code reviewer senior**: antes de ejecutar cualquier cambio, identificar todo lo que puede romperse y comunicarlo.

Para cualquier cambio solicitado:

```
Cambio solicitado: [descripción]
Módulos afectados: [lista con razón]
APIs/contratos afectados: [lista — cambio de input/output/error codes]
Flujos de USER_FLOW_MATRIX afectados: [IDs con criticidad]
Dependencias afectadas: [servicios externos, DBs, colas]
Documentación que debe actualizarse: [lista de docs de /docs-system/]
Riesgos del cambio: [qué puede fallar, con qué probabilidad y qué impacto]
Casos borde no contemplados: [qué escenarios el cambio no maneja explícitamente]
```

Si el análisis revela riesgos no contemplados en la solicitud, comunicarlos antes de continuar.

---

## Fase 3 — Ejecución

Pensar como **senior developer con ownership**: implementar con el mismo criterio con que uno firmaría el código en producción.

Solo después de completar Fases 0, 1 y 2:

- Implementar el cambio.
- Escribir o actualizar tests al nivel de criticidad del flujo afectado (P0 → integration, P1 → unit)
- Ejecutar validaciones disponibles (tests, builds, linters) — sin `continue-on-error`
- No declarar el cambio como completo sin evidencia de que los tests pasan.

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

## Propuestas de ticket (docs-system/Tickets/)

Durante la Fase 0 o la Fase 5, si se identifican gaps o deuda técnica que no tienen ticket documentado, generar una propuesta en `docs-system/Tickets/` usando `templates/TICKET_PROPOSAL.template.md`.

**Cuándo generar un archivo de propuesta:**
- Un item nuevo aparece en `GAPS.md` o `TECHNICAL_DEBT_ROADMAP.md`
- Un gap o deuda existente escala de prioridad (ej: de P2 a P0)
- Se descubre durante el análisis un riesgo concreto que debería quedar como ticket

**Nombre del archivo:**
```
docs-system/Tickets/YYYY-MM-DD-[GAP-001|DEBT-003]-slug-en-minusculas.md
```

**Cómo escribirlo:**
- La sección "¿Qué está pasando?" y "¿Por qué importa?" deben estar en lenguaje de negocio — sin jerga técnica. Debe poder leerlo alguien que no es desarrollador.
- La sección "Contexto técnico" es para el dev que tome el trabajo.
- Las "Notas para el PO" deben incluir la prioridad sugerida con una razón concreta, no solo la etiqueta.
- Si el item es HUMAN_ONLY, indicarlo explícitamente en las notas al PO.

**El agente NO crea tickets en Jira.** Solo genera el archivo MD. El PO decide si crear el ticket, dónde, y con qué ajustes.

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
