# Architecture

**Actualizado:** 2026-06-24

---

## Stack técnico

| Capa | Tecnología | Versión |
|------|------------|---------|
| Runtime | Node.js | 20.x |
| Lenguaje | TypeScript | 5.x |
| Framework | Fastify | 4.x |
| Base de datos | PostgreSQL | 15 |
| Queue | Redis | 7 |
| Email | AWS SES | SDK v3 |
| Push | Firebase FCM | Admin SDK 12 |
| SMS | Twilio | 5.x |
| ORM | Prisma | 5.x |

---

## Estructura de carpetas

```
src/
├── handler/
│   └── notificationsHandler.ts     ← recibe POST /notifications, encola
├── worker/
│   └── dispatchWorker.ts           ← procesa cola Redis, llama providers
├── domain/
│   ├── NotificationService.ts      ← orquestador: preferencias + canal + despacho
│   ├── PreferencesService.ts       ← lee/escribe preferencias de usuario
│   └── TemplateRenderer.ts         ← renderiza Handlebars con variables del evento
├── providers/
│   ├── SesProvider.ts              ← envío via AWS SES
│   ├── FcmProvider.ts              ← envío via Firebase FCM
│   └── TwilioProvider.ts           ← envío via Twilio SMS
├── queue/
│   └── RedisQueue.ts               ← enqueue / dequeue con TTL
├── db/
│   └── prisma/schema.prisma        ← modelos: User, NotificationLog, Template
└── config/
    └── index.ts                    ← env vars centralizadas
```

---

## Decisiones de diseño relevantes

| Decisión | Razón | Fragilidad |
|----------|-------|-----------|
| Redis como queue (no SQS/RabbitMQ) | Simplicidad operativa — el equipo ya lo usa para cache | Si Redis cae, los mensajes en cola se pierden — no hay persistencia |
| Preferencias leídas en cada envío sin cache | Simplificó el MVP | N+1 ante volumen alto — ver TD-01 |
| Retry limit hardcodeado en 3 | Decisión inicial sin análisis formal | No configurable por tipo de evento — ver TD-02 |
| Templates en filesystem (no DB) | Deploy simple — los templates van con el código | Cambiar un template requiere deploy — no hay hot reload |
| FCM token inválido = no retriable | Tokens inválidos no se recuperan solos | Si FCM retorna 404, el mensaje queda `FAILED` sin alerta proactiva |
