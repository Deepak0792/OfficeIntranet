# SdxCore.Employee — API Endpoints Reference

---

## Schema Overview

**Schema:** `employee`
**Service:** `SdxCore.Employee.API`
**Port:** `http://localhost:5004` / `https://localhost:7004`
**Gateway Route Prefix:** `/api/v1/employees/**`, `/api/v1/teams/**`, `/api/v1/skills/**`, `/api/v1/biometric-mappings/**`
**Purpose:** Employee master data, organizational assignments, teams, skills, documents, addresses, and biometric device mappings.

**Cross-schema Dependencies:**

| Dependency | Schema | Used By |
|------------|--------|---------|
| `StatusLookup` | `shared` | EmploymentType, ContactType, RelationshipType, AddressType |
| `Designation` | `time` | Employee.DesignationId |
| `TimeZoneMaster` | `time` | Employee.PreferredTimeZoneId |
| `LegalEntity` | `time` | EmployeeLegalEntity.LegalEntityId |
| `Department` | `time` | EmployeeDepartment.DepartmentId |
| `OfficeLocation` | `time` | EmployeeLocation.LocationId |
| `BiometricDevice` | `time` | BiometricEmployeeMapping.BiometricDeviceId |
| `DocumentType` | `time` | EmployeeDocument.DocumentTypeId |
| `WorkflowInstance` | `workflow` | EmployeeDocument.WorkflowInstanceId |

**Gateway Security:** ALL endpoints require `[GatewayOnly]`. Direct external access returns `403 Forbidden`.

**Soft Delete Pattern:** All tables use `IsActive` flag. No hard deletes. Use `PATCH /{id}/status`.

---

## Common Patterns & Rules

### Gateway Security — `[GatewayOnly]`
All controllers are decorated with `[GatewayOnly]`. This filter:
- Validates the `X-Internal-ApiKey` header on every request.
- Calls `IsInternalGatewayCall()` — rejects if key is absent or invalid.
- Returns `403 Forbidden` with a structured `ApiResponse` on failure.
- Logs the caller IP address as a warning on rejection.

```json
{
  "success": false,
  "message": "Access denied. This endpoint is only accessible through the API Gateway.",
  "data": null,
  "errors": ["Direct access is not permitted."]
}
```

### Soft Delete
- Never hard-delete records. Always use `PATCH /{id}/status`.
- Request body: `{ "isActive": true }` or `{ "isActive": false }`

### Audit Fields
All tables include `CreatedAt`, `CreatedBy`, `LastUpdatedAt`, `LastUpdatedBy`.
- `CreatedBy` / `LastUpdatedBy` are injected automatically by `BaseRepository` from `IRequestContext.UserId`.
- The `UserId` is populated from the `X-User-Id` header injected by the Gateway. 
- **Never** accept audit fields from the request body.

### Data Type Mapping (SQL → C#)

| SQL Type | C# Type |
|----------|---------|
| `SMALLINT` | `short` |
| `INT` | `int` |
| `BIT` | `bool` |
| `DECIMAL` | `decimal` |
| `DATETIME2` | `DateTime` |
| `DATE` | `DateOnly` |
| `NVARCHAR` | `string` |

### Standardized Response Envelopes
- `ApiResponse<T>` — single object responses.
- `PagedResponse<T>` — paged list responses.

### Sub-Resource Nesting
All employee sub-resources follow `/api/v1/employees/{employeeId}/{resource}`. Cross-cutting lookups use flat routes (e.g., `by-device`).

---

## 1. Employee (Core Profile)

