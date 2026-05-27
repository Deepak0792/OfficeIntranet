# SdxCore — Infrastructure & Environment Configuration

---

## Overview

All local infrastructure is orchestrated via a single `docker/docker-compose.yml` file. This includes SQL Server, Redis, Elasticsearch, RabbitMQ, and the shared file storage volume. Every microservice and infrastructure component is configured through Docker environment variables, which override `appsettings.json` values at runtime.

---

## Repository Layout — Infrastructure Files

```
SdxCore/
└── docker/
    ├── docker-compose.yml               # Primary orchestration file
    ├── docker-compose.override.yml      # Developer-local overrides (git-ignored)
    ├── .env                             # Environment variable defaults (git-ignored)
    ├── .env.example                     # Template committed to source control
    └── volumes/
        └── sdxcore-files/               # Bind-mount host path for shared file storage
```

---

## `.env.example` — Environment Variable Template

```dotenv
# ── SQL Server ─────────────────────────────────────────────
SQL_SA_PASSWORD=YourStrongPassword123!
SQL_SERVER_PORT=1433

# ── Redis ──────────────────────────────────────────────────
REDIS_PORT=6379
REDIS_PASSWORD=

# ── Elasticsearch ──────────────────────────────────────────
ES_PORT=9200
ES_KIBANA_PORT=5601
ES_JAVA_OPTS=-Xms512m -Xmx512m

# ── RabbitMQ ───────────────────────────────────────────────
RABBITMQ_PORT=5672
RABBITMQ_MANAGEMENT_PORT=15672
RABBITMQ_DEFAULT_USER=sdxcore
RABBITMQ_DEFAULT_PASS=sdxcore_secret

# ── Gateway ────────────────────────────────────────────────
GATEWAY_INTERNAL_API_KEY=sdxcore-internal-secret-key-change-in-prod

# ── File Storage ───────────────────────────────────────────
FILE_STORAGE_PROVIDER=SharedFileSystem
FILE_STORAGE_ROOT=/mnt/sdxcore-files
FILE_STORAGE_ENV=development
FILE_STORAGE_TENANT=sdxcore

# ── Service Ports ──────────────────────────────────────────
GATEWAY_PORT=5000
IDENTITY_PORT=5001
TIME_PORT=5002
SHARED_PORT=5003
EMPLOYEE_PORT=5004
... Any other services ...
```

Copy `.env.example` to `.env` and fill in values before running `docker-compose up`.

---

## `docker-compose.yml` — Full Configuration

