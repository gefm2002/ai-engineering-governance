# Onboarding — [Nombre del sistema]

> Para un dev que acaba de unirse al equipo y tiene que tocar este repo.
> Generado desde docs-system/ por Engineering Governance Framework.
> Mantener actualizado cuando cambian los flujos críticos o las restricciones.

---

## Qué hace este sistema en 2 líneas

UNKNOWN

---

## Qué proceso de negocio soporta

UNKNOWN
<!-- Ej: "Actualiza el stock disponible en VTEX cuando hay movimientos en el ERP" -->

---

## Por dónde empezar a leer el código

| Archivo | Por qué es importante |
|---------|-----------------------|
| UNKNOWN | UNKNOWN |

<!-- El agente completa esto con los archivos de entry point reales -->

---

## Los flujos que no podés romper (P0)

Estos flujos tienen impacto directo en negocio. Si tocás código relacionado, asegurate de que los tests sigan pasando.

| Flujo | Qué hace | Qué pasa si falla |
|-------|----------|-------------------|
| UNKNOWN | UNKNOWN | UNKNOWN |

Ver detalle en [USER_FLOW_MATRIX.md](USER_FLOW_MATRIX.md).

---

## Cómo correr el proyecto localmente

```bash
# UNKNOWN — completar con pasos reales
```

Variables de entorno requeridas: ver [INTEGRATIONS.md](INTEGRATIONS.md).

---

## Cómo deployar

Ver [OPERATIONS.md](OPERATIONS.md) — sección "Deploy".

---

## Cosas que NO tocar sin hablar con alguien primero

<!-- Items HUMAN_ONLY de GAPS.md y TECHNICAL_DEBT_ROADMAP.md -->

| Qué | Por qué | Con quién hablar |
|-----|---------|-----------------|
| UNKNOWN | UNKNOWN | UNKNOWN |

---

## Deuda conocida y gaps abiertos

Antes de agregar funcionalidad nueva, revisar:
- [GAPS.md](GAPS.md) — funcionalidad que falta
- [TECHNICAL_DEBT_ROADMAP.md](TECHNICAL_DEBT_ROADMAP.md) — deuda técnica activa

Algunos items tienen tickets Jira asignados — buscar por label `governance-framework` en el proyecto.

---

## Preguntas frecuentes

**¿Cómo sé si mi cambio afecta algo crítico?**
Revisar [USER_FLOW_MATRIX.md](USER_FLOW_MATRIX.md) — si el cambio toca un flujo P0 o P1, los tests de ese flujo deben pasar.

**¿Dónde están las credenciales?**
En AWS Secrets Manager. Ver [INTEGRATIONS.md](INTEGRATIONS.md) para los nombres de los secrets.

**¿Cómo verifico que mi cambio no rompió nada?**
```bash
npm test  # o el comando documentado en OPERATIONS.md
```
