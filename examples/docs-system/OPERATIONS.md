# Operations

**Actualizado:** 2026-06-24

---

## Entornos

| Entorno | URL | Branch |
|---------|-----|--------|
| dev | localhost:3000 | cualquiera |
| staging | notifications-stg.internal | develop |
| production | notifications.internal | main |

---

## Build y deploy

```bash
npm install
npm run build        # tsc
npm run migrate      # prisma migrate deploy
npm start            # node dist/server.js
```

Deploy via GitHub Actions en push a `main` → ECS Fargate.

---

## Scripts

| Script | Descripción |
|--------|-------------|
| `npm run dev` | ts-node-dev con hot reload |
| `npm test` | jest |
| `npm run test:cov` | jest con cobertura |
| `npm run migrate` | Prisma migrate deploy |
| `npm run studio` | Prisma Studio (local only) |

---

## Runbooks

| Escenario | Procedimiento |
|-----------|---------------|
| SES throttling | Revisar CloudWatch métricas de SES. Si `Send Rate Exceeded`, reducir volumen de batch o contactar AWS para aumentar límite. |
| Mensajes en estado FAILED acumulados | `SELECT * FROM notification_log WHERE status = 'FAILED' ORDER BY created_at DESC LIMIT 100`. Revisar `error_message`. Si es retriable, usar `POST /notifications/:id/retry`. |
| Redis sin espacio | `REDIS-CLI INFO memory`. Si `used_memory > maxmemory * 0.9`, revisar TTLs de mensajes antiguos: `redis-cli --scan --pattern "notification:*" | xargs redis-cli TTL`. |
| FCM tokens masivamente inválidos | Si hay pico de `FAILED` con FCM, los tokens pueden haber expirado. Endpoint para forzar re-registro de tokens: actualmente NO existe — requiere que el cliente abra la app. |
| Worker detenido | Verificar logs del proceso worker en ECS. Si el container crasheó, ECS lo reinicia automáticamente. Si el loop se bloqueó, reiniciar el task manualmente. |
