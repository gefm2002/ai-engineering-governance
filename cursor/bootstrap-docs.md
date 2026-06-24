# bootstrap-docs — Cursor Command

Analizar este repositorio.

No modificar código.

Crear la estructura `/docs-system` con los siguientes archivos:

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

Para cada archivo:

- Documentar el estado actual del repositorio.
- Usar `UNKNOWN` cuando la información no pueda inferirse del código.
- No inventar información de negocio.
- No asumir contexto que no esté en el código o en archivos de configuración.

Abrir un PR exclusivamente documental.

El PR no debe contener modificaciones de código.

El título del PR debe ser: `docs: baseline documentation [docs-system]`

## Cómo ejecutar

Desde Cursor:

```
Cmd+K → /run bootstrap-docs
```

O pegar directamente en el chat de Cursor/Claude:

```
Ejecutá únicamente la Fase 0 del Engineering Governance Framework.
No modifiques código.
Generá la estructura /docs-system.
Documentá el estado actual.
Marcá UNKNOWN cuando no puedas inferir información.
Abrí un PR exclusivamente documental.
```