**Base route:** `/api/v1/employees`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees` | Paged list of employees with filter support |
| GET | `/api/v1/employees/{id}` | Full employee profile via `vw_EmployeeFullProfile` (includes `ProfilePhotoUrl`) |
| GET | `/api/v1/employees/by-code/{employeeCode}` | Lookup by employee code |
| GET | `/api/v1/employees/by-email/{email}` | Lookup by corporate email |
| GET | `/api/v1/employees/search` | Full-text search by name, code, email, mobile |
| GET | `/api/v1/employees/{id}/summary` | Lightweight card — name, designation, department, location |
| POST | `/api/v1/employees` | Onboard a new employee |
| PUT | `/api/v1/employees/{id}` | Update employee core profile |
| PATCH | `/api/v1/employees/{id}/status` | Activate or deactivate an employee |
| PATCH | `/api/v1/employees/{id}/photo` | Update `ProfilePhotoUrl` after upload via File Storage service |
| PATCH | `/api/v1/employees/{id}/about` | Update `AboutMe` / bio |

**Query Filters for `GET /api/v1/employees`:**
- `?departmentId=` — filter by department
- `?locationId=` — filter by office location
- `?legalEntityId=` — filter by legal entity
- `?employmentType=` — `FULL_TIME`, `PART_TIME`, `CONTRACT`, etc.
- `?isActive=` — active status filter
- `?page=&pageSize=` — pagination

**Key Fields:** `EmployeeCode`, `FirstName`, `LastName`, `DisplayName`, `Email`, `MobileNumber`, `DesignationId`, `PreferredLanguage`, `PreferredTimeZoneId`, `DateOfJoining`, `EmploymentType`, `AboutMe`, `ProfilePhotoUrl`, `IsSystemEmployee`, `IsActive`

**File Storage Integration — Profile Photo:**
- `PATCH /{id}/photo` does **not** accept a file binary. The client uploads the file directly to the File Storage service first, receives a stored file path/URL, then passes that reference here.
- Request body: `{ "profilePhotoUrl": "string" }` — the resolved storage path returned by `IFileStorageService.UploadAsync`.
- Storage path follows: `/{env}/{tenant}/employee/{year}/{month}/avatar/{guid}_{originalFileName}`

**Notes:**
- `GET /{id}` uses `vw_EmployeeFullProfile` — single call returns department, designation, location, manager, and legal entity.
- `EmployeeCode` must be unique. It is system-generated or explicitly provided at onboarding.

---

## 2. EmployeeLegalEntity

**Base route:** `/api/v1/employees/{employeeId}/legal-entities`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{employeeId}/legal-entities` | All legal entity assignments |
| GET | `/api/v1/employees/{employeeId}/legal-entities/{id}` | Single assignment detail |
| POST | `/api/v1/employees/{employeeId}/legal-entities` | Assign to a legal entity |
| PUT | `/api/v1/employees/{employeeId}/legal-entities/{id}` | Update dates or primary flag |
| PATCH | `/api/v1/employees/{employeeId}/legal-entities/{id}/status` | Activate or deactivate |
| PATCH | `/api/v1/employees/{employeeId}/legal-entities/{id}/set-primary` | Mark as primary (auto-unsets previous) |

**Key Fields:** `EmployeeId`, `LegalEntityId`, `IsPrimary`, `StartDate`, `EndDate`, `IsActive`

**Business Rules:**
- Only one active assignment may have `IsPrimary = true` at any time.
- `set-primary` unsets the existing primary before promoting the new one.

---

## 3. EmployeeDepartment

