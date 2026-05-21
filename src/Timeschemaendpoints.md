# ASP.NET Core API Endpoints — `time` Schema
# Purpose: AI Prompt Reference — Full Endpoint Specification

---

## Schema Overview

**Schema:** `time`
**Purpose:** Time zones, countries, regions, office locations, legal entities, departments, scope types, designations, document types, geo-fences, biometric devices.

**Self-referencing tables:**
- `Region` — `ParentRegionId` (recursive hierarchy: State → District → City)
- `Department` — `ParentDepartmentId` (recursive hierarchy: HR → Payroll, Engineering → DevOps)

**Soft delete pattern:** All tables use `IsActive` flag. No hard deletes. Use `PATCH /{id}/status`.

---

## 1. Refactor my existing DTO Folder Structure:

**Folder Structure:**
- DTOs/Request
- DTOs/Response

**Naming Rules:**
- Request DTOs must end with "Request"
- Response DTOs must end with "Response"

**Examples:**
- CreateDepartmentRequest
- UpdateDepartmentRequest
- DepartmentResponse

**Requirements:**
- Use C#
- Use file-scoped namespaces
- Use PascalCase for properties
- Keep DTOs separated into Request and Response folders
- Follow clean architecture naming conventions
- Do not add business logic inside DTOs


## 2. TimeZoneMaster

**Base route:** `/api/timezones`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/timezones` | List all active time zones (dropdown population) |
| GET | `/api/timezones/{id}` | Get full time zone details including IANA / Windows IDs |
| GET | `/api/timezones/by-country/{countryCode}` | Time zones available for a given country code |
| POST | `/api/timezones` | Add a new time zone entry |
| PUT | `/api/timezones/{id}` | Update offset, DST flag, IANA or Windows mapping |
| PATCH | `/api/timezones/{id}/status` | Activate or deactivate a time zone |

**Key fields:** `TimeZoneCode`, `TimeZoneName`, `UtcOffset`, `OffsetMinutes`, `SupportsDaylightSaving`, `WindowsTimeZoneId`, `IanaTimeZoneId`, `CountryCode`, `IsActive`

---

## 3. Country

**Base route:** `/api/countries`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/countries` | List all active countries with default timezone |
| GET | `/api/countries/{id}` | Country detail including currency and timezone |
| POST | `/api/countries` | Add a new country |
| PUT | `/api/countries/{id}` | Update currency, timezone, display order |
| PATCH | `/api/countries/{id}/status` | Activate or deactivate a country |

**Key fields:** `CountryCode`, `CountryName`, `CurrencyCode`, `TimeZoneId` (FK → TimeZoneMaster), `DisplayOrder`, `IsActive`

---

## 4. Region  [SELF-REFERENCING]

**Base route:** `/api/regions`
**Self-reference:** `ParentRegionId` → `Region.Id`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/regions` | Flat list of all regions |
| GET | `/api/regions/tree` | Full recursive hierarchy tree (for UI tree-pickers) |
| GET | `/api/regions/by-country/{countryId}` | All regions belonging to a country |
| GET | `/api/regions/{id}` | Region detail with parent info |
| GET | `/api/regions/{id}/children` | Immediate child regions (lazy-loading) |
| GET | `/api/regions/{id}/ancestors` | Full parent chain — breadcrumb path to root |
| POST | `/api/regions` | Create region with optional parentRegionId |
| PUT | `/api/regions/{id}` | Update name, region type, display order |
| PATCH | `/api/regions/{id}/parent` | Re-parent region under a different node (org restructuring) |
| PATCH | `/api/regions/{id}/status` | Activate or deactivate |

**Key fields:** `CountryId` (FK → Country), `RegionName`, `RegionType`, `ParentRegionId` (FK → Region — self), `DisplayOrder`, `IsActive`

**Notes on hierarchy endpoints:**
- `GET /tree` returns a nested JSON tree — full recursive structure
- `GET /{id}/children` returns only immediate children (use for lazy tree expansion in UI)
- `GET /{id}/ancestors` returns ordered list from root to parent (use for breadcrumbs)
- `PATCH /{id}/parent` body: `{ "parentRegionId": <int|null> }` — null moves to root level

---

## 5. LegalEntity

**Base route:** `/api/legal-entities`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/legal-entities` | List all legal entities |
| GET | `/api/legal-entities/{id}` | Entity details with country info |
| GET | `/api/legal-entities/by-country/{countryId}` | All entities registered in a country |
| POST | `/api/legal-entities` | Register a new legal entity |
| PUT | `/api/legal-entities/{id}` | Update tax/registration numbers and currency |
| PATCH | `/api/legal-entities/{id}/status` | Activate or deactivate |