```yaml
# ============================================================
# SdxCore — Local Development Infrastructure
# ============================================================

version: '3.9'

# ── Named Volumes ────────────────────────────────────────────
volumes:
  sdxcore-sqlserver-data:
    driver: local

  sdxcore-identity-sqlserver-data:
    driver: local

  sdxcore-redis-data:
    driver: local

  sdxcore-elasticsearch-data:
    driver: local

  sdxcore-rabbitmq-data:
    driver: local

  sdxcore-files:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./volumes/sdxcore-files

# ── Networks ─────────────────────────────────────────────────
networks:
  sdxcore-net:
    driver: bridge

# ── Services ─────────────────────────────────────────────────
services:

  # ── SQL Server (SdxCore Database — all microservice schemas) ──
  sdxcore.sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: sdxcore-sqlserver
    environment:
      SA_PASSWORD: ${SQL_SA_PASSWORD}
      ACCEPT_EULA: "Y"
      MSSQL_PID: Developer
    ports:
      - "${SQL_SERVER_PORT:-1433}:1433"
    volumes:
      - sdxcore-sqlserver-data:/var/opt/mssql
    networks:
      - sdxcore-net
    healthcheck:
      test: ["CMD-SHELL", "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P ${SQL_SA_PASSWORD} -Q 'SELECT 1' || exit 1"]
      interval: 15s
      timeout: 10s
      retries: 10
      start_period: 30s
    restart: unless-stopped

  # ── SQL Server (Identity — isolated database) ─────────────────
  sdxcore.identity.sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: sdxcore-identity-sqlserver
    environment:
      SA_PASSWORD: ${SQL_SA_PASSWORD}
      ACCEPT_EULA: "Y"
      MSSQL_PID: Developer
    ports:
      - "1434:1433"
    volumes:
      - sdxcore-identity-sqlserver-data:/var/opt/mssql
    networks:
      - sdxcore-net
    healthcheck:
      test: ["CMD-SHELL", "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P ${SQL_SA_PASSWORD} -Q 'SELECT 1' || exit 1"]
      interval: 15s
      timeout: 10s
      retries: 10
      start_period: 30s
    restart: unless-stopped

  # ── Redis ──────────────────────────────────────────────────────
  sdxcore.redis:
    image: redis:7.2-alpine
    container_name: sdxcore-redis
    command: >
      redis-server
      --requirepass ${REDIS_PASSWORD:-}
      --maxmemory 512mb
      --maxmemory-policy allkeys-lru
      --appendonly yes
      --appendfsync everysec
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - sdxcore-redis-data:/data
    networks:
      - sdxcore-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
    restart: unless-stopped

  # ── Elasticsearch ──────────────────────────────────────────────
  sdxcore.elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: sdxcore-elasticsearch
    environment:
      - node.name=sdxcore-es01
      - cluster.name=sdxcore-cluster
      - discovery.type=single-node
      - ES_JAVA_OPTS=${ES_JAVA_OPTS:--Xms512m -Xmx512m}
      - xpack.security.enabled=false           # Disable for local dev; enable for staging/prod
      - xpack.security.http.ssl.enabled=false
      - bootstrap.memory_lock=true
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    ports:
      - "${ES_PORT:-9200}:9200"
      - "9300:9300"
    volumes:
      - sdxcore-elasticsearch-data:/usr/share/elasticsearch/data
    networks:
      - sdxcore-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health || exit 1"]
      interval: 20s
      timeout: 10s
      retries: 10
      start_period: 60s
    restart: unless-stopped

  # ── Kibana (Elasticsearch UI) ──────────────────────────────────
  sdxcore.kibana:
    image: docker.elastic.co/kibana/kibana:8.13.0
    container_name: sdxcore-kibana
    environment:
      - ELASTICSEARCH_HOSTS=http://sdxcore.elasticsearch:9200
      - SERVER_NAME=sdxcore-kibana
    ports:
      - "${ES_KIBANA_PORT:-5601}:5601"
    networks:
      - sdxcore-net
    depends_on:
      sdxcore.elasticsearch:
        condition: service_healthy
    restart: unless-stopped

  # ── RabbitMQ ───────────────────────────────────────────────────
  sdxcore.rabbitmq:
    image: rabbitmq:3.13-management-alpine
    container_name: sdxcore-rabbitmq
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_DEFAULT_USER:-sdxcore}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_DEFAULT_PASS:-sdxcore_secret}
      RABBITMQ_DEFAULT_VHOST: sdxcore
    ports:
      - "${RABBITMQ_PORT:-5672}:5672"
      - "${RABBITMQ_MANAGEMENT_PORT:-15672}:15672"
    volumes:
      - sdxcore-rabbitmq-data:/var/lib/rabbitmq
    networks:
      - sdxcore-net
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 15s
      timeout: 10s
      retries: 10
      start_period: 30s
    restart: unless-stopped

  # ── Gateway ────────────────────────────────────────────────────
  sdxcore.gateway.api:
    build:
      context: ../
      dockerfile: src/Gateway/SdxCore.Gateway.API/Dockerfile
    container_name: sdxcore-gateway
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:80
      - Gateway__InternalApiKey=${GATEWAY_INTERNAL_API_KEY}
      - ReverseProxy__Clusters__identity__Destinations__default__Address=http://sdxcore.identity.api:80     
      - ReverseProxy__Clusters__shared__Destinations__default__Address=http://sdxcore.shared.api:80
      - ReverseProxy__Clusters__time__Destinations__default__Address=http://sdxcore.time.api:80
      - ReverseProxy__Clusters__employee__Destinations__default__Address=http://sdxcore.employee.api:80
      # ... Any other services to follow ...
    ports:
      - "${GATEWAY_PORT:-5000}:80"  
    volumes:
      - sdxcore-files:/mnt/sdxcore-files
    networks:
      - sdxcore-net
    depends_on:
      sdxcore.sqlserver:
        condition: service_healthy
      sdxcore.redis:
        condition: service_healthy
      sdxcore.rabbitmq:
        condition: service_healthy
    restart: unless-stopped

  # ── Identity Service ───────────────────────────────────────────
  sdxcore.identity.api:
    build:
      context: ../
      dockerfile: src/Services/Identity/SdxCore.Identity.API/Dockerfile
    container_name: sdxcore-identity
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:80
      - ConnectionStrings__SdxIdentityDb=Server=sdxcore.identity.sqlserver,1433;Database=SdxIdentityDb;User Id=sa;Password=${SQL_SA_PASSWORD};TrustServerCertificate=True;
      - Gateway__InternalApiKey=${GATEWAY_INTERNAL_API_KEY}
      - Redis__ConnectionString=sdxcore.redis:6379
      - RabbitMQ__Host=sdxcore.rabbitmq
      - RabbitMQ__VirtualHost=sdxcore
      - RabbitMQ__Username=${RABBITMQ_DEFAULT_USER}
      - RabbitMQ__Password=${RABBITMQ_DEFAULT_PASS}
    ports:
      - "${IDENTITY_PORT:-5001}:80"
    networks:
      - sdxcore-net
    depends_on:
      sdxcore.identity.sqlserver:
        condition: service_healthy
      sdxcore.redis:
        condition: service_healthy
      sdxcore.rabbitmq:
        condition: service_healthy
    restart: unless-stopped

  # ── Shared Service ─────────────────────────────────────────────
  sdxcore.shared.api:
    build:
      context: ../
      dockerfile: src/Services/Shared/SdxCore.Shared.API/Dockerfile
    container_name: sdxcore-shared
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:80
      - ConnectionStrings__SdxCoreDb=Server=sdxcore.sqlserver,1433;Database=SdxCoreDb;User Id=sa;Password=${SQL_SA_PASSWORD};TrustServerCertificate=True;
      - Gateway__InternalApiKey=${GATEWAY_INTERNAL_API_KEY}
      - Redis__ConnectionString=sdxcore.redis:6379
      - RabbitMQ__Host=sdxcore.rabbitmq
      - RabbitMQ__VirtualHost=sdxcore
      - RabbitMQ__Username=${RABBITMQ_DEFAULT_USER}
      - RabbitMQ__Password=${RABBITMQ_DEFAULT_PASS}
    ports:
      - "${SHARED_PORT:-5002}:80"
    networks:
      - sdxcore-net
    depends_on:
      sdxcore.sqlserver:
        condition: service_healthy
      sdxcore.redis:
        condition: service_healthy
    restart: unless-stopped

  # ── Time Service ───────────────────────────────────────────────
  sdxcore.time.api:
    build:
      context: ../
      dockerfile: src/Services/Time/SdxCore.Time.API/Dockerfile
    container_name: sdxcore-time
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:80
      - ConnectionStrings__SdxCoreDb=Server=sdxcore.sqlserver,1433;Database=SdxCoreDb;User Id=sa;Password=${SQL_SA_PASSWORD};TrustServerCertificate=True;
      - Gateway__InternalApiKey=${GATEWAY_INTERNAL_API_KEY}
      - Redis__ConnectionString=sdxcore.redis:6379
      - Elasticsearch__Url=http://sdxcore.elasticsearch:9200
      - RabbitMQ__Host=sdxcore.rabbitmq
      - RabbitMQ__VirtualHost=sdxcore
      - RabbitMQ__Username=${RABBITMQ_DEFAULT_USER}
      - RabbitMQ__Password=${RABBITMQ_DEFAULT_PASS}
      - FileStorage__ProviderType=${FILE_STORAGE_PROVIDER}
      - FileStorage__SharedFileSystem__RootPath=${FILE_STORAGE_ROOT}
      - FileStorage__SharedFileSystem__Environment=${FILE_STORAGE_ENV}
      - FileStorage__SharedFileSystem__Tenant=${FILE_STORAGE_TENANT}
    ports:
      - "${TIME_PORT:-5003}:80"
    volumes:
      - sdxcore-files:/mnt/sdxcore-files
    networks:
      - sdxcore-net
    depends_on:
      sdxcore.sqlserver:
        condition: service_healthy
      sdxcore.redis:
        condition: service_healthy
      sdxcore.rabbitmq:
        condition: service_healthy
    restart: unless-stopped

  # ── Employee Service ───────────────────────────────────────────
  sdxcore.employee.api:
    build:
      context: ../
      dockerfile: src/Services/Employee/SdxCore.Employee.API/Dockerfile
    container_name: sdxcore-employee
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:80
      - ConnectionStrings__SdxCoreDb=Server=sdxcore.sqlserver,1433;Database=SdxCoreDb;User Id=sa;Password=${SQL_SA_PASSWORD};TrustServerCertificate=True;
      - Gateway__InternalApiKey=${GATEWAY_INTERNAL_API_KEY}
      - Redis__ConnectionString=sdxcore.redis:6379
      - Elasticsearch__Url=http://sdxcore.elasticsearch:9200
      - RabbitMQ__Host=sdxcore.rabbitmq
      - RabbitMQ__VirtualHost=sdxcore
      - RabbitMQ__Username=${RABBITMQ_DEFAULT_USER}
      - RabbitMQ__Password=${RABBITMQ_DEFAULT_PASS}
      - FileStorage__ProviderType=${FILE_STORAGE_PROVIDER}
      - FileStorage__SharedFileSystem__RootPath=${FILE_STORAGE_ROOT}
      - FileStorage__SharedFileSystem__Environment=${FILE_STORAGE_ENV}
      - FileStorage__SharedFileSystem__Tenant=${FILE_STORAGE_TENANT}
    ports:
      - "${EMPLOYEE_PORT:-5004}:80"
    volumes:
      - sdxcore-files:/mnt/sdxcore-files
    networks:
      - sdxcore-net
    depends_on:
      sdxcore.sqlserver:
        condition: service_healthy
      sdxcore.redis:
        condition: service_healthy
      sdxcore.rabbitmq:
        condition: service_healthy
      sdxcore.elasticsearch:
        condition: service_healthy
    restart: unless-stopped

  # ── Any other services to follow ─────────────────────────────────────────────
```