**Base route:** `/api/v1/employees/{employeeId}/departments`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{employeeId}/departments` | All department assignments |
| GET | `/api/v1/employees/{employeeId}/departments/{id}` | Single assignment detail |
| POST | `/api/v1/employees/{employeeId}/departments` | Assign to a department |
| PUT | `/api/v1/employees/{employeeId}/departments/{id}` | Update allocation, dates, or primary flag |
| PATCH | `/api/v1/employees/{employeeId}/departments/{id}/status` | Activate or deactivate |
| PATCH | `/api/v1/employees/{employeeId}/departments/{id}/set-primary` | Mark as primary department |

**Key Fields:** `EmployeeId`, `DepartmentId`, `IsPrimaryDepartment`, `AllocationPercentage`, `StartDate`, `EndDate`, `IsActive`

**Business Rules:**
- `AllocationPercentage` across active departments should sum to 100 (validated at application layer).
- Only one `IsPrimaryDepartment = true` per employee at any time.
- `set-primary` unsets the existing primary before promoting the new one.

---

## 4. EmployeeLocation

**Base route:** `/api/v1/employees/{employeeId}/locations`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{employeeId}/locations` | All location assignments |
| GET | `/api/v1/employees/{employeeId}/locations/{id}` | Single assignment detail |
| POST | `/api/v1/employees/{employeeId}/locations` | Assign to an office location |
| PUT | `/api/v1/employees/{employeeId}/locations/{id}` | Update dates or primary flag |
| PATCH | `/api/v1/employees/{employeeId}/locations/{id}/status` | Activate or deactivate |
| PATCH | `/api/v1/employees/{employeeId}/locations/{id}/set-primary` | Mark as primary location |

**Key Fields:** `EmployeeId`, `LocationId`, `IsPrimaryLocation`, `StartDate`, `EndDate`, `IsActive`

**Business Rules:**
- Only one `IsPrimaryLocation = true` per employee at any time.
- `set-primary` unsets the existing primary before promoting the new one.
---

## 5. EmployeeRelationship

**Base route:** `/api/v1/employees/{employeeId}/relationships`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{employeeId}/relationships` | All relationships (as child employee) |
| GET | `/api/v1/employees/{employeeId}/relationships/{id}` | Relationship detail |
| GET | `/api/v1/employees/{employeeId}/direct-reports` | Employees reporting to this employee |
| GET | `/api/v1/employees/{employeeId}/manager` | Primary direct manager |
| POST | `/api/v1/employees/{employeeId}/relationships` | Create a reporting relationship |
| PUT | `/api/v1/employees/{employeeId}/relationships/{id}` | Update type, department, or dates |
| PATCH | `/api/v1/employees/{employeeId}/relationships/{id}/status` | Activate or deactivate |
| PATCH | `/api/v1/employees/{employeeId}/relationships/{id}/set-primary` | Mark as primary relationship |

**Key Fields:** `ParentEmployeeId`, `ChildEmployeeId`, `RelationshipType`, `DepartmentId`, `IsPrimaryRelationship`, `EffectiveFrom`, `EffectiveTo`, `IsActive`

**`RelationshipType` seed values (`RELATIONSHIP_TYPE` group):**

| StatusCode | Label | DisplayOrder |
|------------|-------|-------------|
| `DIRECT_MANAGER` | Primary reporting manager | 1 |
| `DOTTED_LINE_MANAGER` | Secondary reporting manager | 2 |
| `HEAD_DEPARTMENT` | Head of department oversight | 3 |
| `SKIP_LEVEL_MANAGER` | Skip-level manager | 4 |

**Notes:**
- `GET /{employeeId}/manager` — returns `ParentEmployeeId` where `RelationshipType = DIRECT_MANAGER` AND `IsPrimaryRelationship = true`.
- `GET /{employeeId}/direct-reports` — queries where `ParentEmployeeId = {employeeId}` AND `RelationshipType = DIRECT_MANAGER` AND `IsActive = true`.

**Business Rules:**
- Only one `IsPrimaryRelationship = true` per `RelationshipType` for an employee at any time.
- `set-primary` unsets the existing primary before promoting the new one.
---

## 6. EmployeeContact

**Base route:** `/api/v1/employees/{employeeId}/contacts`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{employeeId}/contacts` | All contact entries |
| GET | `/api/v1/employees/{employeeId}/contacts/{id}` | Single contact detail |
| POST | `/api/v1/employees/{employeeId}/contacts` | Add a contact entry |
| PUT | `/api/v1/employees/{employeeId}/contacts/{id}` | Update contact value or type |
| PATCH | `/api/v1/employees/{employeeId}/contacts/{id}/status` | Activate or deactivate |
| PATCH | `/api/v1/employees/{employeeId}/contacts/{id}/set-primary` | Mark as primary for that contact type |

