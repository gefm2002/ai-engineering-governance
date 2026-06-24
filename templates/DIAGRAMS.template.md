# Diagrams

**Actualizado:** UNKNOWN
**Formato:** Mermaid — renderiza en GitHub, GitLab, Notion y la mayoría de herramientas de documentación.
**Regla:** si el sistema cambia, los diagramas deben actualizarse en el mismo PR.

---

## 1. Contexto del sistema (C4 Level 1)

> Quién interactúa con el sistema desde afuera. Para stakeholders no técnicos.

```mermaid
graph TB
    actor1([Actor / Sistema upstream])
    actor2([Usuario final])

    subgraph sistema["[Sistema] Nombre del sistema"]
        core["Descripción breve de qué hace"]
    end

    db1[(Base de datos)]
    ext1[Servicio externo 1]
    ext2[Servicio externo 2]

    actor1 -->|"Acción / protocolo"| sistema
    actor2 -->|"Acción / protocolo"| sistema
    sistema -->|"Lee / escribe"| db1
    sistema -->|"Llama a"| ext1
    sistema -->|"Notifica via"| ext2
```

---

## 2. Diagrama de componentes (C4 Level 2)

> Componentes internos y cómo se conectan entre sí.

```mermaid
graph LR
    subgraph entrada["Entrada"]
        trigger["Trigger\n(SQS / HTTP / cron)"]
    end

    subgraph nucleo["Núcleo"]
        handler["Handler\nValidación + routing"]
        service["Service\nOrquestador"]
        moduleA["Módulo A"]
        moduleB["Módulo B"]
    end

    subgraph salida["Salida"]
        db[(Base de datos)]
        queue[/Cola de mensajes/]
        api[API externa]
    end

    trigger --> handler
    handler --> service
    service --> moduleA
    service --> moduleB
    moduleA --> db
    moduleB --> queue
    moduleA --> api
```

---

## 3. Flujo de negocio — vista funcional

> Qué hace el sistema en términos de negocio, sin detalle técnico. Para product owners y stakeholders.

```mermaid
flowchart TD
    inicio([Inicio: evento de negocio])
    paso1["Validar datos de entrada"]
    decision1{¿Cumple condiciones?}
    paso2["Procesar regla de negocio A"]
    paso3["Procesar regla de negocio B"]
    output1["Resultado A"]
    output2["Resultado B"]
    fin([Fin])

    inicio --> paso1
    paso1 --> decision1
    decision1 -->|Sí| paso2
    decision1 -->|No| paso3
    paso2 --> output1
    paso3 --> output2
    output1 --> fin
    output2 --> fin
```

---

## 4. Diagrama de secuencia — Flujo P0 principal

> Interacciones entre componentes en el tiempo para el flujo crítico. Para desarrolladores.

```mermaid
sequenceDiagram
    actor Trigger
    participant Handler
    participant Service
    participant DB as Base de datos
    participant External as Servicio externo

    Trigger->>Handler: evento con payload
    Handler->>Handler: validar schema
    Handler->>Service: procesar(payload)

    Service->>DB: leer datos
    DB-->>Service: registros

    alt datos válidos
        Service->>External: llamar API
        External-->>Service: respuesta
        Service->>DB: escribir resultado
        Service-->>Handler: éxito
    else datos inválidos o error externo
        Service-->>Handler: error con código
    end

    Handler-->>Trigger: respuesta final
```

---

## 5. Diagrama de secuencia — Flujo de error / retry

> Qué pasa cuando algo falla. Crítico para entender resiliencia del sistema.

```mermaid
sequenceDiagram
    participant Service
    participant External as Servicio externo
    participant Queue as Cola de retry
    participant Alert as Sistema de alertas

    Service->>External: llamada (intento 1)
    External-->>Service: error / timeout

    loop retry (máx N intentos)
        Service->>Service: esperar backoff
        Service->>External: llamada (intento N)
        External-->>Service: error
    end

    alt reintentos agotados y umbral superado
        Service->>Alert: notificar fallo crítico
        Service->>Queue: encolar para revisión manual
    else reintentos agotados, umbral no superado
        Service->>Service: incrementar contador de errores
        Service-->>Service: modo degradado / skip
    end
```

---

## 6. Flujo de datos — Input → Processing → Output

> Qué datos entran, cómo se transforman, qué sale. Para entender el contrato del sistema.

```mermaid
flowchart LR
    subgraph input["📥 Input"]
        i1["Campo A\ntipo: string"]
        i2["Campo B\ntipo: number"]
        i3["Campo C\ntipo: enum"]
    end

    subgraph processing["⚙️ Processing"]
        r1["Regla 1\nTransformación"]
        r2["Regla 2\nValidación"]
        r3["Regla 3\nEnriquecimiento con DB"]
    end

    subgraph output["📤 Output"]
        o1["Objeto destino A\nescrito en DB"]
        o2["Mensaje destino B\nencolado"]
        o3["Respuesta al caller"]
    end

    i1 --> r1
    i2 --> r2
    i3 --> r3
    r1 --> o1
    r2 --> o2
    r3 --> o3
```

---

## 7. Dependencias externas y criticidad

> Qué depende el sistema de afuera y qué pasa si cada dependencia falla.

```mermaid
graph TD
    sistema["[Este sistema]"]

    db[(Base de datos\n🔴 CRÍTICA)]
    queue[/Cola de mensajes\n🟡 DEGRADADO/]
    api1[API externa 1\n🟡 DEGRADADO]
    api2[API externa 2\n🟢 OPCIONAL]
    secrets[Secrets Manager\n🔴 CRÍTICA]

    sistema -->|"Lee/escribe\nSin esto: falla total"| db
    sistema -->|"Encola resultados\nSin esto: procesa pero no despacha"| queue
    sistema -->|"Enriquece datos\nSin esto: modo degradado"| api1
    sistema -->|"Notificaciones\nSin esto: silencioso"| api2
    sistema -->|"Credenciales\nSin esto: falla total"| secrets
```

---

## 8. Modelo de datos — entidades principales

> Qué tablas / colecciones usa el sistema y cómo se relacionan.

```mermaid
erDiagram
    ENTIDAD_A {
        string id PK
        string campo1
        number campo2
        datetime created_at
    }

    ENTIDAD_B {
        string id PK
        string entidad_a_id FK
        string estado
        datetime updated_at
    }

    ENTIDAD_C {
        string id PK
        string entidad_b_id FK
        string resultado
    }

    ENTIDAD_A ||--o{ ENTIDAD_B : "tiene"
    ENTIDAD_B ||--o{ ENTIDAD_C : "genera"
```
