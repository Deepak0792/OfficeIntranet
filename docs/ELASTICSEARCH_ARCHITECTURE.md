# SdxCore — Elasticsearch Architecture

---

## Overview

SdxCore uses Elasticsearch as a **dedicated search and analytics layer** — separate from the SQL Server primary database. No microservice queries Elasticsearch directly for CRUD operations. Elasticsearch is populated and kept in sync exclusively via the **event-driven outbox pipeline**: SQL Server → Outbox → RabbitMQ → Elasticsearch Consumer.

All Elasticsearch index definitions, mappings, aliases, analyzers, ingest pipelines, and management scripts should be centralized under the `src/Elasticsearch/` directory, positioned parallel to the Gateway folder. This ensures a single source of truth for index schemas, independent of any microservice.

---

## Data Flow: SQL Server → Elasticsearch

```
Business Service writes to SQL Server + Outbox (same transaction)
      │
      ▼
Background Outbox Publisher reads pending outbox records
      │
      ▼
Publishes domain event to RabbitMQ
      (exchange: sdxcore.events, routing key: {service}.{entity}.{action})
      │
      ▼
Elasticsearch Consumer Service receives event
      │
      ▼
Performs upsert / delete into Elasticsearch index
      │
      ▼
Marks outbox record as published
```

All consumers must implement **idempotent processing** — processing the same event twice must always produce the same index state.

---

## Idempotency in Elasticsearch Consumers

| Scenario | Handling |
|----------|---------|
| Duplicate create event | Use `_id`-based upsert (`index` or `update` with `doc_as_upsert: true`) |
| Duplicate update event | Upsert overwrites with latest data — safe |
| Duplicate delete event | Deleting a non-existent document returns 404 — consumer must treat as success |
| Out-of-order events | Include `LastUpdatedAt` in document; consumers reject stale writes via version check or `if_seq_no` / `if_primary_term` |
| Partial failure | Outbox record stays unpublished — retried by publisher on next poll cycle |

---

## Solution Structure

```
SdxCore/
└── SdxCore.Elasticsearch/
    ├── shared/
    │   ├── common-settings.json                 # Shared index settings (shards, replicas, refresh interval)
    │   ├── common-analyzers.json                # Autocomplete, lowercase, edge-ngram, keyword analyzers
    │   ├── common-token-filters.json            # Shared token filters (lowercase, stop, synonym, ascii-folding)
    │   ├── common-normalization-pipeline.json   # Ingest pipeline: normalize text, strip HTML, trim whitespace
    │   └── common-timestamp-pipeline.json       # Ingest pipeline: enrich with indexed_at timestamp
    │
    ├── employees/
    │   ├── mappings.json                        # employee index field mappings
    │   └── aliases.json                         # employee index aliases
    │
    ├── time/
    │   ├── mappings.json                        # time (departments, designations, offices) mappings
    │   └── aliases.json
    │
    ├── hr/
    │   ├── mappings.json
    │   └── aliases.json
    |
    |    .... any further modules ....
    │
    └── scripts/
        ├── Manage-Indices.ps1                   # Create/update indices, aliases, pipelines
        ├── Rebuild-Index.ps1                    # Full reindex with zero-downtime alias switch
        ├── Validate-Index.ps1                   # Validate document count, mappings, aliases post-reindex
        └── Retire-OldIndices.ps1                # Remove old versioned indices after alias switch
```

---

## Index Naming & Versioning Convention

All indices follow a versioned naming scheme managed exclusively by PowerShell scripts:

```
sdxcore-{module}-v{version}
```

Examples:
```
sdxcore-employees-v1
sdxcore-employees-v2          ← new version during reindex
sdxcore-time-v1
sdxcore-hr-v1
sdxcore-payroll-v1
```

### Alias Convention

Each module exposes two aliases:

| Alias | Points To | Purpose |
|-------|-----------|---------|
| `sdxcore-{module}-read` | Current active index | All search/read queries |
| `sdxcore-{module}-write` | Current active index | All indexing/upsert operations |

During zero-downtime reindexing, `write` is switched to the new versioned index first, then `read` is switched after validation — ensuring no search downtime and no missed writes.

---

## Zero-Downtime Reindex Flow