**Key Fields:** `EmployeeId`, `ContactType`, `ContactValue`, `IsPrimary`, `IsActive`

**`ContactType` seed values (`CONTACT_TYPE` group):** `PERSONAL_EMAIL`, `PERSONAL_MOBILE`, `EMERGENCY_CONTACT`, `LINKEDIN`, `ALTERNATE_PHONE`

**Business Rules:**
- Only one `IsPrimaryContact = true` per `ContactType` for an employee at any time.
- `set-primary` unsets the existing primary before promoting the new one.

---

## 7. EmployeeDocument

**Base route:** `/api/v1/employees/{employeeId}/documents`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{employeeId}/documents` | All documents for an employee |
| GET | `/api/v1/employees/{employeeId}/documents/{id}` | Document detail with verification status |
| GET | `/api/v1/employees/{employeeId}/documents/expiring` | Documents expiring within N days (`?days=30`) |
| POST | `/api/v1/employees/{employeeId}/documents` | Register a document after upload |
| PUT | `/api/v1/employees/{employeeId}/documents/{id}` | Update metadata (number, expiry, remarks) |
| PATCH | `/api/v1/employees/{employeeId}/documents/{id}/status` | Activate or deactivate |
| PATCH | `/api/v1/employees/{employeeId}/documents/{id}/verify` | Mark as verified |

**Key Fields:** `EmployeeId`, `DocumentTypeId`, `FileName`, `OriginalFileName`, `FileExtension`, `MimeType`, `FileSizeInBytes`, `FileUrl`, `DocumentNumber`, `IssuedDate`, `ExpiryDate`, `Remarks`, `IsVerified`, `VerifiedByEmployeeId`, `VerifiedAt`, `WorkflowInstanceId`, `IsActive`

**File Storage Integration — Employee Documents:**
- `POST /documents` does **not** accept a file binary directly. Client uploads the file via the File Storage service first, then submits document metadata including the resolved `FileUrl`.
- `FileUrl` is the storage path returned by `IFileStorageService.UploadAsync`.
- Storage path follows: `/{env}/{tenant}/employee/{year}/{month}/documents/{guid}_{originalFileName}`
- `PATCH /{id}/verify` body: `{ "verifiedByEmployeeId": int }` — server sets `VerifiedAt = GETUTCDATE()`.
- `WorkflowInstanceId` is nullable — set when document approval flows through the workflow engine.

---

## 8. Skill (Master Data)

**Base route:** `/api/v1/skills`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/skills` | List all active skills |
| GET | `/api/v1/skills/{id}` | Skill detail |
| GET | `/api/v1/skills/by-category/{category}` | Filter by skill category |
| POST | `/api/v1/skills` | Create a new skill |
| PUT | `/api/v1/skills/{id}` | Update name, category, description |
| PATCH | `/api/v1/skills/{id}/status` | Activate or deactivate |

**Key Fields:** `SkillName`, `SkillCategory`, `Description`, `IsActive`

---

## 9. EmployeeSkill

**Base route:** `/api/v1/employees/{employeeId}/skills`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{employeeId}/skills` | All skills of an employee |
| GET | `/api/v1/employees/{employeeId}/skills/{id}` | Skill assignment detail |
| POST | `/api/v1/employees/{employeeId}/skills` | Add a skill |
| PUT | `/api/v1/employees/{employeeId}/skills/{id}` | Update level, experience, last used date |
| PATCH | `/api/v1/employees/{employeeId}/skills/{id}/status` | Activate or deactivate |
| PATCH | `/api/v1/employees/{employeeId}/skills/{id}/set-primary` | Mark as primary skill |

**Key Fields:** `EmployeeId`, `SkillId`, `SkillLevel`, `YearsOfExperience`, `IsPrimarySkill`, `LastUsedDate`, `IsActive`

---

## 10. Team (Master Data)

**Base route:** `/api/v1/teams`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/teams` | List all active teams |
| GET | `/api/v1/teams/{id}` | Team detail |
| GET | `/api/v1/teams/{id}/members` | All active members of a team |
| POST | `/api/v1/teams` | Create a new team |
| PUT | `/api/v1/teams/{id}` | Update name, type, description |
| PATCH | `/api/v1/teams/{id}/status` | Activate or deactivate |

