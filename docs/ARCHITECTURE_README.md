# SdxCore Microservices Ecosystem

SdxCore is a modern, scalable, and highly cohesive microservices architecture built on **.NET 9.0**. It follows strict Clean Architecture principles, utilizing a centralized YARP Gateway, dynamic pluggable authentication, and a standardized boilerplate for rapid service development.

## 🏛️ Architecture Overview

The SdxCore ecosystem is designed around a reverse-proxy gateway pattern with clearly isolated doain boundaries for individual microservices.

```text
                                                                            Client Request 
                                                                                │
                                                                                ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   SdxCore.Gateway.API (YARP)      │──► Validates JWT locally (or delegates)                                                                 │
│                                   Injects X-User-Id & X-Roles     │──► Handles external rate-limiting                                                                       │
└────────────────────────────────────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                 │ Proxy Forwarding (Header-Based Context Propagation)
       ┌────────────────────────┬────────────────┴───┬─────────────────────┬────────────────────┬────────────────────┬────────────────────┬─────────────────┐ 
       ▼                        ▼                    ▼                     ▼                    ▼                    ▼                    ▼                 ▼
┌──────────────┐        ┌──────────────┐    ┌────────────────┐   ┌────────────────┐    ┌────────────────┐   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Identity.API │        │   Time.API   │    │  Employee.API  │   │   Shared.API   │    │     HR.API     │   │  Payroll.API    │ │ Attendance.API  │ │   Workflow.API  │     ....Future Microservices can be added here in future
└──────────────┘        └──────────────┘    └────────────────┘   └────────────────┘    └────────────────┘   └─────────────────┘ └─────────────────┘ └─────────────────┘
       │                        │              │                          │                    │                   │                     │                     │                        
       ▼                        ▼              ▼                          ▼                    ▼                   ▼                     ▼                     ▼
┌─────────────────┐     ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│   SQL Server    │     │                                                                 SQL Server                                                                          │
├─────────────────┤     ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ SdxIdentity     │     │                                        SdxCore Database Schema microservices wise                                                                   │
|   Database      |     |                                                        │── [shared].*                                                                               │
|                 |     |                                                        │── [time].*                                                                                 │
└─────────────────┘     |                                                        │── [workflow].*                                                                             │
                        |                                                        │── [employee].*                                                                             │
                        |                                                        │── [payroll].*                                                                              │
                        |                                                        │── [hr].*                                                                                   │
                        |                                                        |── [event].*                                                                                │
                        |                                                        ├── [helpdesk].*                                                                             │
                        |                                                        ├── [attendance].*                                                                           │
                        |                                                        └── [survey].*                                                                               │
                        |                                                        ├── [auth].*                                                                                 │
                        └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


```

### Layered Clean Architecture (Per Service)
Every downstream microservice is built using a strict 4-layer clean architecture:
1. **API**: Presentation layer (Controllers, Middleware, `[GatewayOnly]` constraints).
2. **Application**: Business logic, Services, DTO mapping (`Request`/`Response`), and Validation.
3. **Domain**: Core entities, Enums, Exceptions, and Repository Interfaces.
4. **Persistence**: EF Core DbContext, Migrations, and generic `BaseRepository` implementations.

---

## 🏗️ Project Structure & Dependencies