**Key fields:** `EntityCode`, `EntityName`, `CountryId` (FK → Country), `TaxIdentificationNumber`, `RegistrationNumber`, `CurrencyCode`, `IsActive`

---

## 6. OfficeLocation  [CENTRAL HUB]

**Base route:** `/api/offices`
**Dependencies:** LegalEntity, Country, Region (all FK), TimeZoneMaster (FK)

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/offices` | List all office locations |
| GET | `/api/offices/{id}` | Office detail — expanded with entity, region, timezone |
| GET | `/api/offices/by-legal-entity/{entityId}` | All offices under a legal entity |
| GET | `/api/offices/by-country/{countryId}` | Offices in a specific country |
| GET | `/api/offices/head-offices` | Filter: head offices only (IsHeadOffice = true) |
| GET | `/api/offices/{id}/geofences` | All geo-fences configured for this office |
| GET | `/api/offices/{id}/devices` | All biometric devices installed at this office |
| POST | `/api/offices` | Create a new office location |
| PUT | `/api/offices/{id}` | Update address, coordinates, timezone |
| PATCH | `/api/offices/{id}/status` | Activate or deactivate |
| PATCH | `/api/offices/{id}/head-office` | Toggle the IsHeadOffice flag |

**Key fields:** `LegalEntityId` (FK), `CountryId` (FK), `RegionId` (FK), `LocationCode`, `LocationName`, `BuildingName`, `AddressLine1`, `AddressLine2`, `City`, `StateProvince`, `PostalCode`, `Latitude`, `Longitude`, `TimeZoneId` (FK), `IsHeadOffice`, `IsActive`

---

## 7. Department  [SELF-REFERENCING]

**Base route:** `/api/departments`
**Self-reference:** `ParentDepartmentId` → `Department.Id`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/departments` | Flat list of all departments |
| GET | `/api/departments/tree` | Full recursive hierarchy tree (for org-chart pickers) |
| GET | `/api/departments/{id}` | Department detail |
| GET | `/api/departments/{id}/children` | Immediate child departments |
| GET | `/api/departments/{id}/ancestors` | Full parent chain to root (breadcrumb) |
| POST | `/api/departments` | Create department with optional parentDepartmentId |
| PUT | `/api/departments/{id}` | Update name and description |
| PATCH | `/api/departments/{id}/parent` | Move department under a new parent (re-org) |
| PATCH | `/api/departments/{id}/status` | Activate or deactivate |

**Key fields:** `DepartmentCode`, `DepartmentName`, `ParentDepartmentId` (FK → Department — self), `Description`, `IsActive`

**Notes on hierarchy endpoints:**
- Same tree pattern as Region — `/tree`, `/{id}/children`, `/{id}/ancestors`, `/{id}/parent`
- `PATCH /{id}/parent` body: `{ "parentDepartmentId": <int|null> }` — null makes it a root department

---

## 8. ScopeType

**Base route:** `/api/scope-types`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/scope-types` | List all scope types ordered by HierarchyLevel |
| GET | `/api/scope-types/{id}` | Scope type detail |
| POST | `/api/scope-types` | Create a new hierarchy level |
| PUT | `/api/scope-types/{id}` | Update name or reorder hierarchy level |
| PATCH | `/api/scope-types/{id}/status` | Activate or deactivate |

**Key fields:** `ScopeCode`, `ScopeName`, `HierarchyLevel`, `IsActive`

---

## 9. Designation

**Base route:** `/api/designations`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/designations` | List all designations |
| GET | `/api/designations/{id}` | Designation detail with grade |
| POST | `/api/designations` | Create a new designation |
| PUT | `/api/designations/{id}` | Update name or grade |
| PATCH | `/api/designations/{id}/status` | Activate or deactivate |

**Key fields:** `DesignationCode`, `DesignationName`, `Grade`, `IsActive`

---

## 10. DocumentType

**Base route:** `/api/document-types`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/document-types` | List all document types |
| GET | `/api/document-types/{id}` | Document type detail |
| GET | `/api/document-types/mandatory` | Filter: mandatory documents only (IsMandatory = true) |
| GET | `/api/document-types/by-category/{category}` | Filter by category |
| POST | `/api/document-types` | Create a new document type |
| PUT | `/api/document-types/{id}` | Update metadata, category, mandatory flag |
| PATCH | `/api/document-types/{id}/status` | Activate or deactivate |

**Key fields:** `DocumentTypeCode`, `DocumentTypeName`, `Category`, `Description`, `IsMandatory`, `IsActive`

---

## 11. GeoFence

**Base route:** `/api/geofences`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/geofences` | List all geo-fences |
| GET | `/api/geofences/{id}` | Geo-fence detail (coordinates + radius) |
| GET | `/api/geofences/by-office/{officeId}` | All fences for a specific office |
| POST | `/api/geofences` | Define a new geo-fence for an office |
| PUT | `/api/geofences/{id}` | Adjust radius or coordinates |
| PATCH | `/api/geofences/{id}/status` | Activate or deactivate |
| POST | `/api/geofences/check` | Check if a lat/lng coordinate is inside any active fence |