```
1. Create New Versioned Index
   sdxcore-employees-v2 (with updated mappings)
         │
         ▼
2. Point write alias to new index
   sdxcore-employees-write → sdxcore-employees-v2
   sdxcore-employees-read  → sdxcore-employees-v1  (unchanged — reads still work)
         │
         ▼
3. Populate New Index
   Rebuild service reads from SQL Server, bulk-indexes all records into v2
         │
         ▼
4. Validate New Index
   Validate-Index.ps1 — compare document counts, spot-check records
         │
         ▼
5. Switch Read Alias
   sdxcore-employees-read → sdxcore-employees-v2
         │
         ▼
6. Retire Old Index
   Retire-OldIndices.ps1 — delete sdxcore-employees-v1
```

This sequence enables:
- **Zero search downtime** — reads serve from v1 until v2 is validated.
- **No missed writes** — write alias switches to v2 before population starts; new events index into v2 during rebuild.
- **Rollback support** — if validation fails, `read` alias remains on v1; v2 is deleted and retried.
- **Versioned index management** — PowerShell scripts auto-increment version numbers.

---

## Shared Settings (`shared/common-settings.json`)

Applied to every module index at creation time:

```json
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "refresh_interval": "1s",
    "max_result_window": 10000,
    "analysis": {
      "analyzer": {},
      "tokenizer": {},
      "filter": {}
    }
  }
}
```

> `number_of_shards` and `number_of_replicas` are overridden per-environment via PowerShell parameter. Development uses `1` shard, `0` replicas. Production uses environment-appropriate values.

---

## Shared Analyzers (`shared/common-analyzers.json`)

Reusable across all module mappings. Referenced by name in module-specific `mappings.json`.

| Analyzer Name | Type | Use Case |
|---------------|------|---------|
| `sdx_autocomplete` | edge-ngram (min 2, max 20) | Typeahead / prefix search on names |
| `sdx_autocomplete_search` | keyword + lowercase | Search-side analyzer matching autocomplete index |
| `sdx_lowercase` | standard + lowercase | General text search |
| `sdx_keyword_lowercase` | keyword + lowercase | Exact match, case-insensitive (email, codes) |
| `sdx_english` | english stemmer + stop words | Full-text English content search |

---

## Shared Ingest Pipelines

### `common-normalization-pipeline`
Applied at index time to all text fields. Steps:
1. Trim leading/trailing whitespace from all string fields.
2. Strip HTML tags from description/bio fields.
3. ASCII-fold special characters (é → e, ñ → n).
4. Lowercase all keyword fields for consistent matching.

### `common-timestamp-pipeline`
Enriches every indexed document with:
- `indexed_at` — UTC timestamp when the document was indexed into Elasticsearch.
- `index_version` — version string of the index the document was written to.

---

## Module Mapping Requirements

All module `mappings.json` files must declare:

```json
{
  "mappings": {
    "dynamic": "strict"
  }
}
```

`dynamic: strict` — Elasticsearch rejects any document containing fields not declared in the mapping. This enforces schema discipline and prevents silent data drift.

### Required Field Types

Every mapping must explicitly define:

| Field Type | Usage |
|------------|-------|
| `keyword` | IDs, codes, enums, email — exact match, aggregations, sorting |
| `text` | Names, descriptions — full-text search with analyzer |
| `text` + `keyword` (multi-field) | Fields that need both full-text search and exact match/sort |
| `nested` | Collections (departments, skills, teams) |
| `date` | `DateOfJoining`, `CreatedAt`, `ExpiryDate` |
| `boolean` | `IsActive`, `IsPrimary`, `IsVerified` |
| `integer` / `short` | Numeric IDs, counts |
| `float` / `double` | Allocation percentages, experience years |

---

## `employees` Index — Key Fields

The `employees` index is the primary search index. It is a **denormalized, read-optimized** document combining data from multiple `employee.*` tables.

```
sdxcore-employees-v{n}
├── employeeId              keyword
├── employeeCode            keyword
├── firstName               text (sdx_autocomplete) + keyword
├── lastName                text (sdx_autocomplete) + keyword
├── displayName             text (sdx_autocomplete) + keyword
├── email                   keyword (sdx_keyword_lowercase)
├── mobileNumber            keyword
├── employmentType          keyword
├── dateOfJoining           date
├── isActive                boolean
├── isSystemEmployee        boolean
├── aboutMe                 text (sdx_english)
├── designation
│   ├── id                  short
│   ├── code                keyword
│   └── name                text + keyword
├── primaryDepartment
│   ├── id                  short
│   ├── code                keyword
│   └── name                text + keyword
├── primaryLocation
│   ├── id                  short
│   ├── code                keyword
│   ├── name                text + keyword
│   └── city                keyword
├── primaryLegalEntity
│   ├── id                  short
│   └── name                text + keyword
├── manager
│   ├── id                  integer
│   ├── displayName         text + keyword
│   └── email               keyword
├── departments             nested
│   ├── id                  short
│   ├── name                keyword
│   └── isPrimary           boolean
├── skills                  nested
│   ├── id                  short
│   ├── name                keyword
│   ├── category            keyword
│   └── level               keyword
├── teams                   nested
│   ├── id                  short
│   └── name                keyword
├── createdAt               date
├── lastUpdatedAt           date
├── indexed_at              date          (from timestamp pipeline)
└── index_version           keyword       (from timestamp pipeline)
```