---

## Infrastructure Service Details

### SQL Server — `sdxcore.sqlserver`

| Property | Value |
|----------|-------|
| Image | `mcr.microsoft.com/mssql/server:2022-latest` |
| Edition | Developer (free, full-featured) |
| Host Port | `1433` |
| Data Volume | `sdxcore-sqlserver-data` (persistent named volume) |
| Hosts Schemas | `[shared]`, `[time]`, `[employee]`, `[hr]`, `[payroll]`, `[attendance]`, `[workflow]`, `[event]`, `[helpdesk]`, `[survey]`, `[auth]` |

### SQL Server — `sdxcore.identity.sqlserver`

| Property | Value |
|----------|-------|
| Image | `mcr.microsoft.com/mssql/server:2022-latest` |
| Host Port | `1434` |
| Data Volume | `sdxcore-identity-sqlserver-data` |
| Hosts Database | `SdxIdentityDb` — isolated, not shared with other services |

### Redis — `sdxcore.redis`

| Property | Value |
|----------|-------|
| Image | `redis:7.2-alpine` |
| Host Port | `6379` |
| Persistence | AOF (Append-Only File) — `appendonly yes`, `appendfsync everysec` |
| Eviction Policy | `allkeys-lru` — evicts least recently used when memory limit reached |
| Max Memory | `512mb` |
| Data Volume | `sdxcore-redis-data` |