**Key Fields:** `TeamCode`, `TeamName`, `TeamType`, `Description`, `IsActive`

---

## 11. EmployeeTeam

**Base route:** `/api/v1/employees/{employeeId}/teams`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{employeeId}/teams` | All team memberships |
| GET | `/api/v1/employees/{employeeId}/teams/{id}` | Single membership detail |
| POST | `/api/v1/employees/{employeeId}/teams` | Add to a team |
| PUT | `/api/v1/employees/{employeeId}/teams/{id}` | Update role, allocation, or dates |
| PATCH | `/api/v1/employees/{employeeId}/teams/{id}/status` | Activate or deactivate |

**Key Fields:** `EmployeeId`, `TeamId`, `RoleInTeam`, `AllocationPercentage`, `StartDate`, `EndDate`, `IsActive`

---

## 12. BiometricEmployeeMapping

**Base route:** `/api/v1/employees/{employeeId}/biometric-mappings`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{employeeId}/biometric-mappings` | All device mappings for an employee |
| GET | `/api/v1/employees/{employeeId}/biometric-mappings/{id}` | Single mapping detail |
| GET | `/api/v1/biometric-mappings/by-device/{deviceId}` | All employees mapped to a device |
| POST | `/api/v1/employees/{employeeId}/biometric-mappings` | Map employee to a biometric device |
| PUT | `/api/v1/employees/{employeeId}/biometric-mappings/{id}` | Update device employee code |
| PATCH | `/api/v1/employees/{employeeId}/biometric-mappings/{id}/status` | Activate or deactivate |

**Key Fields:** `EmployeeId`, `BiometricDeviceId`, `DeviceEmployeeCode`, `IsActive`

**Notes:**
- `DeviceEmployeeCode` is the ID registered on the physical device — may differ from `EmployeeCode`.
- `BiometricDeviceId` is `INT` → `int` (not `short`) per ecosystem rule; `time.BiometricDevice.Id` is `INT`.

---

## 13. EmployeeAddress

**Base route:** `/api/v1/employees/{employeeId}/addresses`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{employeeId}/addresses` | All addresses for an employee |
| GET | `/api/v1/employees/{employeeId}/addresses/{id}` | Single address detail |
| GET | `/api/v1/employees/{employeeId}/addresses/primary` | Fetch the active primary address |
| GET | `/api/v1/employees/{employeeId}/addresses/by-type/{addressType}` | Filter by type (PERMANENT, CURRENT, etc.) |
| POST | `/api/v1/employees/{employeeId}/addresses` | Add a new address |
| PUT | `/api/v1/employees/{employeeId}/addresses/{id}` | Update address fields |
| PATCH | `/api/v1/employees/{employeeId}/addresses/{id}/status` | Activate or deactivate |
| PATCH | `/api/v1/employees/{employeeId}/addresses/{id}/set-primary` | Mark as primary (auto-unsets previous) |
| PATCH | `/api/v1/employees/{employeeId}/addresses/{id}/verify` | Mark address as verified |

**Key Fields:** `EmployeeId`, `AddressType`, `AddressLine1`, `AddressLine2`, `Landmark`, `City`, `StateProvince`, `PostalCode`, `CountryId`, `RegionId`, `IsPrimary`, `IsVerified`, `VerifiedByEmployeeId`, `VerifiedAt`, `IsActive`

**`AddressType` seed values (`ADDRESS_TYPE` group):**

| StatusCode | Label | DisplayOrder |
|------------|-------|-------------|
| `PERMANENT` | Permanent Address | 1 |
| `CURRENT` | Current Address | 2 |
| `MAILING` | Mailing Address | 3 |
| `EMERGENCY` | Emergency Address | 4 |
| `WORK` | Work Address | 5 |

**Business Rules:**

| Rule | Detail |
|------|--------|
| **Single primary** | Enforced by partial unique index `UIX_EmployeeAddress_PrimaryPerEmployee`. `set-primary` calls `UnsetPrimaryAsync` before promoting. |
| **No hard delete** | Use `PATCH /{id}/status` with `{ "isActive": false }`. |
| **Verification** | `PATCH /{id}/verify` sets `IsVerified = true`, `VerifiedAt = UTC now`, `VerifiedByEmployeeId` from request body. Cannot be undone via API. |
| **AddressType validation** | Must exist in `shared.StatusLookup` where `StatusGroup = 'ADDRESS_TYPE'`. Validated at application layer. |
| **Audit** | `CreatedBy` and `LastUpdatedBy` injected by `BaseRepository` from `IRequestContext`. Never in request body. |

---

## 14. Employee Full Profile View

**Base route:** `/api/v1/employees/{id}/profile`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/employees/{id}/profile` | Aggregated profile from `vw_EmployeeFullProfile` |

