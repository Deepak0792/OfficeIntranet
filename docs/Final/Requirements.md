# Enterprise HRMS / Employee Directory — Requirements

> **Platform:** Global HR Platform
> **Database:** Microsoft SQL Server
> **Schema Version:** 1.0
> **Total Modules:** 14
> **Total Tables:** 52

---

## Table of Contents

1. [Overview](#1-overview)
2. [General Requirements](#2-general-requirements)
3. [Module 1 — Master Data](#3-module-1--master-data)
4. [Module 2 — Employee Core](#4-module-2--employee-core)
5. [Module 3 — Team & Skill](#5-module-3--team--skill)
6. [Module 4 — Organization Scope](#6-module-4--organization-scope)
7. [Module 5 — Work Week Policy](#7-module-5--work-week-policy)
8. [Module 6 — Shift Management](#8-module-6--shift-management)
9. [Module 7 — Rotation Shift](#9-module-7--rotation-shift)
10. [Module 8 — Employee Roster](#10-module-8--employee-roster)
11. [Module 9 — Holiday Management](#11-module-9--holiday-management)
12. [Module 10 — Attendance Management](#12-module-10--attendance-management)
13. [Module 11 — Leave Management](#13-module-11--leave-management)
14. [Module 12 — Comp-Off](#14-module-12--comp-off)
15. [Module 13 — Payroll](#15-module-13--payroll)
16. [Module 14 — Biometric & Geo-Fence](#16-module-14--biometric--geo-fence)
17. [Indexes](#17-indexes)
18. [Design Decisions & Constraints](#18-design-decisions--constraints)

---

## 1. Overview

The system is a multi-country, multi-entity Enterprise Human Resource Management System (HRMS) with an integrated Employee Directory. It manages the complete lifecycle of an employee — from onboarding and organizational placement to daily attendance, shift scheduling, leave, and payroll attendance summaries.

The schema is designed to be:

- **Multi-tenant ready** — supports multiple legal entities, countries, and regions under one schema.
- **Policy-driven via scope** — work week policies, shifts, holiday calendars, and rotation schedules are assigned dynamically to any organizational scope level (global down to individual employee), eliminating hardcoded per-entity copies.
- **Temporally aware** — all policy assignments carry `EffectiveFrom` / `EffectiveTo` date ranges so changes can be planned ahead without breaking historical data.
- **Audit-friendly** — all master tables carry `CreatedAt` and `IsActive` soft-delete flags. Key transaction tables carry approver and timestamp fields.

---

## 2. General Requirements

### 2.1 Primary Keys
- All tables use a surrogate `BIGINT IDENTITY(1,1)` primary key named `Id`.

### 2.2 Soft Deletes
- All master and configuration tables include an `IsActive BIT NOT NULL DEFAULT 1` column.
- Records are never physically deleted; they are deactivated by setting `IsActive = 0`.

### 2.3 Audit Timestamps
- All master tables include `CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()`.
- Tables that support updates include `UpdatedAt DATETIME2 NULL`.
- All timestamps are stored in **UTC**.

### 2.4 Unique Codes
- Every master entity carries a human-readable code column (e.g. `DesignationCode`, `CountryCode`, `ShiftCode`) with a `UNIQUE` constraint to prevent duplicates.

### 2.5 Referential Integrity
- All foreign key relationships are enforced via explicit `CONSTRAINT` declarations.
- Self-referencing foreign keys (e.g. `Region.ParentRegionId`, `Department.ParentDepartmentId`) are nullable to support root-level entries.

### 2.6 Deferred Foreign Keys
- Where a table references another table that is defined later in the creation order, the FK is added via a subsequent `ALTER TABLE` statement (e.g. `ShiftSwapRequest → EmployeeShiftRoster`, `MobileAttendanceLog → GeoFence`).

---

## 3. Module 1 — Master Data

Reference data shared across the entire platform. All tables in this module are lookup/configuration tables.

### 3.1 Designation

Stores job titles and grade levels that can be assigned to employees.

| Column | Type | Notes |
|---|---|---|
| Id | BIGINT | PK |
| DesignationCode | NVARCHAR(50) | Unique, required |
| DesignationName | NVARCHAR(200) | Required |
| Grade | NVARCHAR(50) | Optional grade band |
| IsActive | BIT | Soft delete |
| CreatedAt | DATETIME2 | UTC |

### 3.2 TimeZoneMaster

Stores the global time zone registry, supporting both Windows and IANA zone identifiers. Used by Country, OfficeLocation, and Employee for locale-aware time handling.

| Column | Type | Notes |
|---|---|---|
| Id | BIGINT | PK |
| TimeZoneCode | NVARCHAR(100) | Unique |
| TimeZoneName | NVARCHAR(200) | Display name |
| UtcOffset | NVARCHAR(20) | e.g. `+05:30` |
| OffsetMinutes | INT | Numeric offset for calculations |
| SupportsDaylightSaving | BIT | DST flag |
| WindowsTimeZoneId | NVARCHAR(200) | Windows TZ registry ID |
| IanaTimeZoneId | NVARCHAR(200) | IANA/Olson TZ ID |
| CountryCode | NVARCHAR(10) | Optional country association |

### 3.3 Country

Stores ISO country data with optional default currency and time zone.

| Column | Type | Notes |
|---|---|---|
| Id | BIGINT | PK |
| CountryCode | NVARCHAR(10) | ISO 3166-1 alpha-2/3, Unique |
| CountryName | NVARCHAR(200) | Required |
| CurrencyCode | NVARCHAR(10) | ISO 4217 |
| TimeZoneId | BIGINT | FK → TimeZoneMaster |

### 3.4 LegalEntity

Represents a legal/registered company entity operating within a country. A single group may have multiple legal entities (e.g. subsidiaries, branches).

| Column | Type | Notes |
|---|---|---|
| Id | BIGINT | PK |
| EntityCode | NVARCHAR(50) | Unique |
| EntityName | NVARCHAR(300) | Required |
| CountryId | BIGINT | FK → Country |
| TaxIdentificationNumber | NVARCHAR(100) | Optional |
| RegistrationNumber | NVARCHAR(100) | Optional |
| CurrencyCode | NVARCHAR(10) | Operating currency |

### 3.5 Region

Supports a hierarchical (self-referencing) geographic structure within a country: state → district → city, or any custom level via `RegionType`.

| Column | Type | Notes |
|---|---|---|
| Id | BIGINT | PK |
| CountryId | BIGINT | FK → Country |
| RegionName | NVARCHAR(200) | Required |
| RegionType | NVARCHAR(50) | e.g. State, District, City |
| ParentRegionId | BIGINT | FK → Region (self), NULL for root |

### 3.6 OfficeLocation

Stores physical office premises globally with full address, GPS coordinates, and time zone. Each location belongs to a legal entity.

| Column | Type | Notes |
|---|---|---|
| Id | BIGINT | PK |
| LegalEntityId | BIGINT | FK → LegalEntity |
| CountryId | BIGINT | FK → Country |
| RegionId | BIGINT | FK → Region (optional) |
| LocationCode | NVARCHAR(50) | Unique |
| Latitude / Longitude | DECIMAL(10,7) | GPS coordinates |
| TimeZoneId | BIGINT | FK → TimeZoneMaster |
| IsHeadOffice | BIT | Flags the primary office |

### 3.7 Department

Supports nested department hierarchies via a self-referencing `ParentDepartmentId`.

| Column | Type | Notes |
|---|---|---|
| Id | BIGINT | PK |
| DepartmentCode | NVARCHAR(50) | Unique |
| DepartmentName | NVARCHAR(200) | Required |
| ParentDepartmentId | BIGINT | FK → Department (self), NULL for root |
| Description | NVARCHAR(1000) | Optional |

### 3.8 RelationshipType

Lookup table defining the types of reporting relationships between employees (e.g. Direct Manager, Dotted-Line, Mentor).

| Column | Type | Notes |
|---|---|---|
| Id | BIGINT | PK |
| RelationshipName | NVARCHAR(100) | Unique |
| Description | NVARCHAR(500) | Optional |

### 3.9 DocumentType

Defines categories of employee documents (e.g. Passport, Offer Letter, ID Proof). `IsMandatory` flags documents required for onboarding.

| Column | Type | Notes |
|---|---|---|
| Id | BIGINT | PK |
| DocumentTypeCode | NVARCHAR(50) | Unique |
| DocumentTypeName | NVARCHAR(200) | Required |
| IsMandatory | BIT | Onboarding requirement flag |

---

## 4. Module 2 — Employee Core

The central module. All other modules revolve around the `Employee` entity.

### 4.1 Employee

Core identity record for every person in the system.

| Column | Type | Notes |
|---|---|---|
| Id | BIGINT | PK |
| EmployeeCode | NVARCHAR(50) | Unique, business identifier |
| FirstName / LastName | NVARCHAR(100) | Required / Optional |
| DisplayName | NVARCHAR(200) | Computed or overridden display name |
| Email | NVARCHAR(255) | Unique, required |
| MobileNumber | NVARCHAR(30) | Optional |
| DesignationId | BIGINT | FK → Designation |
| PreferredLanguage | NVARCHAR(20) | BCP-47 locale code |
| PreferredTimeZoneId | BIGINT | FK → TimeZoneMaster |
| DateOfJoining | DATE | Official joining date |
| EmploymentType | NVARCHAR(50) | e.g. Full-Time, Contract, Intern |
| AboutMe | NVARCHAR(MAX) | Free-text profile bio |
| ProfilePhotoUrl | NVARCHAR(1000) | CDN/blob URL |

### 4.2 EmployeeLegalEntity

An employee may be simultaneously employed under multiple legal entities (e.g. secondments, inter-company transfers). `IsPrimary` identifies the principal entity.

- One employee may have many legal entity mappings.
- Date range `StartDate` / `EndDate` supports history tracking.

### 4.3 EmployeeDepartment

An employee may belong to multiple departments with split allocation percentages. `IsPrimaryDepartment` flags the main department.

- `AllocationPercentage DECIMAL(5,2)` — sum across active records should equal 100 (enforced at application layer).

### 4.4 EmployeeLocation

Maps employees to their assigned office location(s). `IsPrimaryLocation` identifies their home office.

### 4.5 EmployeeRelationship

Stores the directed reporting graph between employees.

- `ParentEmployeeId` → manager / senior.
- `ChildEmployeeId` → reportee / junior.
- `RelationshipTypeId` determines the relationship nature.
- `DepartmentId` scopes matrix relationships to a specific department.
- `IsPrimaryRelationship` distinguishes primary from secondary (dotted-line) reporting.
- Date range fields support future and historical relationship changes.

### 4.6 EmployeeContact

Stores supplementary contact methods beyond the primary email and mobile stored on the Employee record (e.g. work landline, personal email, Slack, LinkedIn).

### 4.7 EmployeeDocument

Stores employee-uploaded compliance and HR documents with full metadata.

| Column | Type | Notes |
|---|---|---|
| DocumentTypeId | BIGINT | FK → DocumentType |
| FileName | NVARCHAR(500) | Stored file name |
| OriginalFileName | NVARCHAR(500) | User's original file name |
| FileUrl | NVARCHAR(1000) | Blob/CDN storage URL |
| DocumentNumber | NVARCHAR(200) | e.g. Passport number |
| IssuedDate / ExpiryDate | DATE | For time-bound documents |
| IsVerified | BIT | HR verification flag |
| VerifiedByEmployeeId | BIGINT | FK → Employee (HR verifier) |

---

## 5. Module 3 — Team & Skill

### 5.1 Skill

A flat catalog of skills that employees can be tagged with. Skills are categorized (e.g. Technical, Soft Skill, Domain).

### 5.2 Team

Represents cross-functional groups such as squads, pods, project teams, or COEs. Teams exist independently of the department hierarchy.

| Column | Type | Notes |
|---|---|---|
| TeamCode | NVARCHAR(50) | Unique |
| TeamType | NVARCHAR(100) | e.g. Squad, Pod, Tiger Team |

### 5.3 EmployeeTeam

Many-to-many mapping between employees and teams with role and allocation percentage per team.

### 5.4 EmployeeSkill

Maps employees to skills with proficiency metadata.

| Column | Type | Notes |
|---|---|---|
| SkillLevel | NVARCHAR(50) | e.g. Beginner, Intermediate, Expert |
| YearsOfExperience | DECIMAL(5,2) | Decimal years |
| IsPrimarySkill | BIT | Flags the employee's primary skill |
| LastUsedDate | DATE | Recency tracking |

---

## 6. Module 4 — Organization Scope

### 6.1 ScopeType

Defines the hierarchy levels used for dynamic policy assignment across the platform. All assignment tables (shifts, work week policies, holiday calendars, rotation schedules) reference `ScopeType` + `ScopeReferenceId` to target any level of the organization.

| Level | ScopeCode | HierarchyLevel |
|---|---|---|
| 1 | GLOBAL | 1 |
| 2 | COUNTRY | 2 |
| 3 | REGION | 3 |
| 4 | LEGAL_ENTITY | 4 |
| 5 | OFFICE | 5 |
| 6 | DEPARTMENT | 6 |
| 7 | TEAM | 7 |
| 8 | EMPLOYEE | 8 |

Seed data is inserted at schema creation time. The most specific (highest `HierarchyLevel`) assignment for a given employee wins when multiple levels apply.

---

## 7. Module 5 — Work Week Policy

### 7.1 WorkWeekPolicy

Named work week template (e.g. "Standard Mon–Fri", "Middle East Sun–Thu"). `IsDefault` flags the system-wide fallback policy.

### 7.2 WorkWeekPolicyDay

Defines the working/non-working status and standard hours for each day of the week (0 = Sunday … 6 = Saturday) within a policy.

- `IsWorkingDay BIT` — whether this day counts as a working day.
- `StandardWorkingMinutes INT` — expected minutes for the day (used in attendance calculations).
- `IsHalfDay BIT` — marks a scheduled half-working day (e.g. Saturday).
- Unique constraint on `(WorkWeekPolicyId, DayOfWeek)` prevents duplicate day entries per policy.

### 7.3 WorkWeekPolicyAssignment

Assigns a work week policy to a scope level for a date range.

- `PriorityOrder INT` — lower value = higher priority when multiple assignments apply to the same employee.
- Allows future-dated changes by defining a new assignment with a future `EffectiveFrom`.

---

## 8. Module 6 — Shift Management

### 8.1 Shift

Defines a shift timing template reused across assignments and rosters.

| Column | Type | Notes |
|---|---|---|
| StartTime / EndTime | TIME | Core shift window |
| BreakDurationMinutes | INT | Excluded from worked time |
| GraceInMinutes | INT | Late arrival tolerance |
| GraceOutMinutes | INT | Early exit tolerance |
| MinimumWorkingMinutes | INT | Floor for a valid working day |
| MaximumWorkingMinutes | INT | Cap before overtime triggers |
| IsNightShift | BIT | Night shift flag |
| CrossesMidnight | BIT | Shift window spans two calendar days |
| IsFlexible | BIT | Flexible (no fixed in/out time) |
| AllowOvertime | BIT | Whether overtime is permitted |

### 8.2 ShiftAssignment

Assigns a shift to any scope level with `PriorityOrder` conflict resolution. Supports `IsPrimaryShift` for employees on multiple shifts.

### 8.3 ShiftSwapStatus

Lookup table for the shift swap request workflow (e.g. Pending, Approved, Rejected).

### 8.4 ShiftSwapRequest

Captures a request by one employee to swap their rostered shift with another employee.

- `RequesterEmployeeId` / `TargetEmployeeId` — the two parties involved.
- `RequesterRosterId` / `TargetRosterId` — FK to `EmployeeShiftRoster` (deferred, as roster table is defined later).
- Carries approver and approval timestamp fields.

---

## 9. Module 7 — Rotation Shift

### 9.1 RotationShift

Defines a named cyclic rotation pattern. `CycleLengthDays` sets the total days before the cycle repeats.

### 9.2 RotationShiftDetail

Specifies the ordered sequence of shifts (or off-days) within a rotation cycle.

| Column | Type | Notes |
|---|---|---|
| SequenceNo | INT | Ordering within the cycle |
| ShiftId | BIGINT | FK → Shift (NULL if IsOffDay) |
| DurationDays | INT | How many days this phase lasts |
| IsOffDay | BIT | Marks a rest phase in the cycle |

### 9.3 RotationShiftAssignment

Assigns a rotation schedule to a scope level.

- `RotationStartDate DATE` — anchors day-1 of the cycle, enabling correct shift calculation for any date.
- `EffectiveFrom` / `EffectiveTo` — the active window for this rotation assignment.

---

## 10. Module 8 — Employee Roster

### 10.1 EmployeeShiftRoster

The resolved daily schedule for each employee. Generated from shift and rotation assignments.

| Column | Type | Notes |
|---|---|---|
| EmployeeId | BIGINT | FK → Employee |
| RosterDate | DATE | The calendar date |
| ShiftId | BIGINT | FK → Shift (NULL on off/holiday) |
| IsOffDay | BIT | Scheduled rest day |
| IsHoliday | BIT | Public holiday day |
| PlannedStartTime / PlannedEndTime | DATETIME2 | Expected shift window |
| ActualStartTime / ActualEndTime | DATETIME2 | Recorded after attendance |
| IsLocked | BIT | Prevents further edits once finalized |

- Unique constraint on `(EmployeeId, RosterDate)` — one roster entry per employee per day.
- `ShiftSwapRequest` FKs to this table are added via deferred `ALTER TABLE`.

---

## 11. Module 9 — Holiday Management

### 11.1 HolidayCalendar

Named holiday calendars that can be assigned independently to different scope levels (e.g. a country-wide national holiday calendar + an office-specific local calendar).

### 11.2 HolidayType

Categorizes holidays: e.g. National, Regional, Restricted, Optional. `IsOptional` flags holidays employees may choose from a quota.

### 11.3 Holiday

Individual holiday entries under a calendar.

| Column | Type | Notes |
|---|---|---|
| HolidayDate | DATE | The date of the holiday |
| IsHalfDay | BIT | Half-day holiday |
| HalfDaySession | NVARCHAR(20) | First Half / Second Half |
| IsRecurring | BIT | Repeats annually |
| ApplicableYear | INT | NULL for recurring, year for one-time |

### 11.4 HolidayCalendarAssignment

Assigns holiday calendars to scope levels.

- `MergeStrategy NVARCHAR(50)` — when multiple calendars apply (e.g. country + office), defines how they combine: Union, Intersection, or Override.
- `IsPrimary BIT` — marks the dominant calendar when merging.

---

## 12. Module 10 — Attendance Management

### 12.1 AttendanceStatus

Lookup table defining the outcome of a processed attendance record.

| Column | Notes |
|---|---|
| IsPresent / IsAbsent | Mutually exclusive flags |
| IsPaid | Whether the day is paid |
| CountsAsWorkingDay | Affects payroll working day count |
| IsSystemStatus | Distinguishes system-generated vs custom statuses |

### 12.2 AttendanceRecord

One processed record per employee per day — the authoritative attendance outcome.

| Column | Type | Notes |
|---|---|---|
| CheckInTime / CheckOutTime | DATETIME2 | Actual punches |
| LateByMinutes | INT | Minutes after grace-adjusted shift start |
| EarlyExitMinutes | INT | Minutes before grace-adjusted shift end |
| WorkedMinutes | INT | Net minutes worked |
| OvertimeMinutes | INT | Minutes beyond MaximumWorkingMinutes |
| IsManualEntry | BIT | Distinguishes manual HR edits |
| ApprovedBy / ApprovedAt | FK / DATETIME2 | Manual entry approval |

- Unique constraint on `(EmployeeId, AttendanceDate)`.

### 12.3 AttendanceLog

Raw biometric punch log, imported from devices before processing.

- `PunchType NVARCHAR(20)` — e.g. IN, OUT, BREAK.
- `DeviceId NVARCHAR(100)` — source device identifier.
- `IsProcessed BIT` — flags records reconciled into `AttendanceRecord`.

### 12.4 AttendanceRegularizationStatus

Lookup for the regularization workflow (e.g. Pending, Approved, Rejected).

### 12.5 AttendanceRegularization

Employee-submitted request to correct a missing or incorrect attendance record.

- Contains `RequestedCheckIn` / `RequestedCheckOut` proposed values.
- Links to approver and status.

### 12.6 MobileAttendanceLog

GPS-based mobile punch records.

| Column | Type | Notes |
|---|---|---|
| GeoFenceId | BIGINT | FK → GeoFence (deferred) |
| Latitude / Longitude | DECIMAL(18,8) | Employee's location at punch time |
| IsInsideGeoFence | BIT | Computed/set at punch time |
| DeviceInfo | NVARCHAR(500) | Mobile device metadata |

---

## 13. Module 11 — Leave Management

### 13.1 LeaveType

Defines all leave categories available in the system.

| Column | Type | Notes |
|---|---|---|
| LeaveCode | NVARCHAR(100) | Unique |
| IsPaid | BIT | Paid vs unpaid leave |
| MaxDaysPerYear | DECIMAL(10,2) | Annual cap, NULL = unlimited |
| AllowCarryForward | BIT | Whether unused balance rolls over |
| RequiresApproval | BIT | Workflow trigger |
| AllowHalfDay | BIT | Half-day application support |

### 13.2 LeaveStatus

Lookup for leave request workflow states (e.g. Pending, Approved, Rejected, Cancelled, Withdrawn).

### 13.3 LeaveRequest

Employee leave application.

| Column | Type | Notes |
|---|---|---|
| FromDate / ToDate | DATE | Inclusive date range |
| TotalDays | DECIMAL(10,2) | Pre-calculated leave days |
| IsHalfDay | BIT | Half-day application |
| HalfDaySession | NVARCHAR(20) | First Half / Second Half |
| ApprovedBy / ApprovedAt | BIGINT / DATETIME2 | Approver details |

### 13.4 LeaveBalance

Tracks annual leave balance per employee per leave type.

| Column | Type | Notes |
|---|---|---|
| BalanceYear | INT | Calendar/fiscal year |
| OpeningBalance | DECIMAL(10,2) | Balance at year start |
| Allocated | DECIMAL(10,2) | Credits during the year |
| Availed | DECIMAL(10,2) | Leaves taken |
| Encashed | DECIMAL(10,2) | Leaves encashed |
| CarryForward | DECIMAL(10,2) | Rolled over from prior year |
| ClosingBalance | Computed | `OpeningBalance + Allocated + CarryForward - Availed - Encashed` |

- Unique constraint on `(EmployeeId, LeaveTypeId, BalanceYear)`.

---

## 14. Module 12 — Comp-Off

### 14.1 CompOffType

Defines categories of compensatory off with an optional `ExpiryDays` window after which unavailed comp-off lapses.

### 14.2 CompOffBalance

Tracks comp-off days earned and availed per employee.

| Column | Type | Notes |
|---|---|---|
| EarnedDate | DATE | Date the comp-off was earned |
| ExpiryDate | DATE | Lapse date (calculated from CompOffType.ExpiryDays) |
| TotalDays | DECIMAL(10,2) | Days credited |
| AvailedDays | DECIMAL(10,2) | Days consumed |
| RemainingDays | Computed | `TotalDays - AvailedDays` |
| AttendanceRecordId | BIGINT | FK → AttendanceRecord (source overtime day) |

---

## 15. Module 13 — Payroll

### 15.1 PayrollComponent

Master catalog of payroll earning heads (e.g. Basic, HRA, Special Allowance) and deduction heads (e.g. PF, ESI, TDS). `IsEarning` and `IsDeduction` flags are non-exclusive to support components that can appear in both contexts.

### 15.2 PayrollAttendanceSummary

Monthly aggregated attendance figures produced by the attendance processing job and consumed by the payroll engine.

| Column | Type | Notes |
|---|---|---|
| PayrollMonth / PayrollYear | INT | Period identifier |
| TotalWorkingDays | DECIMAL(10,2) | Scheduled working days |
| PresentDays | DECIMAL(10,2) | Days marked present |
| LeaveDays | DECIMAL(10,2) | Paid leave days availed |
| AbsentDays | DECIMAL(10,2) | Unpaid absent days |
| OvertimeMinutes | INT | Total OT for the period |
| ProcessedAt | DATETIME2 | Timestamp of payroll run |

---

## 16. Module 14 — Biometric & Geo-Fence

### 16.1 BiometricDevice

Inventory of physical biometric devices (fingerprint/face scanners) installed at office locations.

| Column | Type | Notes |
|---|---|---|
| DeviceCode | NVARCHAR(100) | Unique device identifier |
| SerialNumber | NVARCHAR(200) | Hardware serial |
| OfficeId | BIGINT | FK → OfficeLocation |
| IpAddress | NVARCHAR(100) | Network address for sync |
| LastSyncAt | DATETIME2 | Last successful data pull timestamp |

### 16.2 BiometricEmployeeMapping

Maps employees to their enrolled identity on each device. `DeviceEmployeeCode` is the ID registered on the physical device (may differ from `EmployeeCode`).

- An employee may be enrolled on multiple devices.
- A device may have many enrolled employees.

### 16.3 GeoFence

Defines a circular geographic boundary for mobile attendance validation.

| Column | Type | Notes |
|---|---|---|
| GeoFenceCode | NVARCHAR(100) | Unique |
| Latitude / Longitude | DECIMAL(18,8) | Center point |
| RadiusMeters | DECIMAL(18,2) | Boundary radius |
| OfficeId | BIGINT | FK → OfficeLocation (optional) |

- `MobileAttendanceLog.GeoFenceId` FK to this table is added via deferred `ALTER TABLE` to respect creation order.

---

## 17. Indexes

All indexes are non-clustered unless noted. They are created after all tables and FKs.

| Index | Table | Columns | Purpose |
|---|---|---|---|
| IX_Employee_Email | Employee | Email | Login / search lookup |
| IX_Employee_DisplayName | Employee | DisplayName | Directory search |
| IX_EmployeeRelationship_Parent | EmployeeRelationship | ParentEmployeeId | Org chart traversal downward |
| IX_EmployeeRelationship_Child | EmployeeRelationship | ChildEmployeeId | Org chart traversal upward |
| IX_EmployeeSkill_Skill | EmployeeSkill | SkillId | Skill-based employee search |
| IX_EmployeeDepartment_Employee | EmployeeDepartment | EmployeeId | Employee department lookup |
| IX_EmployeeTeam_Employee | EmployeeTeam | EmployeeId | Employee team lookup |
| IX_EmployeeLocation_Employee | EmployeeLocation | EmployeeId | Employee location lookup |
| IX_OfficeLocation_Country | OfficeLocation | CountryId | Offices by country |
| IX_OfficeLocation_Region | OfficeLocation | RegionId | Offices by region |
| IX_EmployeeDocument_Employee | EmployeeDocument | EmployeeId | Employee documents list |
| IX_EmployeeDocument_DocumentType | EmployeeDocument | DocumentTypeId | Documents by type |
| IX_EmployeeDocument_ExpiryDate | EmployeeDocument | ExpiryDate | Expiry alerts / compliance |
| IX_TimeZoneMaster_TimeZoneCode | TimeZoneMaster | TimeZoneCode | Code-based lookup |
| IX_TimeZoneMaster_IanaTimeZoneId | TimeZoneMaster | IanaTimeZoneId | IANA-based lookup |
| IX_TimeZoneMaster_WindowsTimeZoneId | TimeZoneMaster | WindowsTimeZoneId | Windows TZ lookup |
| IX_ShiftAssignment_Scope | ShiftAssignment | ScopeTypeId, ScopeReferenceId | Scope-based shift resolution |
| IX_WorkWeekAssignment_Scope | WorkWeekPolicyAssignment | ScopeTypeId, ScopeReferenceId | Scope-based policy resolution |
| IX_RotationAssignment_Scope | RotationShiftAssignment | ScopeTypeId, ScopeReferenceId | Scope-based rotation resolution |
| IX_HolidayAssignment_Scope | HolidayCalendarAssignment | ScopeTypeId, ScopeReferenceId | Scope-based calendar resolution |
| IX_Roster_Employee_Date | EmployeeShiftRoster | EmployeeId, RosterDate | Daily roster lookup |
| IX_Attendance_Employee_Date | AttendanceRecord | EmployeeId, AttendanceDate | Daily attendance lookup |
| IX_AttendanceLog_Employee_Time | AttendanceLog | EmployeeId, PunchTime | Raw punch processing |
| IX_Holiday_Date | Holiday | HolidayDate | Holiday calendar query |
| IX_LeaveRequest_Employee | LeaveRequest | EmployeeId, FromDate, ToDate | Employee leave history |
| IX_LeaveBalance_Employee | LeaveBalance | EmployeeId, LeaveTypeId | Balance lookup |
| IX_CompOffBalance_Employee | CompOffBalance | EmployeeId, CompOffTypeId | Comp-off balance lookup |
| IX_PayrollSummary_Employee | PayrollAttendanceSummary | EmployeeId, PayrollMonth, PayrollYear | Payroll period lookup |
| IX_BiometricEmployeeMapping_Employee | BiometricEmployeeMapping | EmployeeId, BiometricDeviceId | Device enrollment lookup |
| IX_MobileAttendanceLog_Employee | MobileAttendanceLog | EmployeeId, PunchTime | Mobile punch processing |
| IX_ShiftSwapRequest_Requester | ShiftSwapRequest | RequesterEmployeeId, RequestedAt | Swap request history |

---

## 18. Design Decisions & Constraints

### 18.1 Scope-Based Policy Architecture
Rather than maintaining separate policy copies per country or office, all configurable policies (shift, work week, holiday calendar, rotation) are assigned via the `ScopeType` + `ScopeReferenceId` pattern. Conflict resolution uses `PriorityOrder` (lower = higher priority). The most specific scope level wins over broader ones.

### 18.2 No Approval Workflow Engine
The schema intentionally excludes a generic approval workflow engine. Approval state is captured as simple status lookups (`LeaveStatus`, `AttendanceRegularizationStatus`, `ShiftSwapStatus`) with approver ID and timestamp columns. Full workflow orchestration (e.g. multi-level approval chains, delegation, escalation) is expected to be handled at the application layer or integrated via an external BPM engine.

### 18.3 Computed Columns
`LeaveBalance.ClosingBalance` and `CompOffBalance.RemainingDays` are SQL Server persisted computed columns, ensuring consistency without application-layer recalculation.

### 18.4 Payroll Integration Boundary
The schema provides `PayrollAttendanceSummary` as an attendance-to-payroll handoff table. Full payroll calculation (salary structures, tax computation, pay slips) is out of scope for this schema and is expected to reside in a dedicated payroll system consuming this data.

### 18.5 Mobile vs Biometric Attendance
The schema maintains two distinct punch log tables:
- `AttendanceLog` — raw records from physical biometric devices.
- `MobileAttendanceLog` — GPS punches from mobile apps, validated against `GeoFence` zones.

Both feed into `AttendanceRecord` after processing.

### 18.6 Temporal Validity
All assignment tables use `EffectiveFrom` / `EffectiveTo` date ranges. A `NULL` `EffectiveTo` means the assignment is open-ended (currently active). This enables advance-scheduling of policy changes without disrupting current operations.

### 18.7 Multi-Language & Locale
Employee locale preferences (`PreferredLanguage`, `PreferredTimeZoneId`) are stored at the employee level. Display-layer localization (translated names, date formatting) is the responsibility of the application layer.