**Connection string used by microservices:**
```
sdxcore.redis:6379
```

### Elasticsearch — `sdxcore.elasticsearch`

| Property | Value |
|----------|-------|
| Image | `docker.elastic.co/elasticsearch/elasticsearch:8.13.0` |
| Mode | `single-node` (development) |
| Host Port | `9200` (HTTP API), `9300` (cluster transport) |
| Security | Disabled for local dev (`xpack.security.enabled=false`) |
| Heap Size | Configurable via `ES_JAVA_OPTS` — default `-Xms512m -Xmx512m` |
| Data Volume | `sdxcore-elasticsearch-data` |

**Connection string used by microservices:**
```
http://sdxcore.elasticsearch:9200
```

### Kibana — `sdxcore.kibana`

| Property | Value |
|----------|-------|
| Image | `docker.elastic.co/kibana/kibana:8.13.0` |
| Host Port | `5601` |
| Elasticsearch | `http://sdxcore.elasticsearch:9200` |
| Purpose | Index management, data exploration, dev tooling |

Access at: `http://localhost:5601`

### RabbitMQ — `sdxcore.rabbitmq`

| Property | Value |
|----------|-------|
| Image | `rabbitmq:3.13-management-alpine` |
| AMQP Port | `5672` |
| Management UI Port | `15672` |
| Default VHost | `sdxcore` |
| Default User | `sdxcore` |
| Data Volume | `sdxcore-rabbitmq-data` |
| Retry / DLQ | Configured per-queue by consumer services at startup |