```text
SdxCore/
├── src/
│   ├── Gateway/
│   │   └── SdxCore.Gateway.API          # YARP reverse proxy & Auth interception
│   ├── Services/
│   │   ├── Identity/                    # Manages Auth, Users, Roles, JWTs
│   │   │   ├── SdxCore.Identity.API
│   │   │   ├── SdxCore.Identity.Application
│   │   │   ├── SdxCore.Identity.Domain
│   │   │   └── SdxCore.Identity.Persistence
│   │   ├── Shared/ 
│   │   │   ├── SdxCore.Shared.API
│   │   │   ├── SdxCore.Shared.Application
│   │   │   ├── SdxCore.Shared.Domain
│   │   │   └── SdxCore.Shared.Persistence
│   │   ├── Time/                        # Domain service (Regions, Biometrics, GeoFences)
│   │   │   ├── SdxCore.Time.API
│   │   │   ├── SdxCore.Time.Application
│   │   │   ├── SdxCore.Time.Domain
│   │   │   └── SdxCore.Time.Persistence
│   │   ├── Workflow. 
│   │   │   ├── SdxCore.Workflow.API
│   │   │   ├── SdxCore.Workflow.Application
│   │   │   ├── SdxCore.Workflow.Domain
│   │   │   └── SdxCore.Workflow.Persistence
│   │   ├── Employee. 
│   │   │   ├── SdxCore.Employee.API
│   │   │   ├── SdxCore.Employee.Application
│   │   │   ├── SdxCore.Employee.Domain
│   │   │   └── SdxCore.Employee.Persistence
│   │   ├── HR.
│   │   │   ├── SdxCore.HR.API
│   │   │   ├── SdxCore.HR.Application
│   │   │   ├── SdxCore.HR.Domain
│   │   │   └── SdxCore.HR.Persistence
│   │   ├── Payroll.
│   │   │   ├── SdxCore.Payroll.API
│   │   │   ├── SdxCore.Payroll.Application
│   │   │   ├── SdxCore.Payroll.Domain
│   │   │   └── SdxCore.Payroll.Persistence
│   │   ├── Attendance. 
│   │   │   ├── SdxCore.Attendance.API
│   │   │   ├── SdxCore.Attendance.Application
│   │   │   ├── SdxCore.Attendance.Domain
│   │   │   └── SdxCore.Attendance.Persistence
│   │   ├── Survey. 
│   │       ├── SdxCore.Survey.API
│   │       ├── SdxCore.Survey.Application
│   │       ├── SdxCore.Survey.Domain
│   │       └── SdxCore.Survey.Persistence  
│   └── BuildingBlocks/                  # Shared libraries referenced by services
│       ├── SdxCore.Common               # Base models (ApiResponse, RequestContext, BaseEntity)
│       ├── SdxCore.Contracts            # Event/Message Bus Contracts (Future)
│       └── SdxCore.SharedKernel         # Core abstractions
├── src/Database/
│   └── SdxCore.Database                 # SSDT Project & PowerShell Migration Scripts
├── tests/                               # Unit and Integration Tests
│   ├── Identity.Tests/                 
│   ├── Time.Tests/
│   ├── Employee.Tests/
│   ├── HR.Tests/
│   ├── Payroll.Tests/
│   ├── Attendance.Tests/
│   ├── Survey.Tests/
│   ├── Gateway.Tests/
│   ├── Common.Tests/
│   ├── Contracts.Tests/
│   ├── SharedKernel.Tests/
│   └── Database.Tests/
│   
└── docker/
    └── docker-compose.yml              # Local SQL Server orchestration
                                        # Redis
                                        # Elasticsearch
                                        # RabbitMQ 
```

---

## ⚙️ Core Implementation Details

### 1. Pluggable Authentication Module (Identity Service)
The Identity service supports dynamic, configuration-driven authentication protocols:
- **InHouse**: SQL Server-backed username/password authentication (Argon2id hashing).
- **SAML 2.0 / OAuth 2.0 / OIDC / LDAP**: Enterprise SSO integrations.
*Configuration dictates which provider is injected at runtime in `Program.cs`.*

### 2. Delegated Authentication & The `[GatewayOnly]` Attribute
Downstream services (like `Time.API`) are **oblivious to JWTs**. 
- The Gateway intercepts the request, validates the JWT, and enriches the downstream HTTP headers with `X-User-Id`, `X-Roles`, etc.
- Downstream endpoints are protected by a `[GatewayOnly]` attribute, a security filter that rejects direct external requests, ensuring all traffic funnels through the enriched YARP Gateway context.
- Inside the services, the `IRequestContext` is automatically populated with the user details from these headers.

### 3. Generic Repository & Audit Trails
The Persistence layer heavily utilizes a `BaseRepository<TEntity, TKey>`.
- Automatically injects `CreatedAt`, `CreatedBy`, `LastUpdatedAt`, and `LastUpdatedBy` using the `IRequestContext` via reflection during EF Core `SaveChanges`.
- Standardizes CRUD (GetById, GetAllPagedAsync, FindAsync, Add, Update).

