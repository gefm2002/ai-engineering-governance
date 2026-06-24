# Performance Report

**Actualizado:** 2026-06-24
**Contexto:** Optimización del worker de despacho — antes/después de agregar procesamiento paralelo (PR #189).

---

## Resumen ejecutivo

| Métrica | Antes | Después | Delta |
|---------|-------|---------|-------|
| Mensajes procesados/segundo | 12 | 47 | +292% |
| Latencia p95 por mensaje | 380ms | 95ms | -75% |
| CPU del worker en pico | 18% | 22% | +4% |
| Errores de despacho | 0.3% | 0.3% | sin cambio |

---

## Metodología

**Herramienta:** k6 con script de carga sintética
**Entorno:** Staging (mismas specs que producción)
**Carga:** 1000 mensajes en cola, worker iniciando desde 0
**Fecha:** 2026-06-20

---

## Cambio aplicado

**Problema:** El worker procesaba mensajes de a uno (loop secuencial). A 380ms por mensaje, el throughput máximo era ~2.6/s en carga ideal.

**Causa raíz:** `for await` en el worker leía un mensaje, esperaba al provider, y recién entonces leía el siguiente.

**Solución:** Procesar en lotes de 10 mensajes en paralelo con `Promise.allSettled` — cada mensaje falla independientemente sin bloquear al resto.

```typescript
// Antes
for await (const msg of queue.dequeue()) {
  await dispatch(msg);
}

// Después
const batch = await queue.dequeueBatch(10);
await Promise.allSettled(batch.map(dispatch));
```

---

## Regresiones conocidas

| Optimización | Regresión | Severidad | Estado |
|--------------|-----------|-----------|--------|
| Procesamiento paralelo | El orden de envío ya no es garantizado dentro de un batch | Baja — no hay dependencia de orden entre notificaciones | Aceptada |

---

## Próximas oportunidades

| Área | Potencial | Esfuerzo | Prioridad |
|------|-----------|----------|-----------|
| Cache de preferencias (TD-01) | Eliminar 1 SELECT por mensaje = -30% latencia estimada | Medio | Alta |
| Batch size configurable | Ajustar según carga real sin deploy | Bajo | Media |