**Connection used by microservices:**
```
Host:        sdxcore.rabbitmq
Port:        5672
VirtualHost: sdxcore
```

Management UI: `http://localhost:15672` (user/pass from `.env`)

---

## RabbitMQ — Exchange, Queue & DLQ Topology

All topology (exchanges, queues, bindings, DLQs) is declared by consumer services at startup using a `IRabbitMqTopologyConfigurator` abstraction from `SdxCore.Common`. This ensures topology is reproducible and version-controlled in code.

### Exchange Convention

| Exchange Name | Type | Purpose |
|---------------|------|---------|
| `sdxcore.events` | topic | All domain events from all microservices |
| `sdxcore.events.dlx` | fanout | Dead letter exchange — receives failed/expired messages |

### Queue Naming Convention
```
sdxcore.{consumer-service}.{purpose}
```

Examples:
```
sdxcore.cache.employee.invalidate
sdxcore.elasticsearch.employee.index
sdxcore.notification.email.send
sdxcore.cache.time.invalidate
sdxcore.elasticsearch.time.index
```

### DLQ Convention
Every queue declares a corresponding Dead Letter Queue:
```
sdxcore.{consumer-service}.{purpose}.dlq
```

### Retry Policy
Each queue is configured with:
- `x-message-ttl` — per-attempt TTL before routing to DLQ (e.g., 60000ms).
- `x-dead-letter-exchange` — routes failed messages to `sdxcore.events.dlx`.
- `x-dead-letter-routing-key` — preserves original routing key on DLQ.
- Consumer-side retry: up to 3 attempts with exponential backoff before final DLQ routing.

---

## Shared File Volume — `sdxcore-files`

| Property | Value |
|----------|-------|
| Volume Name | `sdxcore-files` |
| Mount Path (all services) | `/mnt/sdxcore-files` |
| Host Bind Path | `./volumes/sdxcore-files` |
| Driver | `local` (bind mount) |

**Pre-requisite — create host directory before first run:**
```bash
mkdir -p ./docker/volumes/sdxcore-files
chmod 777 ./docker/volumes/sdxcore-files    # Linux/macOS only
```

Every service that handles file upload or download mounts this volume. Services that have no file operations (e.g., Attendance, Workflow in early phases) omit the volume mount.

---

## Service Dependency Order

Docker Compose `depends_on` with `condition: service_healthy` enforces this startup order:

```
1. sdxcore.sqlserver          (healthcheck: sqlcmd SELECT 1)
2. sdxcore.identity.sqlserver (healthcheck: sqlcmd SELECT 1)
3. sdxcore.redis              (healthcheck: redis-cli ping)
4. sdxcore.rabbitmq           (healthcheck: rabbitmq-diagnostics ping)
5. sdxcore.elasticsearch      (healthcheck: curl /_cluster/health)
6. sdxcore.kibana             (depends on elasticsearch)
7. sdxcore.identity.api       (depends on identity sqlserver + redis + rabbitmq)
8. sdxcore.*.api              (depends on sqlserver + redis + rabbitmq)
9. sdxcore.gateway.api        (depends on sqlserver + redis + rabbitmq)
```

---

## Running the Full Stack

### First-Time Setup