### 4. Global Soft Delete Pattern
Hard deletes are strictly prohibited across the ecosystem.
- `DELETE` HTTP verbs are replaced with `HttpPatch("{id}/status")`.
- Services implement a `ToggleStatusAsync` method mutating the `IsActive` boolean flag on the base entity.

### 5. DTO Architecture Standardization
Strict suffixing conventions map Domain Entities to external representations:
- **Requests**: `Create{Entity}Request`, `Update{Entity}Request`
- **Responses**: `{Entity}Response` (E.g., `RegionResponse`)
- **Envelopes**: All API responses are wrapped in `ApiResponse<T>` or `PagedResponse<T>` to maintain strict frontend contract normalization.

---

## 🚀 Setup Instructions

### Prerequisites
- **.NET 9.0 SDK**
- **SQL Server** (LocalDB, Docker, or full instance)
- **Docker** (optional, for rapid local database spinning)

### 1. Start Local Databases
The ecosystem utilizes a multi-schema approach. The `Identity` service gets its own isolated database, while all other downstream microservices (like `Time`) share a central database but isolate their tables using SQL Schemas (e.g., `[time].[Regions]`). 

You can spin up an instance using the provided Docker compose file:
```bash
cd docker
docker-compose up sql-server -d
```

### 2. Database Migrations
SdxCore utilizes EF Core alongside SSDT PowerShell scripts for generating strict `Full.sql` and `Delta.sql` sprint-based artifacts.
To generate your local databases via EF Core:
```bash
# Update Identity Database
dotnet ef database update --project src/Services/Identity/SdxCore.Identity.Persistence --startup-project src/Services/Identity/SdxCore.Identity.API

# Update Time Database
dotnet ef database update --project src/Services/Time/SdxCore.Time.Persistence --startup-project src/Services/Time/SdxCore.Time.API
```

### 3. Run the Microservices

You must start the Identity Service, the Time Service, and the Gateway.

**Terminal 1 (Identity Service):**
```bash
dotnet run --project src/Services/Identity/SdxCore.Identity.API
# Runs on https://localhost:5001
```

**Terminal 2 (Time Service):**
```bash
dotnet run --project src/Services/Time/SdxCore.Time.API
# Runs on https://localhost:5002
```

**Terminal 3 (Gateway):**
```bash
dotnet run --project src/Gateway/SdxCore.Gateway.API
# Runs on https://localhost:5000
```

### 4. Testing the Flow
Generate a token from the Identity service, then query the Time service through the Gateway:
```bash
# 1. Login
curl -X POST https://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "Password123!"}'

# 2. Query Time Service (Via Gateway)
curl -X GET https://localhost:5000/api/v1/regions \
  -H "Authorization: Bearer <YOUR_TOKEN_HERE>"
```

---

## 🧪 Testing

### Run All Tests
```bash
dotnet test tests/Identity.Tests/
```

### Categories
- **Unit Tests**: Isolated domain and application logic.
- **Integration Tests**: In-memory database endpoint testing.
- **Property Tests**: FsCheck validations for authentication algorithms.

---

## 🛠️ Contributing & Development Standards

When extending SdxCore or adding a new microservice, adhere to the following ecosystem laws:
1. **No direct database access in the API layer**. Always route through Application Services -> Domain Interfaces -> Persistence Repositories.
2. **Never hard-delete records**. Always implement `PATCH /status` and utilize the `IsActive` flag.
3. **Data Types**: System Identifiers mapping to `SMALLINT` in SQL Server must use `short` in C#. System Identifiers mapping to `INT` must use `int`. (e.g. BiometricDevice uses `int`).
4. **Service-to-Service Auth**: Downstream APIs should not implement JWT logic. Decorate controllers with `[GatewayOnly]` and trust the Gateway's internal API Key and Header enrichment. 
5. **Standardized Responses**: Always return data wrapped in `ApiResponse<T>` or `PagedResponse<T>` with a descriptive success message.