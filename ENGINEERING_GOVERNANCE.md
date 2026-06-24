# AI-Assisted Engineering Governance Framework

---

## Objetivo

Establecer un proceso estándar para el uso de IA (Cursor, Claude, Codex, Copilot y similares) dentro del ciclo de desarrollo.

El objetivo no es generar más código.

El objetivo es:

- Reducir cambios sin contexto.
- Reducir regresiones.
- Preservar conocimiento.
- Mejorar mantenibilidad.
- Aumentar velocidad sin perder control.
- Permitir que humanos e IA compartan una misma fuente de verdad.

---

## Principios

### 1. Entender antes de modificar

Ningún cambio debe implementarse sin comprender:

- Qué hace el sistema.
- Qué negocio soporta.
- Qué actores impacta.
- Qué dependencias afecta.
- Qué contratos modifica.

### 2. La documentación es parte del producto

La documentación no es opcional.

La documentación describe:

- Estado actual.
- Alcance funcional.
- Flujos de negocio.
- Operación.
- Deuda técnica.

Si el sistema cambia, la documentación debe cambiar.

### 3. La IA no reemplaza entendimiento

La IA puede generar código.  
No puede inferir correctamente:

- Reglas de negocio implícitas.
- Dependencias organizacionales.
- Decisiones históricas.
- Restricciones operativas.

Por lo tanto, la IA debe trabajar a partir de documentación explícita.

### 4. Evidencia sobre opiniones

No se considera validado:

- Build exitoso.
- Test unitario exitoso.
- Respuesta HTTP 200.

Se considera validado:

- Flujo ejecutado.
- Resultado verificado.
- Evidencia disponible.

### 5. Source of Truth

Cada repositorio debe poseer una carpeta:

```
/docs-system
```

que contiene la documentación oficial.

No deben existir múltiples fuentes contradictorias.

---

## Estructura mínima requerida

```
/docs-system
├── 00_INDEX.md
├── PRODUCT_SURFACE.md
├── FLOW_MATRIX.md
├── ARCHITECTURE.md
├── INTEGRATIONS.md
├── OPERATIONS.md
├── TECHNICAL_DEBT.md
└── RELEASE_STATE.md
```

---

## Flujo obligatorio

```
READ
  ↓
UNDERSTAND
  ↓
IMPACT ANALYSIS
  ↓
CHANGE
  ↓
VERIFY
  ↓
DOCUMENT
  ↓
CERTIFY
```

---

## Pull Requests

Todo PR debe responder:

1. Qué cambia.
2. Por qué cambia.
3. Qué impacto tiene.
4. Qué documentación se actualizó.
5. Qué evidencia valida el cambio.

---

## Fases de trabajo con IA

### Fase 0 — Context Bootstrap

Leer obligatoriamente antes de cualquier tarea:

```
/docs-system/00_INDEX.md
/docs-system/PRODUCT_SURFACE.md
/docs-system/FLOW_MATRIX.md
/docs-system/ARCHITECTURE.md
/docs-system/INTEGRATIONS.md
/docs-system/OPERATIONS.md
/docs-system/TECHNICAL_DEBT.md
/docs-system/RELEASE_STATE.md
```

No modificar código todavía.

### Fase 1 — Entendimiento

Generar:

**Repository Summary**

- Qué hace el repositorio.
- Qué negocio soporta.
- Qué actores utilizan sus capacidades.
- Qué dependencias posee.
- Qué riesgos principales existen.

**Impact Analysis**

Para cualquier solicitud, identificar:

- Módulos afectados.
- APIs afectadas.
- Eventos afectados.
- Dependencias afectadas.
- Documentación afectada.

### Fase 2 — Ejecución

Solo después del análisis:

- Implementar cambios.
- Validar cambios.
- Ejecutar pruebas relevantes.

### Fase 3 — Documentación

Si el comportamiento cambia, actualizar según corresponda:

- `PRODUCT_SURFACE.md`
- `FLOW_MATRIX.md`
- `ARCHITECTURE.md`
- `OPERATIONS.md`
- `TECHNICAL_DEBT.md`
- `RELEASE_STATE.md`

### Fase 4 — Cierre

Entregar siempre:

```
Summary
Impact Analysis
Files Changed
Documentation Updated
Validation Executed
Remaining Risks
```

No asumir. No inventar. No marcar PASS sin evidencia.

---

## Regla Final

> Ningún cambio puede implementarse sin demostrar comprensión funcional del comportamiento que está modificando.