```bash
# 1. Copy environment template
cp docker/.env.example docker/.env
# Edit docker/.env with your passwords and keys

# 2. Create shared file storage directory
mkdir -p docker/volumes/sdxcore-files

# 3. Start infrastructure only (SQL Server, Redis, ES, RabbitMQ)
cd docker
docker-compose up sdxcore.sqlserver sdxcore.identity.sqlserver sdxcore.redis sdxcore.rabbitmq sdxcore.elasticsearch sdxcore.kibana -d

# 4. Run Elasticsearch index setup
.\SdxCore.Elasticsearch\scripts\Manage-Indices.ps1 -Action CreateAll -Environment development -ElasticsearchUrl "http://localhost:9200"

# 5. Start all application services
docker-compose up -d
```

### Infrastructure Only (Without Application Services)

```bash
docker-compose up sdxcore.sqlserver sdxcore.identity.sqlserver sdxcore.redis sdxcore.rabbitmq sdxcore.elasticsearch sdxcore.kibana -d
```

### Tear Down (Preserve Data)

```bash
docker-compose down
```

### Full Reset (Destroy All Data)

```bash
docker-compose down -v
rm -rf docker/volumes/sdxcore-files/*
```

---

## Local Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| API Gateway | `http://localhost:5000` | JWT via Identity |
| Identity API | `http://localhost:5001` | — |
| Time API | `http://localhost:5002` | — |
| Shared API | `http://localhost:5003` | — |
| Employee API | `http://localhost:5004` | — |
|
| ... any further api ... |  
|
| SQL Server (SdxCore) | `localhost,1433` | `sa` / from `.env` |
| SQL Server (Identity) | `localhost,1434` | `sa` / from `.env` |
| Redis | `localhost:6379` | from `.env` |
| Elasticsearch | `http://localhost:9200` | none (dev) |
| Kibana | `http://localhost:5601` | none (dev) |
| RabbitMQ Management | `http://localhost:15672` | from `.env` |

---

## `appsettings.json` — Microservice Configuration Template

Every microservice follows this standard `appsettings.json` structure:

```json
{
  "ConnectionStrings": {
    "SdxCoreDb": "Server=localhost,1433;Database=SdxCoreDb;User Id=sa;Password=YourPassword;TrustServerCertificate=True;"
  },
  "Gateway": {
    "InternalApiKey": "sdxcore-internal-secret-key-change-in-prod"
  },
  "Redis": {
    "ConnectionString": "localhost:6379",
    "InstanceName": "sdxcore:",
    "DefaultTtlMinutes": 30
  },
  "Elasticsearch": {
    "Url": "http://localhost:9200",
    "DefaultIndex": "sdxcore-{module}-read",
    "RequestTimeout": 30
  },
  "RabbitMQ": {
    "Host": "localhost",
    "Port": 5672,
    "VirtualHost": "sdxcore",
    "Username": "sdxcore",
    "Password": "sdxcore_secret",
    "ExchangeName": "sdxcore.events",
    "DeadLetterExchange": "sdxcore.events.dlx"
  },
  "FileStorage": {
    "ProviderType": "SharedFileSystem",
    "SharedFileSystem": {
      "RootPath": "/mnt/sdxcore-files",
      "Environment": "development",
      "Tenant": "sdxcore"
    }
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

---

## Adding a New Microservice to the Stack

When adding a future microservice (e.g., `SdxCore.Helpdesk.API`), follow this checklist:

1. Add a new service block to `docker-compose.yml` following the same pattern as `sdxcore.employee.api`.
2. Add the `sdxcore-files` volume mount if the service handles file uploads.
3. Add the corresponding `HELPDESK_PORT` to `.env.example` and `.env`.
4. Add the YARP cluster entry to the Gateway environment variables.
5. Add the service to the `sdxcore-net` network.
6. Declare `depends_on` for `sqlserver`, `redis`, and `rabbitmq` at minimum.
7. Add Elasticsearch dependency if the service publishes search-indexable events.
8. Create the Elasticsearch index definition under `SdxCore.Elasticsearch/helpdesk/`.
9. Run `Manage-Indices.ps1 -Action CreateAll` after adding the new index files.