**Returns:** `EmployeeId`, `EmployeeCode`, `FirstName`, `LastName`, `DisplayName`, `Email`, `MobileNumber`, `DateOfJoining`, `EmploymentType`, `IsActive`, `DepartmentId`, `DepartmentName`, `DesignationId`, `DesignationName`, `Grade`, `LocationId`, `LocationName`, `City`, `PrimaryLegalEntityId`, `PrimaryLegalEntityName`, `ManagerId`, `ManagerName`

---

## Endpoint Count Summary

| Resource | GET | POST | PUT | PATCH | Total |
|----------|-----|------|-----|-------|-------|
| Employee | 6 | 1 | 1 | 3 | 11 |
| EmployeeLegalEntity | 2 | 1 | 1 | 2 | 6 |
| EmployeeDepartment | 2 | 1 | 1 | 2 | 6 |
| EmployeeLocation | 2 | 1 | 1 | 2 | 6 |
| EmployeeRelationship | 4 | 1 | 1 | 2 | 8 |
| EmployeeContact | 2 | 1 | 1 | 2 | 6 |
| EmployeeDocument | 3 | 1 | 1 | 2 | 7 |
| Skill | 3 | 1 | 1 | 1 | 6 |
| EmployeeSkill | 2 | 1 | 1 | 2 | 6 |
| Team | 3 | 1 | 1 | 1 | 6 |
| EmployeeTeam | 2 | 1 | 1 | 1 | 5 |
| BiometricEmployeeMapping | 3 | 1 | 1 | 1 | 6 |
| EmployeeAddress | 4 | 1 | 1 | 3 | 9 |
| EmployeeFullProfile (View) | 1 | — | — | — | 1 |
| **TOTAL** | **39** | **13** | **13** | **24** | **89** |

---

## Dependency Seeding Order

1. `employee.Skill` — standalone master
2. `employee.Team` — standalone master
3. `employee.Employee` — needs `time.Designation`, `time.TimeZoneMaster`
4. `employee.EmployeeLegalEntity` — needs Employee + `time.LegalEntity`
5. `employee.EmployeeDepartment` — needs Employee + `time.Department`
6. `employee.EmployeeLocation` — needs Employee + `time.OfficeLocation`
7. `employee.EmployeeRelationship` — needs Employee × 2
8. `employee.EmployeeContact` — needs Employee + `shared.StatusLookup`
9. `employee.EmployeeDocument` — needs Employee + `time.DocumentType`
10. `employee.EmployeeSkill` — needs Employee + Skill
11. `employee.EmployeeTeam` — needs Employee + Team
12. `employee.BiometricEmployeeMapping` — needs Employee + `time.BiometricDevice`
13. `employee.EmployeeAddress` — needs Employee + `shared.StatusLookup`