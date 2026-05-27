# SdxCore — Caching Architecture

---

## Overview

SdxCore implements a **two-layer caching architecture** across all microservices. Every service independently manages its own L1 and L2 cache layers using shared abstractions from `BuildingBlocks/SdxCore.Common`. Cache invalidation is driven by the event-driven outbox pattern — when data changes, a RabbitMQ event is published and a dedicated background consumer refreshes both cache layers across all service instances.

---

## Cache Layer Summary

| Layer | Type | Scope | TTL | Technology |
|-------|------|-------|-----|------------|
| L1 | In-Memory | Per service instance | Very short (seconds to minutes) | `IMemoryCache` (.NET built-in) |
| L2 | Distributed | Cross-instance, cross-service | Medium (minutes to hours) | Redis |

---

## L1 — In-Memory Cache (Local Cache)

### Purpose
Absorbs repeated hot reads within a single service instance. Eliminates redundant round trips to Redis for the most frequently accessed data within a short time window.

### Characteristics
- Lives inside the service process — no network call required.
- Invalidated automatically by TTL expiry or explicit eviction.
- Lost on service restart or pod termination — L2 acts as the fallback.
- Each service instance maintains its own independent L1 — no cross-instance synchronization at this layer.

### TTL Guidelines

| Data Category | Recommended L1 TTL |
|---------------|-------------------|
| Static master data (countries, timezones) | 10–15 minutes |
| Lookup data (StatusLookup, designations) | 5–10 minutes |
| Employee core profile | 2–5 minutes |
| Employee org assignments (dept, location) | 2–3 minutes |
| Session/token validation results | 30–60 seconds |
| Real-time aggregates | 10–30 seconds |

### Cache Key Convention (L1)
```
{ServiceName}:{EntityName}:{Identifier}
```

Examples:
```
employee:employee:1042
employee:skill:all
time:department:tree
shared:statuslookup:EMPLOYMENT_TYPE
```

---

## L2 — Distributed Cache (Redis)

### Purpose
Shares cached data across all instances of a service and, where applicable, across different services. Acts as the primary cache source when L1 is cold (after restart, TTL expiry, or first access).

### Characteristics
- Shared across all instances of a service — single source of truth for cached state.
- Survives individual service restarts.
- Explicitly invalidated via RabbitMQ-triggered cache consumer events.
- Serialized as JSON.

### TTL Guidelines

| Data Category | Recommended L2 TTL |
|---------------|-------------------|
| Static master data (countries, timezones) | 60–120 minutes |
| Lookup data (StatusLookup, designations) | 30–60 minutes |
| Employee core profile | 15–30 minutes |
| Employee org assignments | 10–20 minutes |
| Paged list results | 5–10 minutes |
| Session/token validation results | Match JWT expiry |
| Search results | 2–5 minutes |

### Cache Key Convention (L2)
```
sdxcore:{environment}:{service}:{entity}:{identifier}
```

Examples:
```
sdxcore:prod:employee:employee:1042
sdxcore:prod:employee:employee:all:page:1:size:20
sdxcore:prod:time:department:tree
sdxcore:prod:shared:statuslookup:EMPLOYMENT_TYPE
sdxcore:prod:employee:skill:category:backend
```

### Key Naming Rules
- All lowercase, colon-delimited segments.
- `{environment}` — `dev`, `staging`, `prod`.
- `{service}` — matches microservice name: `employee`, `time`, `hr`, `payroll`, etc.
- `{entity}` — singular entity name: `employee`, `department`, `skill`.
- `{identifier}` — entity ID, `all`, or filter hash for list queries.
- Paged list keys must encode `page` and `size` to avoid stale page results.

---

## Read-Through Strategy (Per Request)

Every cache-eligible read follows this sequence:

```
Incoming Request
      │
      ▼
Check L1 (IMemoryCache)
      │
   HIT ──────────────────────────────► Return L1 result
      │
   MISS
      │
      ▼
Check L2 (Redis)
      │
   HIT ──► Populate L1 with short TTL ► Return L2 result
      │
   MISS
      │
      ▼
Query Primary Database (SQL Server)
      │
      ▼
Populate L2 (Redis) with medium TTL
      │
      ▼
Populate L1 (IMemoryCache) with short TTL
      │
      ▼
Return result
```

---

## Cache Invalidation Strategy

Cache invalidation is **event-driven** — no direct cache writes from business services after the initial population. Invalidation follows this flow:

```
Business Service writes to SQL Server + Outbox (same transaction)
      │
      ▼
Background Outbox Publisher reads pending outbox records
      │
      ▼
Publishes domain event to RabbitMQ
      │
      ▼
Cache Consumer Service receives event
      │
      ▼
Deletes or refreshes L2 Redis keys
      │
      ▼
L1 expires naturally via TTL (or is evicted explicitly if within same instance)
```

### Invalidation Patterns by Operation