**Key fields:** `GeoFenceCode`, `GeoFenceName`, `Latitude`, `Longitude`, `RadiusMeters`, `OfficeId` (FK → OfficeLocation), `IsActive`

**Special endpoint — `/api/geofences/check`:**
- Request body: `{ "latitude": decimal, "longitude": decimal }`
- Response: `{ "isInside": bool, "matchedFences": [ { "id", "geoFenceCode", "geoFenceName", "officeId" } ] }`
- Used at attendance punch-in to validate employee is within an office boundary

---

## 12. BiometricDevice

**Base route:** `/api/biometric-devices`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/biometric-devices` | List all biometric devices | PaginationFilter filter
| GET | `/api/biometric-devices/{id}` | Device detail — IP address, serial number, last sync time |
| GET | `/api/biometric-devices/by-office/{officeId}` | All devices installed at a specific office |
| POST | `/api/biometric-devices` | Register a new biometric device |
| PUT | `/api/biometric-devices/{id}` | Update IP address, name, or serial number |
| PATCH | `/api/biometric-devices/{id}/sync` | Record sync timestamp (called by device/sync agent after push) |
| PATCH | `/api/biometric-devices/{id}/status` | Activate or deactivate |

**Key fields:** `DeviceCode`, `DeviceName`, `SerialNumber`, `OfficeId` (FK → OfficeLocation), `IpAddress`, `LastSyncAt`, `IsActive`

**Special endpoint — `PATCH /{id}/sync`:**
- Request body: `{ "syncedAt": datetime }` (or server sets current UTC time)
- Updates `LastSyncAt` — called automatically by the device sync agent after pushing attendance logs

---

## Summary: Endpoint Count by Entity

| Entity | GET | POST | PUT | PATCH | Total |
|--------|-----|------|-----|-------|-------|
| TimeZoneMaster | 3 | 1 | 1 | 1 | 6 |
| Country | 2 | 1 | 1 | 1 | 5 |
| Region ⟳ | 6 | 1 | 1 | 2 | 10 |
| LegalEntity | 3 | 1 | 1 | 1 | 6 |
| OfficeLocation | 7 | 1 | 1 | 2 | 11 |
| Department ⟳ | 5 | 1 | 1 | 2 | 9 |
| ScopeType | 2 | 1 | 1 | 1 | 5 |
| Designation | 2 | 1 | 1 | 1 | 5 |
| DocumentType | 4 | 1 | 1 | 1 | 7 |
| GeoFence | 3 | 2 | 1 | 1 | 7 |
| BiometricDevice | 3 | 1 | 1 | 2 | 7 |
| **TOTAL** | **40** | **12** | **11** | **15** | **78** |

---

## Common Patterns & Rules

### Soft Delete
All entities use `IsActive` — never hard delete. Always use `PATCH /{id}/status`.
- Request body: `{ "isActive": true }` or `{ "isActive": false }`

### Self-Referencing Hierarchy (Region & Department)
Both follow the same pattern:
- `GET /tree` — full recursive nested JSON (used for initial tree render)
- `GET /{id}/children` — immediate children only (used for lazy expand)
- `GET /{id}/ancestors` — ordered list from root down to parent (used for breadcrumbs)
- `PATCH /{id}/parent` — re-parent node; body `{ "parentId": <int|null> }`, null = root level

### Audit Fields (all tables)
All tables include: `CreatedAt`, `CreatedBy`, `LastUpdatedAt`, `LastUpdatedBy`
- Set `CreatedBy` / `LastUpdatedBy` from authenticated user context — do not accept from request body.

### Dependency Order for Seeding / Setup
1. TimeZoneMaster
2. Country (needs TimeZoneMaster)
3. Region (needs Country)
4. LegalEntity (needs Country)
5. OfficeLocation (needs LegalEntity + Country + Region + TimeZoneMaster)
6. GeoFence (needs OfficeLocation)
7. BiometricDevice (needs OfficeLocation)
8. Department (standalone, self-referencing)
9. ScopeType (standalone)
10. Designation (standalone)
11. DocumentType (standalone)