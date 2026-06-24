# Diagrams — notifications-service

**Actualizado:** 2026-06-24

---

## 1. Contexto del sistema

```mermaid
graph TB
    upstream(["Servicios upstream\n(orders, payments, shipping)"])
    user(["Usuario final\n(iOS / Android / Email)"])
    admin(["Admin / Equipo de producto"])

    subgraph ns["[Sistema] notifications-service"]
        core["Recibe eventos de negocio\ny los despacha al canal correcto\nsegún preferencias del usuario"]
    end

    pg[(PostgreSQL\npreferencias + log)]
    redis[/Redis\ncola de mensajes/]
    ses["AWS SES\nemail"]
    fcm["Firebase FCM\npush"]
    twilio["Twilio\nSMS"]

    upstream -->|"POST /notifications\n(event_type, user_id, data)"| ns
    user -->|"PUT /preferences\nGET /unsubscribe"| ns
    admin -->|"POST /retry\nGET /notifications"| ns
    ns -->|"Lee preferencias\nEscribe log"| pg
    ns -->|"Encola mensajes\npendientes"| redis
    ns -->|"Envía email"| ses
    ns -->|"Envía push"| fcm
    ns -->|"Envía SMS"| twilio
```

---

## 2. Componentes internos

```mermaid
graph LR
    subgraph entrada["Entrada"]
        http["HTTP Handler\nFastify"]
        worker["Dispatch Worker\ncron cada 5s"]
    end

    subgraph dominio["Dominio"]
        ns["NotificationService\norquestador"]
        pref["PreferencesService\nleer/escribir prefs"]
        tmpl["TemplateRenderer\nHandlebars"]
    end

    subgraph providers["Providers"]
        ses["SesProvider"]
        fcm["FcmProvider"]
        twilio["TwilioProvider"]
    end

    subgraph infra["Infraestructura"]
        queue["RedisQueue\nenqueue/dequeue"]
        pg[(PostgreSQL\nPrisma ORM)]
    end

    http -->|"encola"| queue
    http -->|"lee preferencias"| pref
    worker -->|"desencola"| queue
    worker -->|"despacha"| ns
    ns -->|"renderiza"| tmpl
    ns -->|"selecciona canal"| pref
    ns --> ses
    ns --> fcm
    ns --> twilio
    pref --> pg
    ses -.->|"log resultado"| pg
    fcm -.->|"log resultado"| pg
    twilio -.->|"log resultado"| pg
```

---

## 3. Flujo de negocio — recepción y despacho

```mermaid
flowchart TD
    inicio(["Servicio upstream genera evento\nej: order_confirmed, payment_failed"])
    dup{"¿event_id\nya procesado?"}
    skip1(["Ignorar\nidempotencia"])
    optout{"¿Usuario con\nnotifications_enabled?"}
    skip2(["Omitir envío\nretornar skipped"])
    prefs["Leer preferencias\ndel usuario por canal"]
    canal{"¿Canal\nconfigurado?"}
    default["Usar canal\npor defecto: email"]
    template{"¿Template\nexiste?"}
    error422(["Error 422\ntemplate no encontrado"])
    encolar["Encolar mensaje\nen Redis con TTL 24h"]
    worker["Worker despacha\nal proveedor del canal"]
    retry{"¿Fallo?\n¿retry_count < 3?"}
    reencolar["Re-encolar\ncon backoff"]
    failed(["Estado FAILED\nlog + sin alerta proactiva"])
    ok(["Estado SENT\nlog en notification_log"])

    inicio --> dup
    dup -->|"Sí"| skip1
    dup -->|"No"| optout
    optout -->|"No"| skip2
    optout -->|"Sí"| prefs
    prefs --> canal
    canal -->|"No configurado"| default
    canal -->|"Sí"| template
    default --> template
    template -->|"No existe"| error422
    template -->|"Existe"| encolar
    encolar --> worker
    worker --> retry
    retry -->|"Sí"| reencolar
    reencolar --> worker
    retry -->|"No"| failed
    worker -->|"Éxito"| ok
```

---

## 4. Secuencia — Flujo P0: Recepción y despacho completo

```mermaid
sequenceDiagram
    actor Upstream as Servicio upstream
    participant H as HTTP Handler
    participant NS as NotificationService
    participant PS as PreferencesService
    participant Q as RedisQueue
    participant W as Dispatch Worker
    participant TR as TemplateRenderer
    participant P as Provider (SES/FCM/Twilio)
    participant DB as PostgreSQL

    Upstream->>H: POST /notifications {event_id, event_type, user_id, data}
    H->>DB: SELECT notification_log WHERE event_id (idempotencia)
    DB-->>H: sin resultado (no duplicado)
    H->>PS: getPreferences(user_id)
    PS->>DB: SELECT notification_preferences + users
    DB-->>PS: preferencias + notifications_enabled
    PS-->>H: {channel: "email", enabled: true}
    H->>Q: enqueue(message, TTL=24h)
    Q-->>H: notification_id
    H-->>Upstream: 202 {status: "queued", notification_id}

    Note over W: cron cada 5s
    W->>Q: dequeue(batch=10)
    Q-->>W: [message]
    W->>TR: render(template_name, data)
    TR-->>W: html/text renderizado
    W->>P: send(to, content)

    alt Envío exitoso
        P-->>W: OK
        W->>DB: INSERT notification_log {status: SENT}
    else Fallo retriable (retry_count < 3)
        P-->>W: error
        W->>Q: requeue(message, backoff, retry_count+1)
    else Fallo definitivo (retry_count >= 3)
        P-->>W: error
        W->>DB: INSERT notification_log {status: FAILED}
    end
```