| Operation | L2 Keys Invalidated |
|-----------|-------------------|
| Create employee | `employee:all:*` (all paged list keys) |
| Update employee | `employee:{id}`, `employee:all:*` |
| Toggle employee status | `employee:{id}`, `employee:all:*` |
| Update photo / about | `employee:{id}` |
| Assign department | `employee:{id}`, `department:{deptId}:members` |
| Update designation | `employee:{id}`, `time:designation:all` |
| Create/update skill | `skill:{id}`, `skill:all`, `skill:category:*` |
| Create/update team | `team:{id}`, `team:all` |
| Update StatusLookup | `shared:statuslookup:{group}` |

### Wildcard Invalidation
Redis key patterns use `*` suffix for bulk invalidation of list/paged keys:
```
sdxcore:prod:employee:employee:all:*   → invalidates all paged employee lists
sdxcore:prod:employee:skill:category:* → invalidates all category-filtered skill lists
```

---

## Cache Regions by Microservice

### `employee` service
| Cache Key Pattern | Contents |
|-------------------|---------|
| `employee:employee:{id}` | Core employee profile |
| `employee:employee:all:page:{n}:size:{n}` | Paged employee list |
| `employee:employee:code:{code}` | Employee by code |
| `employee:employee:email:{email}` | Employee by email |
| `employee:skill:all` | All active skills |
| `employee:skill:{id}` | Skill detail |
| `employee:skill:category:{cat}` | Skills by category |
| `employee:team:all` | All active teams |
| `employee:team:{id}` | Team detail |
| `employee:team:{id}:members` | Team member list |

### `time` service
| Cache Key Pattern | Contents |
|-------------------|---------|
| `time:timezone:all` | All timezones |
| `time:country:all` | All countries |
| `time:region:tree` | Full region hierarchy tree |
| `time:department:tree` | Full department hierarchy tree |
| `time:designation:all` | All designations |
| `time:officelocation:all` | All office locations |
| `time:legalentity:all` | All legal entities |

### `shared` service
| Cache Key Pattern | Contents |
|-------------------|---------|
| `shared:statuslookup:{group}` | All entries for a StatusLookup group |
| `shared:statuslookup:all` | Full StatusLookup table |

---

## Redis Configuration (`appsettings.json`)

```json
{
  "Redis": {
    "ConnectionString": "localhost:6379",
    "InstanceName": "sdxcore:",
    "DefaultTtlMinutes": 30,
    "AbortOnConnectFail": false,
    "ConnectTimeout": 5000,
    "SyncTimeout": 1000
  }
}
```

### Environment Overrides

| Environment | Redis Connection |
|-------------|-----------------|
| Development | `localhost:6379` (Docker) |
| Staging | `redis-staging:6379` |
| Production | Redis Cluster / Sentinel endpoint |

---

## Cache Consumer — Event-Driven Invalidation Flow

A dedicated background service (or worker within each microservice) subscribes to domain events from RabbitMQ and handles cache invalidation:

```
RabbitMQ Exchange: sdxcore.events
      │
      ├── Queue: cache.employee.invalidate
      │         → Consumed by Employee cache consumer
      │         → Deletes/refreshes employee Redis keys
      │
      ├── Queue: cache.time.invalidate
      │         → Consumed by Time cache consumer
      │         → Deletes/refreshes time Redis keys
      │
      └── Queue: cache.shared.invalidate
                → Consumed by Shared cache consumer
                → Deletes/refreshes StatusLookup Redis keys
```

All cache consumers must be **idempotent** — receiving the same cache invalidation event twice must not cause errors or inconsistency.

---

## Idempotency in Cache Operations

| Scenario | Handling |
|----------|---------|
| Duplicate invalidation event | Deleting a non-existent Redis key is a no-op — safe. |
| Duplicate refresh event | Redis SET with TTL is idempotent — overwrites with same data. |
| Out-of-order events | Last writer wins — TTL ensures eventual consistency. |
| Redis unavailable | L1 continues to serve. DB fallback activates. Log and alert. |

---

## BuildingBlocks Integration

Cache abstractions live in `SdxCore.Common` to ensure every microservice uses identical patterns:

```
src/BuildingBlocks/SdxCore.Common/
    ├── Caching/
    │   ├── ICacheService.cs              # Unified L1+L2 interface
    │   ├── CacheService.cs               # Default implementation (L1 → L2 → DB)
    │   ├── CacheKeyBuilder.cs            # Standardized key generation
    │   └── CacheOptions.cs               # Per-entity TTL configuration
```

Each microservice registers `ICacheService` via the shared `AddSdxCaching(config)` extension and uses it uniformly — no direct `IMemoryCache` or `IDistributedCache` calls in business code.

---

## Monitoring & Observability

| Metric | Description |
|--------|-------------|
| `cache.l1.hit_rate` | Percentage of requests served from L1 |
| `cache.l2.hit_rate` | Percentage of requests served from L2 |
| `cache.db.fallback_count` | Number of DB fallbacks (both caches missed) |
| `cache.invalidation.lag_ms` | Time between DB write and cache invalidation |
| `redis.connection.errors` | Redis connectivity failures |

All cache metrics are emitted as structured logs and can be indexed into Elasticsearch for dashboard visualization.