---

## RabbitMQ Event Routing to Elasticsearch Consumers

```
Exchange: sdxcore.events (topic)
      │
      ├── employee.employee.created      → Elasticsearch Employee Consumer → upsert into sdxcore-employees-write
      ├── employee.employee.updated      → Elasticsearch Employee Consumer → upsert into sdxcore-employees-write
      ├── employee.employee.status       → Elasticsearch Employee Consumer → upsert into sdxcore-employees-write
      ├── employee.department.assigned   → Elasticsearch Employee Consumer → update nested departments
      ├── employee.skill.assigned        → Elasticsearch Employee Consumer → update nested skills
      ├── employee.team.assigned         → Elasticsearch Employee Consumer → update nested teams
      ├── employee.relationship.created  → Elasticsearch Employee Consumer → update manager field
      │
      ├── time.department.created        → Elasticsearch Time Consumer → upsert into sdxcore-time-write
      ├── time.designation.created       → Elasticsearch Time Consumer → upsert into sdxcore-time-write
      │
      └── hr.*.* / payroll.*.* / ...     → Module-specific Elasticsearch consumers
```

---

## Full Index Rebuild — `Rebuild-Index.ps1`

The rebuild script is executed manually or via CI pipeline when:
- Index mappings change (schema evolution).
- Data drift is detected between SQL Server and Elasticsearch.
- A new module index is being bootstrapped.
- Post-disaster recovery.

### Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-Module` | Target index module | `employees`, `time`, `hr` |
| `-Environment` | Target environment | `development`, `staging`, `production` |
| `-ElasticsearchUrl` | Elasticsearch endpoint | `http://localhost:9200` |
| `-SqlConnectionString` | Source database connection | `Server=...;Database=SdxCoreDb;` |
| `-BatchSize` | Documents per bulk request | `500` |
| `-Validate` | Run validation before alias switch | `$true` / `$false` |

### Execution

```powershell
# Rebuild employees index in development
.\scripts\Rebuild-Index.ps1 `
    -Module employees `
    -Environment development `
    -ElasticsearchUrl "http://localhost:9200" `
    -SqlConnectionString "Server=localhost,1433;Database=SdxCoreDb;User Id=sa;Password=YourPassword;" `
    -BatchSize 500 `
    -Validate $true
```

---

## `Manage-Indices.ps1` — Day-to-Day Index Management

Used for:
- Creating a new index from scratch (first-time setup).
- Applying updated `common-settings.json` or `common-analyzers.json`.
- Registering new ingest pipelines.
- Creating or updating aliases without a full reindex.

```powershell
# Create all indices and aliases for development
.\scripts\Manage-Indices.ps1 `
    -Action CreateAll `
    -Environment development `
    -ElasticsearchUrl "http://localhost:9200"

# Apply updated mappings for employees module only
.\scripts\Manage-Indices.ps1 `
    -Action UpdateMappings `
    -Module employees `
    -Environment development `
    -ElasticsearchUrl "http://localhost:9200"
```

---

## Elasticsearch Configuration (`appsettings.json`)

```json
{
  "Elasticsearch": {
    "Url": "http://localhost:9200",
    "Username": "",
    "Password": "",
    "DefaultIndex": "sdxcore-employees-read",
    "RequestTimeout": 30,
    "EnableDebugMode": false
  }
}
```

---

## BuildingBlocks Integration

```
src/BuildingBlocks/SdxCore.Common/
    └── Search/
        ├── ISearchService.cs             # Generic search interface — used by all services
        └── ElasticsearchOptions.cs       # Typed config bound from appsettings
```

Each microservice registers the Elasticsearch client via `AddSdxSearch(config)` and interacts with Elasticsearch exclusively through `ISearchService`. No direct `ElasticClient` calls in business or controller code.