---

## 5. Secuencia — Unsubscribe (con gap documentado)

```mermaid
sequenceDiagram
    actor User as Usuario
    participant H as HTTP Handler
    participant DB as PostgreSQL
    participant Q as RedisQueue

    User->>H: GET /unsubscribe?token=...
    H->>H: validar HMAC token (expira 30 días)

    alt Token válido
        H->>DB: UPDATE users SET notifications_enabled=false
        DB-->>H: OK
        Note over Q: ⚠️ GAP-001: mensajes ya encolados<br/>NO se cancelan aquí
        H-->>User: 200 página de confirmación
    else Token inválido o expirado
        H-->>User: 400 token inválido
    end

    Note over Q: Los mensajes previos en Redis<br/>se seguirán procesando y enviando
```

---

## 6. Flujo de datos — Input → Transformación → Output

```mermaid
flowchart LR
    subgraph input["📥 Input — POST /notifications"]
        i1["event_id: string\nuuid v4"]
        i2["event_type: string\nej: order_confirmed"]
        i3["user_id: string"]
        i4["data: object\nvariables del template"]
        i5["priority?: enum\nDEFAULT | HIGH"]
    end

    subgraph processing["⚙️ Processing"]
        r1["Idempotencia\nSELECT notification_log"]
        r2["Preferencias\nSELECT preferences + users"]
        r3["Selección de canal\nprefs → default email"]
        r4["Template render\nHandlebars + data"]
        r5["Regla SMS\nsolo priority=HIGH"]
    end

    subgraph output["📤 Output"]
        o1["Redis message\n{channel, to, content, retry_count=0}"]
        o2["notification_log row\n{SENT | FAILED | SKIPPED}"]
        o3["Email enviado\nvia SES"]
        o4["Push enviado\nvia FCM"]
        o5["SMS enviado\nvia Twilio (solo HIGH)"]
    end

    i1 --> r1
    i2 --> r3
    i3 --> r2
    i4 --> r4
    i5 --> r5
    r1 -->|"no duplicado"| o1
    r2 --> r3
    r3 --> o1
    r4 --> o1
    r5 -->|"HIGH → habilita SMS"| r3
    o1 -->|"worker despacha"| o3
    o1 -->|"worker despacha"| o4
    o1 -->|"worker despacha"| o5
    o3 --> o2
    o4 --> o2
    o5 --> o2
```

---

## 7. Dependencias y modo de fallo

```mermaid
graph TD
    ns["notifications-service"]

    pg[("PostgreSQL\n🔴 CRÍTICA\nSin esto: falla total")]
    redis[/"Redis\n🔴 CRÍTICA\nSin esto: mensajes perdidos"/]
    ses["AWS SES\n🟡 DEGRADADO\nSin esto: sin email, retry"]
    fcm["Firebase FCM\n🟡 DEGRADADO\nSin esto: sin push, retry"]
    twilio["Twilio\n🟡 DEGRADADO\nSin esto: sin SMS, retry"]
    secrets["Secrets / Env Vars\n🔴 CRÍTICA\nSin esto: falla al inicio"]

    ns -->|"preferencias + log\nSELECT + INSERT"| pg
    ns -->|"cola de mensajes\nenqueue / dequeue"| redis
    ns -->|"email transaccional"| ses
    ns -->|"push iOS/Android"| fcm
    ns -->|"SMS AR/CL"| twilio
    ns -->|"credenciales de providers"| secrets

    style pg fill:#ff6b6b,color:#fff
    style redis fill:#ff6b6b,color:#fff
    style secrets fill:#ff6b6b,color:#fff
    style ses fill:#ffd93d,color:#333
    style fcm fill:#ffd93d,color:#333
    style twilio fill:#ffd93d,color:#333
```

---

## 8. Modelo de datos

```mermaid
erDiagram
    users {
        string id PK
        string email
        string phone
        string fcm_token
        boolean notifications_enabled
        datetime created_at
    }

    notification_preferences {
        string id PK
        string user_id FK
        string event_type
        string channel
        boolean enabled
    }

    notification_log {
        string id PK
        string event_id
        string user_id FK
        string channel
        string status
        int retry_count
        string error_message
        datetime sent_at
        datetime created_at
    }

    users ||--o{ notification_preferences : "configura"
    users ||--o{ notification_log : "recibe"
```
