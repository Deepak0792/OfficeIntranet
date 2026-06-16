# SdxCore.Attendance Microservice — AI Generation Prompt

## Purpose

This document is a **complete, self-contained specification** for generating the `SdxCore.Attendance` microservice using .NET 9 Clean Architecture. It covers Leave Management, Shift Scheduling, Attendance Tracking, Roster Management, Holiday Calendars, Comp-Off, and Shift Swap — with full Workflow integration via RabbitMQ.

**Do not ask for clarification. Generate everything described. One class per file.**

---

## Platform Architecture Context

```
SdxCore.Attendance/
├── Domain/
│   ├── Entities/                    One file per entity
│   ├── Abstractions/Repositories/   Repository interfaces
│   └── Exceptions/                  Domain-specific exceptions
├── Application/
│   ├── DTOs/
│   │   ├── {EntityName}/
│   │   │   ├── Request/             CreateXRequest.cs, UpdateXRequest.cs
│   │   │   └── Response/            XResponse.cs
│   ├── Abstractions/
│   │   ├── Services/                Application service interfaces
│   │   └── Clients/                 HTTP client interfaces
│   ├── Services/                    Application service implementations
│   ├── Consumers/                   MassTransit consumers
│   ├── BackgroundServices/          Scheduled jobs
│   ├── Extensions/                  ServiceCollectionExtensions
│   └── Validators/                  FluentValidation validators (one per request DTO)
├── Persistence/
│   ├── Data/                        AttendanceDbContext
│   ├── Repositories/                EF Core repository implementations
│   └── Interceptors/                OutboxSaveChangesInterceptor, AttendanceWorkflowOutboxInterceptor
└── API/
    ├── Controllers/                 One controller per aggregate
    └── Middleware/                  AttendanceExceptionMiddleware
```

---

## Shared NuGet Packages (already built — just reference)

| Package | Purpose |
|---|---|
| `SdxCore.SharedKernel` | `BaseEntity<T>`, `BaseAuditEntity<T>`, `IPublishableEntity`, `OutboxMessage`, `IOutboxRepository`, `OutboxRepository<TDbContext>`, `SdxDbContext`, `OutboxSaveChangesInterceptor`, `IRequestContext` |
| `SdxCore.Messaging` | `IEventPublisher`, `AddSdxMessaging()`, `OutboxProcessorBackgroundService` |
| `SdxCore.Caching` | `ICacheService`, `ICacheKeyBuilder`, `CacheOptions` |
| `SdxCore.Common` | `PagedResponse<T>`, `ApiResponse<T>`, `PaginationFilter` |
| `SdxCore.Common.Helpers` | `PropertyMapper` — use for all DTO ↔ Entity mapping |
| `SdxCore.Common.Security` | `[GatewayOnly]`, `SdxControllerBase` |

### Key Shared Patterns

**BaseAuditEntity<TKey>:**
```csharp
public abstract class BaseAuditEntity<TKey> : BaseEntity<TKey>, IAuditableEntity
{
    public DateTime  CreatedAt     { get; set; }
    public Guid?     CreatedBy     { get; set; }
    public DateTime  LastUpdatedAt { get; set; }
    public Guid?     LastUpdatedBy { get; set; }
}
```

**IPublishableEntity** — mark entities whose Add/Update/Delete auto-writes `EntityChangedEvent` to outbox via `OutboxSaveChangesInterceptor`.

**SdxDbContext** — wraps every `SaveChangesAsync` in a transaction via `CreateExecutionStrategy`. If transaction already open, saves normally.

**OutboxSaveChangesInterceptor** — singleton, registered globally. Fires for any `IPublishableEntity` change. Writes `EntityChangedEvent` to `OutboxMessages`. Does NOT call `SaveChangesAsync`.

**AttendanceWorkflowOutboxInterceptor** — custom interceptor. Watches newly ADDED workflow-triggering entities (`LeaveRequest`, `AttendanceRegularization`, `ShiftSwapRequest`, `CompOffBalance` with `RequiresApproval=true`). Writes domain-specific submitted events. Does NOT call `SaveChangesAsync`. Caller owns the commit.

**OutboxProcessorBackgroundService** — in `SdxCore.Messaging`. Polls `OutboxMessages`, resolves `EventType` via `Type.GetType()`, deserializes, publishes to RabbitMQ. Auto-registered by `AddSdxMessaging()`.

**SdxControllerBase** — provides `OkOrNotFound`, `ValidationError`, `ValidateAsync<T>` (resolves `IValidator<T>` from DI). All controllers inherit this.

**GatewayOnly** — all endpoints require `X-Internal-ApiKey`. Gateway injects `X-User-Id`, `X-User-Name`, `X-Roles`.

**PropertyMapper** — use `PropertyMapper.Map<TSource, TDest>(source)` for all DTO↔Entity mapping. Never write manual mapping code.

---

## Namespaces

| Layer | Namespace Pattern |
|---|---|
| Domain Entities | `SdxCore.Attendance.Domain.Entities` |
| Domain Repository Interfaces | `SdxCore.Attendance.Domain.Abstractions.Repositories` |
| Application Service Interfaces | `SdxCore.Attendance.Application.Abstractions.Services` |
| Application HTTP Client Interfaces | `SdxCore.Attendance.Application.Abstractions.Clients` |
| Application Service Implementations | `SdxCore.Attendance.Application.Services` |
| DTOs — Requests | `SdxCore.Attendance.Application.DTOs.{EntityName}.Request` |
| DTOs — Responses | `SdxCore.Attendance.Application.DTOs.{EntityName}.Response` |
| Consumers | `SdxCore.Attendance.Application.Consumers` |
| Validators | `SdxCore.Attendance.Application.Validators.{EntityName}` |
| Extensions | `SdxCore.Attendance.Application.Extensions` |
| DbContext | `SdxCore.Attendance.Persistence.Data` |
| Repositories | `SdxCore.Attendance.Persistence.Repositories` |
| Interceptors | `SdxCore.Attendance.Persistence.Interceptors` |
| Controllers | `SdxCore.Attendance.API.Controllers` |
| Middleware | `SdxCore.Attendance.API.Middleware` |

---

## DTO File Structure

```
Application/DTOs/
├── Leave/
│   ├── Request/
│   │   ├── CreateLeaveRequestRequest.cs
│   │   ├── UpdateLeaveRequestRequest.cs
│   │   └── LeaveBalanceQueryRequest.cs
│   └── Response/
│       ├── LeaveRequestResponse.cs
│       └── LeaveBalanceResponse.cs
├── LeaveType/
│   ├── Request/
│   │   ├── CreateLeaveTypeRequest.cs
│   │   └── UpdateLeaveTypeRequest.cs
│   └── Response/
│       └── LeaveTypeResponse.cs
├── Shift/
│   ├── Request/
│   │   ├── CreateShiftRequest.cs
│   │   └── UpdateShiftRequest.cs
│   └── Response/
│       └── ShiftResponse.cs
├── Roster/
│   ├── Request/
│   │   ├── GenerateRosterRequest.cs
│   │   ├── UpdateRosterRequest.cs
│   │   ├── RosterUploadRequest.cs
│   │   └── RosterRow.cs
│   └── Response/
│       ├── RosterResponse.cs
│       ├── RosterGenerationResult.cs
│       └── RosterUploadResult.cs
├── Attendance/
│   ├── Request/
│   │   ├── CheckInRequest.cs
│   │   ├── CheckOutRequest.cs
│   │   └── CreateRegularizationRequest.cs
│   └── Response/
│       ├── AttendanceRecordResponse.cs
│       └── RegularizationResponse.cs
├── Holiday/
│   ├── Request/
│   │   ├── CreateHolidayRequest.cs
│   │   ├── UpdateHolidayRequest.cs
│   │   └── CreateHolidayCalendarRequest.cs
│   └── Response/
│       ├── HolidayResponse.cs
│       └── HolidayCalendarResponse.cs
├── ShiftSwap/
│   ├── Request/
│   │   └── CreateShiftSwapRequest.cs
│   └── Response/
│       └── ShiftSwapResponse.cs
├── CompOff/
│   ├── Request/
│   │   ├── EarnCompOffRequest.cs
│   │   └── RedeemCompOffRequest.cs
│   └── Response/
│       └── CompOffBalanceResponse.cs
└── RotationShift/
    ├── Request/
    │   ├── CreateRotationShiftRequest.cs
    │   └── AssignRotationShiftRequest.cs
    └── Response/
        └── RotationShiftResponse.cs
```

---

## Validator File Structure

```
Application/Validators/
├── Leave/
│   ├── CreateLeaveRequestRequestValidator.cs
│   └── UpdateLeaveRequestRequestValidator.cs
├── Shift/
│   ├── CreateShiftRequestValidator.cs
│   └── UpdateShiftRequestValidator.cs
├── Roster/
│   ├── GenerateRosterRequestValidator.cs
│   └── RosterUploadRequestValidator.cs
├── Attendance/
│   ├── CheckInRequestValidator.cs
│   ├── CheckOutRequestValidator.cs
│   └── CreateRegularizationRequestValidator.cs
├── Holiday/
│   ├── CreateHolidayRequestValidator.cs
│   └── CreateHolidayCalendarRequestValidator.cs
├── ShiftSwap/
│   └── CreateShiftSwapRequestValidator.cs
└── CompOff/
    ├── EarnCompOffRequestValidator.cs
    └── RedeemCompOffRequestValidator.cs
```

**Validator example following Employee service pattern:**
```csharp
// Application/Validators/Leave/CreateLeaveRequestRequestValidator.cs
using FluentValidation;
using SdxCore.Attendance.Application.DTOs.Leave.Request;

namespace SdxCore.Attendance.Application.Validators.Leave;

public sealed class CreateLeaveRequestRequestValidator : AbstractValidator<CreateLeaveRequestRequest>
{
    public CreateLeaveRequestRequestValidator()
    {
        RuleFor(x => x.LeaveTypeId).NotEmpty();
        RuleFor(x => x.FromDate).NotEmpty();
        RuleFor(x => x.ToDate).NotEmpty()
            .GreaterThanOrEqualTo(x => x.FromDate)
            .WithMessage("ToDate must be >= FromDate.");
        RuleFor(x => x.Reason).MaximumLength(1000);
        RuleFor(x => x.HalfDaySession)
            .MaximumLength(20)
            .When(x => x.IsHalfDay);
    }
}
```

---

## Status Code Constants

**Put files at: `src/SdxCore.Common/Enum/Attendance/`**

```csharp
// src/SdxCore.Common/Enum/Attendance/LeaveStatus.cs
namespace SdxCore.Common.Enum.Attendance;
public static class LeaveStatus
{
    public const string Pending    = "PENDING";
    public const string InProgress = "IN_PROGRESS";
    public const string Approved   = "APPROVED";
    public const string Rejected   = "REJECTED";
    public const string Cancelled  = "CANCELLED";
    public const string Withdrawn  = "WITHDRAWN";
}

// src/SdxCore.Common/Enum/Attendance/RegularizationStatus.cs
namespace SdxCore.Common.Enum.Attendance;
public static class RegularizationStatus
{
    public const string Pending    = "PENDING";
    public const string InProgress = "IN_PROGRESS";
    public const string Approved   = "APPROVED";
    public const string Rejected   = "REJECTED";
    public const string Withdrawn  = "WITHDRAWN";
}

// src/SdxCore.Common/Enum/Attendance/ShiftSwapStatus.cs
namespace SdxCore.Common.Enum.Attendance;
public static class ShiftSwapStatus
{
    public const string Pending    = "PENDING";
    public const string InProgress = "IN_PROGRESS";
    public const string Approved   = "APPROVED";
    public const string Rejected   = "REJECTED";
    public const string Cancelled  = "CANCELLED";
}

// src/SdxCore.Common/Enum/Attendance/AttendanceStatusCodes.cs
namespace SdxCore.Common.Enum.Attendance;
public static class AttendanceStatusCodes
{
    public const string Present      = "PRESENT";
    public const string Absent       = "ABSENT";
    public const string OnLeave      = "ON_LEAVE";
    public const string WorkFromHome = "WORK_FROM_HOME";
    public const string HalfDay      = "HALF_DAY";
    public const string Late         = "LATE";
    public const string Holiday      = "HOLIDAY";
    public const string Weekend      = "WEEKEND";
    public const string OnDuty       = "ON_DUTY";
    public const string CompOff      = "COMP_OFF";
    public const string Regularized  = "REGULARIZED";
}

// src/SdxCore.Common/Enum/Attendance/WorkflowModuleCodes.cs
namespace SdxCore.Common.Enum.Attendance;
public static class WorkflowModuleCodes
{
    public const string Leave                    = "LEAVE_REQUEST";
    public const string AttendanceRegularization = "ATTENDANCE_REGULARIZATION";
    public const string ShiftSwap                = "SHIFT_SWAP_REQUEST";
    public const string CompOff                  = "COMP_OFF_REDEMPTION";
}

// src/SdxCore.Common/Enum/Attendance/RosterGenerationType.cs
namespace SdxCore.Common.Enum.Attendance;
public static class RosterGenerationType
{
    public const string Monthly = "MONTHLY";
    public const string Weekly  = "WEEKLY";
    public const string Adhoc   = "ADHOC";
}

// src/SdxCore.Common/Enum/Attendance/ScopeHierarchyLevel.cs
namespace SdxCore.Common.Enum.Attendance;
public static class ScopeHierarchyLevel
{
    public const int Global      = 1;
    public const int Country     = 2;
    public const int LegalEntity = 3;
    public const int Office      = 4;
    public const int Department  = 5;
    public const int Team        = 6;
    public const int Employee    = 7;
}
```

---

## Database Schema

- Schema: `attendance`
- PKs: `UNIQUEIDENTIFIER` → `Guid`
- Audit columns on every table: `CreatedAt`, `CreatedBy`, `LastUpdatedAt`, `LastUpdatedBy`
- Status FK pattern: computed persisted `*Group` column → FK to `shared.StatusLookup(StatusCode, StatusGroup)`
- Cross-schema: `employee.Employee`, `time.ScopeType`, `time.GeoFence`, `workflow.WorkflowInstance`

### Tables

| Table | Description |
|---|---|
| `AttendanceStatus` | Lookup: PRESENT, ABSENT, ON_LEAVE, HOLIDAY, WEEKEND, LATE, HALF_DAY, REGULARIZED, WORK_FROM_HOME, ON_DUTY, COMP_OFF |
| `Shift` | Shift master with timings, grace, night-shift, cross-midnight, overtime flags |
| `ShiftAssignment` | Assigns fixed shifts to scopes with effective dates and priority |
| `RotationShift` | Rotation cycle master with CycleLengthDays |
| `RotationShiftDetail` | Ordered shift segments within cycle (SequenceNo, DurationDays, IsOffDay) |
| `RotationShiftAssignment` | Assigns rotation to scopes with RotationStartDate + RotationOffsetDays |
| `EmployeeShiftRoster` | One row per employee per date. `IsLocked=true` protects from overwrite |
| `EmployeeRosterGenerationTracker` | Tracks what period was generated, how, and whether locked |
| `WorkSession` | Raw check-in/check-out sessions per employee per day |
| `AttendanceRecord` | Processed daily record: status, worked minutes, overtime, leave flags |
| `AttendanceLog` | Raw biometric punches from devices |
| `MobileAttendanceLog` | GPS mobile punches with geofence validation |
| `LeaveType` | Leave master: CL, SL, EL, ML, PL, COMPOFF, LWP, BL — with `WorkflowCode` column |
| `LeaveRequest` | Leave requests with workflow instance link |
| `LeaveBalance` | Per-employee, per-type, per-year. `ClosingBalance` is computed column |
| `CompOffType` | Comp-off types with expiry rules |
| `CompOffBalance` | Earned comp-off per employee. `RemainingDays` is computed column |
| `AttendanceRegularization` | Request to correct missed attendance with workflow |
| `HolidayCalendar` | Calendar master (National, State, Optional) |
| `HolidayType` | NATIONAL, STATE, RELIGIOUS, OPTIONAL |
| `Holiday` | Individual holiday entries per calendar. `IsRecurring` skips year match |
| `HolidayCalendarAssignment` | Assigns calendars to scopes with `MergeStrategy` (MERGE / REPLACE) |
| `WorkWeekPolicy` | Working days policy per scope |
| `WorkWeekPolicyDay` | Per-day config within a policy |
| `WorkWeekPolicyAssignment` | Assigns policy to scopes with effective dates |
| `ShiftSwapRequest` | Swap request between two employees with workflow |
| `OutboxMessages` | RabbitMQ outbox for this service |

### Key Column Notes

**LeaveType** — add column beyond schema:
```sql
WorkflowCode NVARCHAR(200) NULL  -- "STANDARD_LEAVE_V1", "EMERGENCY_LEAVE_V1"
```

**EmployeeShiftRoster:**
- `IsLocked BIT` — `true` = never overwritten by `GenerateRosterAsync`

**EmployeeRosterGenerationTracker:**
- `GenerationType` → FK to `shared.StatusLookup` group `ROSTER_GENERATION_TYPE`
- Values: `MONTHLY`, `WEEKLY`, `ADHOC`
- Unique: `(EmployeeId, RosterYear, RosterMonth, GenerationType)`

**RotationShiftDetail:**
- CHECK: `(IsOffDay=1 AND ShiftId IS NULL) OR (IsOffDay=0 AND ShiftId IS NOT NULL)`
- UNIQUE: `(RotationShiftId, SequenceNo)`

**HolidayCalendarAssignment:**
- `MergeStrategy`: `MERGE` = union all calendars; `REPLACE` = override lower-scope

**Scope assignments:** `ScopeTypeId` FK to `time.ScopeType`. Hierarchy: GLOBAL(1) → COUNTRY(2) → LEGAL_ENTITY(3) → OFFICE(4) → DEPARTMENT(5) → TEAM(6) → EMPLOYEE(7).

---

## Domain Entities

One C# file per entity. All extend `BaseAuditEntity<Guid>`. File path: `Domain/Entities/{EntityName}.cs`.

### Entities implementing `IPublishableEntity`
`LeaveType`, `Shift`, `HolidayCalendar`, `Holiday`, `WorkWeekPolicy`

### Extra Properties Beyond DB Schema

```csharp
// LeaveType — add:
public string? WorkflowCode { get; set; }

// RotationShift — add navigation:
public ICollection<RotationShiftDetail> Details { get; set; } = [];

// WorkWeekPolicy — add navigation:
public ICollection<WorkWeekPolicyDay> Days { get; set; } = [];
```

---

## Holiday Assignment and Resolution

Holidays are **never assigned directly to employees** — assigned to scopes via `HolidayCalendarAssignment`.

**Seed example:**
```
HC-INDIA-NATIONAL → COUNTRY/India     (MergeStrategy=MERGE, Priority=1)
HC-MH-STATE       → OFFICE/Mumbai     (MergeStrategy=MERGE, Priority=2)
HC-KA-STATE       → OFFICE/Bangalore  (MergeStrategy=MERGE, Priority=2)
```

**Resolution algorithm (in `IScopeResolutionService`):**
```csharp
// ResolveHolidaysAsync(EmployeeSummaryResponse employee, DateOnly from, DateOnly to)
// 1. Build scope chain: EMPLOYEE→TEAM→DEPT→OFFICE→LEGAL_ENTITY→COUNTRY→GLOBAL
// 2. For each scope: query HolidayCalendarAssignment (IsActive, effective dates)
// 3. Apply MergeStrategy:
//    MERGE  → union holidays from this calendar into result set
//    REPLACE → clear result, start fresh with this calendar
// 4. Return final merged holiday list

// Example: nurse in Mumbai ICU
//   COUNTRY/India  → HC-INDIA-NATIONAL → 14 national holidays (MERGE)
//   OFFICE/Mumbai  → HC-MH-STATE       → +2 Maharashtra holidays (MERGE)
//   Result = 16 applicable holidays
```

**When applied:**

| Operation | Holiday Used |
|---|---|
| Roster Generation | Resolved holidays → `IsHoliday=true` on roster row |
| Attendance Processing | Reads `IsHoliday` from pre-generated roster |
| Leave Balance Calc | Holiday dates within leave period excluded from `TotalDays` |
| On-demand API | `GET /api/v1/holidays/applicable?employeeId=&from=&to=` |

---

## Shift Assignment to Employees

Resolution priority (highest wins):
```
1.  EmployeeShiftRoster IsLocked=true     ← manual upload, never overwritten
2.  RotationShiftAssignment EMPLOYEE scope
3.  RotationShiftAssignment TEAM scope
4.  RotationShiftAssignment DEPARTMENT scope
5.  RotationShiftAssignment OFFICE scope
6.  ShiftAssignment EMPLOYEE scope
7.  ShiftAssignment TEAM scope
8.  ShiftAssignment DEPARTMENT scope
9.  ShiftAssignment OFFICE scope
10. ShiftAssignment LEGAL_ENTITY scope
11. ShiftAssignment COUNTRY scope
12. ShiftAssignment GLOBAL scope          ← company-wide default
```

### Fixed Shift Resolution
```csharp
// Walk scope from EMPLOYEE(7) → GLOBAL(1)
// Find ShiftAssignment WHERE ScopeTypeId = level, ScopeReferenceId = employee's ID at that level
// EffectiveFrom <= date AND (EffectiveTo IS NULL OR EffectiveTo >= date) AND IsActive = true
// Return first match ordered by HierarchyLevel DESC, PriorityOrder ASC
```

### Rotation Shift Cycle Calculation
```csharp
// Seed: ROT-NURSING-3SHIFT, CycleLengthDays=19
// EMP010: RotationOffsetDays=0, EMP011: RotationOffsetDays=3, EMP012: RotationOffsetDays=6
// (offset prevents all nurses having same off-day simultaneously)

int daysSinceStart  = (targetDate.DayNumber - assignment.RotationStartDate.DayNumber)
                    + assignment.RotationOffsetDays;
int positionInCycle = ((daysSinceStart % cycleLengthDays) + cycleLengthDays) % cycleLengthDays;

int accumulated = 0;
foreach (var detail in rotation.Details.OrderBy(d => d.SequenceNo))
{
    accumulated += detail.DurationDays;
    if (positionInCycle < accumulated)
        return detail.IsOffDay ? null : detail.Shift;
}
```

---

## Roster Generation

### When Generated

Roster is generated **in advance** by HR admin or scheduled job — not daily automatically. Daily attendance processing reads the pre-generated roster.

### Database Handles All Frequencies

The schema is date-level granular. Any frequency works:

| Frequency | GenerationType | FromDate | ToDate |
|---|---|---|---|
| Monthly | `MONTHLY` | Jun 1 | Jun 30 |
| Bi-weekly | `WEEKLY` | Jun 1 | Jun 14 |
| Weekly | `WEEKLY` | Jun 1 | Jun 7 |
| Single day | `ADHOC` | Jun 5 | Jun 5 |

`EmployeeRosterGenerationTracker` unique constraint `(EmployeeId, RosterYear, RosterMonth, GenerationType)` allows coexisting `MONTHLY` + `WEEKLY` + `ADHOC` trackers for same month.

### Full Generation Algorithm

```csharp
// Application/Services/RosterService.cs — GenerateAsync
public async Task<RosterGenerationResult> GenerateAsync(GenerateRosterRequest request, CancellationToken ct)
{
    var employees = await ResolveEmployeesInScopeAsync(request, ct);

    foreach (var employee in employees)
    {
        var tracker = await trackerRepo.GetAsync(employee.Id, request.FromDate.Year, request.FromDate.Month, ct);
        if (tracker?.IsLocked == true && !request.ForceRegenerate) continue;

        var empSummary       = await employeeHttpClient.GetSummaryAsync(employee.Id, ct);
        var holidays         = await scopeResolution.ResolveHolidaysAsync(empSummary, request.FromDate, request.ToDate, ct);
        var holidayDates     = holidays.Select(h => h.HolidayDate).ToHashSet();
        var workWeek         = await scopeResolution.ResolveWorkWeekPolicyAsync(empSummary, request.FromDate, ct);
        var rotationAssign   = await scopeResolution.ResolveRotationAssignmentAsync(empSummary, request.FromDate, ct);

        for (var date = request.FromDate; date <= request.ToDate; date = date.AddDays(1))
        {
            var existing = await rosterRepo.GetByEmployeeDateAsync(employee.Id, date, ct);
            if (existing?.IsLocked == true && !request.ForceRegenerate) continue;

            var roster = existing ?? new EmployeeShiftRoster
            {
                Id = Guid.NewGuid(), EmployeeId = employee.Id, RosterDate = date, IsActive = true
            };

            if (holidayDates.Contains(date))
            {
                SetHoliday(roster, request.LockAfterGenerate);
            }
            else if (!IsWorkingDay(workWeek, date))
            {
                SetOffDay(roster, request.LockAfterGenerate);
            }
            else
            {
                var shift = rotationAssign != null
                    ? ResolveRotationShift(rotationAssign, date)
                    : await scopeResolution.ResolveShiftAsync(empSummary, date, ct);

                SetShift(roster, shift, date, request.LockAfterGenerate);
            }

            await UpsertRosterAsync(roster, existing, ct);
        }

        await trackerRepo.UpsertAsync(BuildTracker(employee.Id, request), ct);
    }

    await unitOfWork.SaveChangesAsync(ct);
}
```

### Roster Change Handling (Mid-Period Shift Change)

**Option A — Re-generate with ForceRegenerate:**
```
POST /api/v1/rosters/generate
{ FromDate: Jun15, ToDate: Jun30, EmployeeIds: [empId], ForceRegenerate: true, GenerationType: "ADHOC" }
→ Overwrites rows Jun 15-30, picks up new ShiftAssignment effective Jun 15
→ Rows Jun 1-14 untouched
```

**Option B — Single row edit:**
```
PUT /api/v1/rosters/{id}
→ Set ShiftId, PlannedStartTime, PlannedEndTime, IsLocked=true
```

**Option C — Bulk unlock + re-generate:**
```
PATCH /api/v1/rosters/bulk-unlock?employeeId=&from=Jun15&to=Jun30
→ Sets IsLocked=false
Then: POST /api/v1/rosters/generate (ForceRegenerate=false, picks up new assignment)
```

### Manual Roster Upload

```csharp
// Application/DTOs/Roster/Request/RosterUploadRequest.cs
namespace SdxCore.Attendance.Application.DTOs.Roster.Request;

public record RosterUploadRequest(
    DateOnly        FromDate,
    DateOnly        ToDate,
    string          GenerationType,     // "WEEKLY", "MONTHLY", "ADHOC"
    List<RosterRow> Rows,
    bool            LockAfterUpload = true,
    string?         Remarks = null);

// Application/DTOs/Roster/Request/RosterRow.cs
public record RosterRow(
    Guid     EmployeeId,
    DateOnly Date,
    Guid?    ShiftId,
    bool     IsOffDay   = false,
    bool     IsHoliday  = false,
    string?  Remarks    = null);

// Application/DTOs/Roster/Response/RosterUploadResult.cs
public record RosterUploadResult(
    int          TotalRows,
    int          Created,
    int          Updated,
    int          Skipped,
    List<string> Errors);
```

---

## Attendance Calculation

### Daily Processing Job

`ProcessDailyAsync(DateOnly date)` — scheduled at 00:30 daily, runs after `AttendanceFinalizeBufferMinutes`.

```csharp
// Application/Services/AttendanceService.cs
public async Task ProcessDailyAsync(DateOnly date, CancellationToken ct)
{
    var rosterRows = await rosterRepo.GetByDateAsync(date, ct);

    foreach (var roster in rosterRows)
    {
        var existing = await attendanceRepo.GetByEmployeeDateAsync(roster.EmployeeId, date, ct);
        if (existing?.IsAttendanceLocked == true) continue;

        var session     = await workSessionRepo.GetByRosterAsync(roster.Id, ct);
        var activeLeave = await leaveRepo.GetApprovedLeaveForDateAsync(roster.EmployeeId, date, ct);

        var (statusCode, metrics) = CalculateAttendance(roster, session, activeLeave);

        var record = existing ?? new AttendanceRecord
        {
            Id = Guid.NewGuid(), EmployeeId = roster.EmployeeId, AttendanceDate = date
        };

        record.EmployeeShiftRosterId = roster.Id;
        record.WorkSessionId         = session?.Id;
        record.ShiftId               = roster.ShiftId;
        record.AttendanceStatusId    = await statusRepo.GetIdByCodeAsync(statusCode, ct);
        record.CheckInTime           = session?.CheckInTime;
        record.CheckOutTime          = session?.CheckOutTime;
        record.WorkedMinutes         = metrics.WorkedMinutes;
        record.LateByMinutes         = metrics.LateByMinutes;
        record.EarlyExitMinutes      = metrics.EarlyExitMinutes;
        record.OvertimeMinutes       = metrics.OvertimeMinutes;
        record.BreakMinutes          = (short)(roster.Shift?.BreakDurationMinutes ?? 0);
        record.IsNightShift          = roster.Shift?.IsNightShift ?? false;
        record.IsCrossDayAttendance  = roster.Shift?.CrossesMidnight ?? false;
        record.IsWeeklyOff           = roster.IsOffDay;
        record.IsHoliday             = roster.IsHoliday;
        record.IsOnLeave             = activeLeave != null;
        record.IsAutoProcessed       = true;

        await attendanceRepo.UpsertAsync(record, ct);
    }

    await unitOfWork.SaveChangesAsync(ct);
}
```

### Attendance Metrics Calculation

```csharp
private (string StatusCode, AttendanceMetrics Metrics) CalculateAttendance(
    EmployeeShiftRoster roster, WorkSession? session, LeaveRequest? activeLeave)
{
    var metrics = new AttendanceMetrics();

    if (roster.IsHoliday) return (AttendanceStatusCodes.Holiday, metrics);
    if (roster.IsOffDay)  return (AttendanceStatusCodes.Weekend, metrics);
    if (activeLeave != null) return (AttendanceStatusCodes.OnLeave, metrics);

    if (session == null || session.CheckInTime == default)
        return (AttendanceStatusCodes.Absent, metrics);

    var plannedStart = roster.PlannedStartTime ?? session.CheckInTime;
    var plannedEnd   = roster.PlannedEndTime   ?? session.CheckOutTime ?? session.CheckInTime;
    var graceIn      = TimeSpan.FromMinutes(roster.Shift?.GraceInMinutes  ?? 0);
    var graceOut     = TimeSpan.FromMinutes(roster.Shift?.GraceOutMinutes ?? 0);
    var breakMins    = roster.Shift?.BreakDurationMinutes ?? 0;

    if (session.CheckInTime > plannedStart.Add(graceIn))
        metrics = metrics with { LateByMinutes = (short)(session.CheckInTime - plannedStart.Add(graceIn)).TotalMinutes };

    if (session.CheckOutTime.HasValue)
    {
        var earlyThreshold = plannedEnd.Subtract(graceOut);
        if (session.CheckOutTime.Value < earlyThreshold)
            metrics = metrics with { EarlyExitMinutes = (short)(earlyThreshold - session.CheckOutTime.Value).TotalMinutes };

        var raw = (session.CheckOutTime.Value - session.CheckInTime).TotalMinutes - breakMins;
        metrics = metrics with { WorkedMinutes = (short)Math.Max(0, raw) };

        var stdMins = roster.Shift?.MaximumWorkingMinutes
                   ?? (int)(plannedEnd - plannedStart).TotalMinutes - breakMins;
        if (roster.Shift?.AllowOvertime == true && metrics.WorkedMinutes > stdMins)
            metrics = metrics with { OvertimeMinutes = (short)(metrics.WorkedMinutes - stdMins) };
    }

    var minWorking = roster.Shift?.MinimumWorkingMinutes ?? 0;

    if (session.CheckOutTime == null)      return (AttendanceStatusCodes.Present, metrics);
    if (metrics.WorkedMinutes < minWorking / 2) return (AttendanceStatusCodes.Absent, metrics);
    if (metrics.WorkedMinutes < minWorking)     return (AttendanceStatusCodes.HalfDay, metrics);
    if (metrics.LateByMinutes > 0)              return (AttendanceStatusCodes.Late, metrics);

    return (AttendanceStatusCodes.Present, metrics);
}

// Application/DTOs/Attendance/Response/AttendanceMetrics.cs (internal use)
public record AttendanceMetrics(
    short WorkedMinutes    = 0,
    short LateByMinutes    = 0,
    short EarlyExitMinutes = 0,
    short OvertimeMinutes  = 0);
```

### Decision Tree

```
IsHoliday = true         → HOLIDAY
IsOffDay = true          → WEEKEND
ApprovedLeave exists     → ON_LEAVE
No check-in after buffer → ABSENT
CheckOut null            → PRESENT (tentative)
WorkedMinutes < min/2    → ABSENT
WorkedMinutes < min      → HALF_DAY
LateByMinutes > 0        → LATE
Otherwise                → PRESENT
```

### Night Shift Handling

For `CrossesMidnight=true` (e.g. SHF-NIGHT 20:00-08:00):
- `PlannedStartTime` = roster date at 20:00
- `PlannedEndTime` = **next day** at 08:00 (`date.AddDays(1).ToDateTime(shift.EndTime)`)
- `AttendanceRecord` credited to the **date the shift started**
- `IsCrossDayAttendance = true`

---

## Application Service Interfaces

File path: `Application/Abstractions/Services/I{Name}Service.cs`
Namespace: `SdxCore.Attendance.Application.Abstractions.Services`

```csharp
// ILeaveService.cs
public interface ILeaveService
{
    Task<PagedResponse<IEnumerable<LeaveRequestResponse>>> GetAllAsync(PaginationFilter filter, Guid? employeeId, string? status, CancellationToken ct);
    Task<LeaveRequestResponse?> GetByIdAsync(Guid id, CancellationToken ct);
    Task<IEnumerable<LeaveRequestResponse>> GetByEmployeeAsync(Guid employeeId, CancellationToken ct);
    Task<IEnumerable<LeaveBalanceResponse>> GetBalanceAsync(Guid employeeId, int year, CancellationToken ct);
    Task<LeaveRequestResponse> SubmitAsync(CreateLeaveRequestRequest request, CancellationToken ct);
    Task<bool> CancelAsync(Guid id, CancellationToken ct);
    Task<bool> WithdrawAsync(Guid id, CancellationToken ct);
    Task<LeaveRequestResponse?> GetByWorkflowInstanceAsync(Guid workflowInstanceId, CancellationToken ct);
    Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, CancellationToken ct);
}

// IShiftService.cs
public interface IShiftService
{
    Task<PagedResponse<IEnumerable<ShiftResponse>>> GetAllAsync(PaginationFilter filter, CancellationToken ct);
    Task<ShiftResponse?> GetByIdAsync(Guid id, CancellationToken ct);
    Task<ShiftResponse> CreateAsync(CreateShiftRequest request, CancellationToken ct);
    Task<bool> UpdateAsync(Guid id, UpdateShiftRequest request, CancellationToken ct);
    Task<bool> ToggleStatusAsync(Guid id, CancellationToken ct);
    Task<ShiftResponse?> ResolveForEmployeeAsync(Guid employeeId, DateOnly date, CancellationToken ct);
}

// IRosterService.cs
public interface IRosterService
{
    Task<IEnumerable<RosterResponse>> GetByEmployeeAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken ct);
    Task<RosterResponse?> GetByDateAsync(Guid employeeId, DateOnly date, CancellationToken ct);
    Task<RosterGenerationResult> GenerateAsync(GenerateRosterRequest request, CancellationToken ct);
    Task<RosterUploadResult> UploadAsync(RosterUploadRequest request, CancellationToken ct);
    Task<RosterUploadResult> UploadCsvAsync(Stream csvStream, bool lockAfterUpload, CancellationToken ct);
    Task<bool> LockAsync(Guid id, CancellationToken ct);
    Task<bool> UnlockAsync(Guid id, CancellationToken ct);
    Task<bool> BulkUnlockAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken ct);
    Task<bool> UpdateAsync(Guid id, UpdateRosterRequest request, CancellationToken ct);
    Task ExecuteShiftSwapAsync(Guid workflowInstanceId, CancellationToken ct);
}

// IAttendanceService.cs
public interface IAttendanceService
{
    Task<PagedResponse<IEnumerable<AttendanceRecordResponse>>> GetAllAsync(PaginationFilter filter, Guid? employeeId, DateOnly? from, DateOnly? to, CancellationToken ct);
    Task<AttendanceRecordResponse?> GetByIdAsync(Guid id, CancellationToken ct);
    Task<AttendanceRecordResponse?> GetByEmployeeDateAsync(Guid employeeId, DateOnly date, CancellationToken ct);
    Task CheckInAsync(CheckInRequest request, CancellationToken ct);
    Task CheckOutAsync(CheckOutRequest request, CancellationToken ct);
    Task ProcessDailyAsync(DateOnly date, CancellationToken ct);
    Task<bool> LockAsync(Guid id, CancellationToken ct);
    Task RegularizeAsync(CreateRegularizationRequest request, CancellationToken ct);
    Task ApplyRegularizationAsync(Guid workflowInstanceId, CancellationToken ct);
    Task UpdateRegularizationStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, CancellationToken ct);
}

// IHolidayService.cs
public interface IHolidayService
{
    Task<IEnumerable<HolidayCalendarResponse>> GetAllCalendarsAsync(CancellationToken ct);
    Task<IEnumerable<HolidayResponse>> GetByCalendarAsync(Guid calendarId, int year, CancellationToken ct);
    Task<IEnumerable<HolidayResponse>> GetApplicableAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken ct);
    Task<HolidayResponse> CreateAsync(CreateHolidayRequest request, CancellationToken ct);
    Task<bool> UpdateAsync(Guid id, UpdateHolidayRequest request, CancellationToken ct);
    Task<bool> ToggleStatusAsync(Guid id, CancellationToken ct);
}

// IShiftSwapService.cs
public interface IShiftSwapService
{
    Task<ShiftSwapResponse> RequestSwapAsync(CreateShiftSwapRequest request, CancellationToken ct);
    Task<bool> CancelAsync(Guid id, CancellationToken ct);
    Task<ShiftSwapResponse?> GetByIdAsync(Guid id, CancellationToken ct);
    Task<IEnumerable<ShiftSwapResponse>> GetMyRequestsAsync(Guid employeeId, CancellationToken ct);
    Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, CancellationToken ct);
}

// ICompOffService.cs
public interface ICompOffService
{
    Task<IEnumerable<CompOffBalanceResponse>> GetBalanceAsync(Guid employeeId, CancellationToken ct);
    Task<CompOffBalanceResponse> EarnAsync(EarnCompOffRequest request, CancellationToken ct);
    Task RedeemAsync(RedeemCompOffRequest request, CancellationToken ct);
    Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, CancellationToken ct);
}

// IScopeResolutionService.cs (Domain Abstractions)
// Namespace: SdxCore.Attendance.Domain.Abstractions.Services
public interface IScopeResolutionService
{
    Task<Shift?> ResolveShiftAsync(EmployeeSummaryResponse employee, DateOnly date, CancellationToken ct);
    Task<IEnumerable<Holiday>> ResolveHolidaysAsync(EmployeeSummaryResponse employee, DateOnly from, DateOnly to, CancellationToken ct);
    Task<WorkWeekPolicy?> ResolveWorkWeekPolicyAsync(EmployeeSummaryResponse employee, DateOnly date, CancellationToken ct);
    Task<RotationShiftAssignment?> ResolveRotationAssignmentAsync(EmployeeSummaryResponse employee, DateOnly date, CancellationToken ct);
}
```

---

## Workflow Integration

### Submission Flow (Attendance → Workflow)

```
LeaveService.SubmitAsync()
  → leaveRequestRepo.AddAsync(leaveRequest)     [staged]
  → AttendanceWorkflowOutboxInterceptor fires
       → Builds LeaveRequestSubmittedEvent
       → outboxRepo.AddAsync(OutboxMessage)     [staged]
  → unitOfWork.SaveChangesAsync()               [single commit]
  → OutboxProcessorBackgroundService polls
  → RabbitMQ → Workflow.LeaveRequestSubmittedConsumer
       → WorkflowEngine.SubmitAsync(moduleCode, workflowCode, employeeId)
```

### Events Published (in `SdxCore.SharedKernel.Events`)

```csharp
public record LeaveRequestSubmittedEvent(
    Guid     LeaveRequestId,
    Guid     EmployeeId,
    string   LeaveTypeCode,
    string   WorkflowCode,      // from LeaveType.WorkflowCode
    string   ModuleCode,        // "LEAVE_REQUEST"
    DateOnly FromDate,
    DateOnly ToDate,
    decimal  TotalDays,
    string?  Reason,
    DateTime OccurredOnUtc);

public record AttendanceRegularizationSubmittedEvent(
    Guid      RegularizationId,
    Guid      EmployeeId,
    string    WorkflowCode,     // "ATTENDANCE_REGULARIZATION_V1"
    string    ModuleCode,       // "ATTENDANCE_REGULARIZATION"
    DateOnly  AttendanceDate,
    DateTime? RequestedCheckIn,
    DateTime? RequestedCheckOut,
    string?   Reason,
    DateTime  OccurredOnUtc);

public record ShiftSwapRequestSubmittedEvent(
    Guid     ShiftSwapRequestId,
    Guid     RequesterEmployeeId,
    Guid     TargetEmployeeId,
    Guid     RequesterRosterId,
    Guid     TargetRosterId,
    string   WorkflowCode,      // "SHIFT_SWAP_V1"
    string   ModuleCode,        // "SHIFT_SWAP_REQUEST"
    DateOnly SwapDate,
    DateTime OccurredOnUtc);

public record CompOffRedemptionSubmittedEvent(
    Guid     CompOffBalanceId,
    Guid     EmployeeId,
    string   WorkflowCode,      // "COMP_OFF_REDEMPTION_V1"
    string   ModuleCode,        // "COMP_OFF_REDEMPTION"
    decimal  RequestedDays,
    DateTime OccurredOnUtc);
```

### Event Consumed From Workflow

```csharp
public record WorkflowInstanceStatusChangedEvent(
    Guid     WorkflowInstanceId,
    string   ModuleCode,
    Guid     ReferenceTransactionId,
    string   NewStatus,
    string   EventType,         // "status_changed" | "returned" | "delegated"
    Guid     ActionBy,
    string?  Remarks,
    DateTime OccurredOnUtc);
```

---

## RabbitMQ Consumers

### Consumer Pattern (follow exactly)

```csharp
// Application/Consumers/WorkflowInstanceStatusChangedConsumer.cs
namespace SdxCore.Attendance.Application.Consumers;

public sealed class WorkflowInstanceStatusChangedConsumer(
    ILeaveService      leaveService,
    IAttendanceService attendanceService,
    IShiftSwapService  shiftSwapService,
    IRosterService     rosterService,
    ICompOffService    compOffService,
    ILogger<WorkflowInstanceStatusChangedConsumer> logger)
    : IConsumer<WorkflowInstanceStatusChangedEvent>
{
    public async Task Consume(ConsumeContext<WorkflowInstanceStatusChangedEvent> context)
    {
        var evt = context.Message;
        var ct  = context.CancellationToken;

        if (evt.EventType == "delegated") return;

        logger.LogInformation(
            "Workflow status change. Module={Module}, Entity={EntityId}, Status={Status}",
            evt.ModuleCode, evt.ReferenceTransactionId, evt.NewStatus);

        try
        {
            switch (evt.ModuleCode)
            {
                case WorkflowModuleCodes.Leave:
                    await leaveService.UpdateStatusFromWorkflowAsync(
                        evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, ct);
                    break;

                case WorkflowModuleCodes.AttendanceRegularization:
                    await attendanceService.UpdateRegularizationStatusFromWorkflowAsync(
                        evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, ct);
                    if (evt.NewStatus == RegularizationStatus.Approved)
                        await attendanceService.ApplyRegularizationAsync(evt.WorkflowInstanceId, ct);
                    break;

                case WorkflowModuleCodes.ShiftSwap:
                    await shiftSwapService.UpdateStatusFromWorkflowAsync(
                        evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, ct);
                    if (evt.NewStatus == ShiftSwapStatus.Approved)
                        await rosterService.ExecuteShiftSwapAsync(evt.WorkflowInstanceId, ct);
                    break;

                case WorkflowModuleCodes.CompOff:
                    await compOffService.UpdateStatusFromWorkflowAsync(
                        evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, ct);
                    break;

                default:
                    logger.LogDebug("Unhandled module '{Module}' — skipping.", evt.ModuleCode);
                    break;
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Failed to process event for {Module}/{EntityId}",
                evt.ModuleCode, evt.ReferenceTransactionId);
            throw; // MassTransit handles retry → dead-letter
        }
    }
}
```

### Adding a New Consumer

**Step 1:** Add event record to `SdxCore.SharedKernel.Events`
**Step 2:** Create consumer in `Application/Consumers/{EventName}Consumer.cs`
**Step 3:** Register in `AddSdxCoreAttendanceMessaging`:
```csharp
configureBus.AddConsumer<NewEventConsumer>(); // add here
```
**Step 4:** No other changes — `AddSdxMessaging` auto-creates queue from class name + prefix.

### Consumer Rules

1. **Always re-throw** — never swallow. MassTransit handles retry + dead-letter.
2. **Idempotent** — guard: `if (entity.Status == newStatus) return;`
3. **Never inject DbContext** — always via Application service interface.
4. **Log Information on entry, Error on exception.**
5. **Skip gracefully** if `ModuleCode` not owned by this service.
6. **Use `context.CancellationToken`** — never `CancellationToken.None`.

---

## Inter-Service Communication

### Pattern 1: HTTP (Synchronous)

Use when data is needed **immediately** to complete the current request.

```csharp
// Application/Abstractions/Http/IEmployeeHttpClient.cs
namespace SdxCore.Attendance.Application.Abstractions.Http;

public interface IEmployeeHttpClient
{
    Task<EmployeeSummaryResponse?> GetSummaryAsync(Guid employeeId, CancellationToken ct);
    Task<IEnumerable<EmployeesByDesignationResponse>> GetByDesignationInScopeAsync(
        List<short> designationIds, short? scopeTypeId, int? scopeReferenceId, CancellationToken ct);
}

// Infrastructure/Http/EmployeeHttpClient.cs
public class EmployeeHttpClient(HttpClient http, ILogger<EmployeeHttpClient> logger)
    : IEmployeeHttpClient
{
    public async Task<EmployeeSummaryResponse?> GetSummaryAsync(Guid employeeId, CancellationToken ct)
    {
        try
        {
            var response = await http.GetFromJsonAsync<ApiResponse<EmployeeSummaryResponse>>(
                $"/api/v1/employees/{employeeId}/summary", ct);
            return response?.Data;
        }
        catch (HttpRequestException ex)
        {
            logger.LogError(ex, "Failed to get employee summary for {EmployeeId}", employeeId);
            return null;
        }
    }
}
```

**Internal API Key Handler (add to all outbound HTTP clients):**
```csharp
// Infrastructure/Http/InternalApiKeyHandler.cs
public class InternalApiKeyHandler(IConfiguration config) : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken ct)
    {
        request.Headers.Add("X-Internal-ApiKey", config["Gateway:InternalApiKey"]);
        return await base.SendAsync(request, ct);
    }
}
```

### Pattern 2: RabbitMQ (Asynchronous)

Use when **notifying** another service or **triggering** a long-running process.

```
Submit leave → outbox → RabbitMQ → Workflow initiates approval
Approval done → RabbitMQ → Attendance updates status
```

**Never call Workflow HTTP to submit. Always via outbox → RabbitMQ.**

### Service Communication Table

| Source | Target | Pattern | When |
|---|---|---|---|
| Attendance | Employee | HTTP GET | Roster generation, shift/holiday resolution |
| Attendance | Time | HTTP GET | Scope types |
| Attendance | Workflow | **RabbitMQ** | Submit leave/regularization/swap/comp-off |
| Workflow | Attendance | **RabbitMQ** | Approval status changes |
| Workflow | Employee | HTTP GET | Resolve approvers |

---

## API Controllers

All inherit `SdxControllerBase`. All decorated `[GatewayOnly]`. Prefix `api/v1/`. Use `IRequestContext` for `UserId`.

```csharp
// Pattern from Employee service:
[HttpPost]
public async Task<IActionResult> Create([FromBody] CreateLeaveRequestRequest request, CancellationToken ct)
{
    var validation = await ValidateAsync(request, ct);   // resolves IValidator<T> from DI
    if (validation != null) return validation;

    var result = await _service.SubmitAsync(request, ct);
    return CreatedAtAction(nameof(GetById), new { id = result.Id },
        new ApiResponse<LeaveRequestResponse>(result, "Leave submitted successfully."));
}
```

### Leave — `api/v1/leaves`
```
GET    /                               GetAll (filter, employeeId?, status?)
GET    /{id}                           GetById
GET    /employee/{employeeId}          GetByEmployee
GET    /employee/{employeeId}/balance  GetBalance (?year=)
POST   /                               Submit
PATCH  /{id}/cancel                    Cancel
PATCH  /{id}/withdraw                  Withdraw
GET    /workflow/{instanceId}          GetByWorkflowInstance
```

### Attendance — `api/v1/attendance`
```
GET    /                               GetAll (filter, employeeId?, from?, to?)
GET    /{id}                           GetById
GET    /employee/{employeeId}/date/{date}  GetByEmployeeDate
POST   /check-in                       CheckIn
POST   /check-out                      CheckOut
POST   /process-daily                  ProcessDaily (admin, ?date=)
PATCH  /{id}/lock                      Lock
```

### Regularization — `api/v1/attendance/regularizations`
```
GET    /                               GetAll (filter, employeeId?)
GET    /{id}                           GetById
POST   /                               Submit
PATCH  /{id}/withdraw                  Withdraw
GET    /workflow/{instanceId}          GetByWorkflowInstance
```

### Shift — `api/v1/shifts`
```
GET    /                               GetAll
GET    /{id}                           GetById
GET    /resolve                        ResolveForEmployee (?employeeId=&date=)
POST   /                               Create
PUT    /{id}                           Update
PATCH  /{id}/status                    ToggleStatus
```

### Roster — `api/v1/rosters`
```
GET    /employee/{employeeId}          GetByEmployee (?from=&to=)
GET    /employee/{employeeId}/date/{date}  GetByDate
POST   /generate                       GenerateRoster
POST   /upload                         UploadRoster (JSON)
POST   /upload/csv                     UploadRosterCsv (multipart/form-data)
PATCH  /{id}/lock                      Lock
PATCH  /{id}/unlock                    Unlock
PATCH  /bulk-unlock                    BulkUnlock (?employeeId=&from=&to=)
PUT    /{id}                           Update
```

### Shift Swap — `api/v1/shift-swaps`
```
GET    /                               GetMyRequests
GET    /{id}                           GetById
POST   /                               RequestSwap
PATCH  /{id}/cancel                    Cancel
```

### Holiday — `api/v1/holidays`
```
GET    /calendars                      GetAllCalendars
GET    /calendars/{id}                 GetCalendar
POST   /calendars                      CreateCalendar
GET    /calendars/{id}/holidays        GetByCalendar (?year=)
POST   /calendars/{id}/holidays        CreateHoliday
PUT    /holidays/{id}                  UpdateHoliday
PATCH  /holidays/{id}/status           ToggleStatus
GET    /applicable                     GetApplicable (?employeeId=&from=&to=)
```

### Comp-Off — `api/v1/comp-offs`
```
GET    /employee/{employeeId}          GetBalance
POST   /earn                           Earn
POST   /redeem                         Redeem
```

### Rotation Shift — `api/v1/rotation-shifts`
```
GET    /                               GetAll
GET    /{id}                           GetById
POST   /                               Create
PUT    /{id}                           Update
GET    /{id}/details                   GetDetails
POST   /{id}/assignments               AssignToScope
```

---

## Persistence Layer

### AttendanceDbContext

```csharp
// Persistence/Data/AttendanceDbContext.cs
namespace SdxCore.Attendance.Persistence.Data;

public class AttendanceDbContext(
    DbContextOptions<AttendanceDbContext> options,
    OutboxSaveChangesInterceptor outboxInterceptor,
    AttendanceWorkflowOutboxInterceptor workflowInterceptor)
    : SdxDbContext(options)
{
    // All DbSets...

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        => optionsBuilder.AddInterceptors(outboxInterceptor, workflowInterceptor);

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.HasDefaultSchema("attendance");

        // Computed columns — NEVER written by EF:
        modelBuilder.Entity<LeaveRequest>()
            .Property(x => x.LeaveStatusGroup)
            .HasComputedColumnSql("CAST('LEAVE_STATUS' AS NVARCHAR(50))", stored: true);

        modelBuilder.Entity<AttendanceRegularization>()
            .Property(x => x.RegularizationStatusGroup)
            .HasComputedColumnSql("CAST('ATTENDANCE_REGULARIZATION_STATUS' AS NVARCHAR(50))", stored: true);

        modelBuilder.Entity<ShiftSwapRequest>()
            .Property(x => x.ShiftSwapStatusGroup)
            .HasComputedColumnSql("CAST('SHIFT_SWAP_STATUS' AS NVARCHAR(50))", stored: true);

        modelBuilder.Entity<EmployeeRosterGenerationTracker>()
            .Property(x => x.GenerationTypeGroup)
            .HasComputedColumnSql("CAST('ROSTER_GENERATION_TYPE' AS NVARCHAR(50))", stored: true);

        modelBuilder.Entity<LeaveBalance>()
            .Property(x => x.ClosingBalance)
            .HasComputedColumnSql("(OpeningBalance + Allocated + CarryForward - Availed - Encashed)", stored: false);

        modelBuilder.Entity<CompOffBalance>()
            .Property(x => x.RemainingDays)
            .HasComputedColumnSql("(TotalDays - AvailedDays)", stored: false);

        modelBuilder.Entity<OutboxMessage>()
            .ToTable("OutboxMessages", "attendance");
    }
}
```

### Repository Interface Pattern

```csharp
// Domain/Interfaces/ILeaveRequestRepository.cs
namespace SdxCore.Attendance.Domain.Interfaces;

public interface ILeaveRequestRepository
{
    Task<LeaveRequest?> GetByIdAsync(Guid id, CancellationToken ct);
    Task<(IEnumerable<LeaveRequest> Items, int TotalCount)> GetPagedAsync(
        int page, int pageSize, Guid? employeeId, string? status, CancellationToken ct);
    Task<LeaveRequest?> GetByWorkflowInstanceIdAsync(Guid workflowInstanceId, CancellationToken ct);
    Task<IEnumerable<LeaveRequest>> GetByEmployeeAsync(Guid employeeId, CancellationToken ct);
    Task<LeaveRequest?> GetApprovedLeaveForDateAsync(Guid employeeId, DateOnly date, CancellationToken ct);
    Task<LeaveRequest> AddAsync(LeaveRequest entity, CancellationToken ct);
    void Update(LeaveRequest entity);
    Task<int> SaveChangesAsync(CancellationToken ct);
}
// Implementation extends BaseRepository<LeaveRequest, Guid, AttendanceDbContext>
// NEVER call SaveChangesAsync inside repository
```

---

## DI Registration

```csharp
// Program.cs

builder.Services.AddSingleton<OutboxSaveChangesInterceptor>();
builder.Services.AddSingleton<AttendanceWorkflowOutboxInterceptor>();
builder.Services.AddTransient<InternalApiKeyHandler>();

builder.Services.AddDbContext<AttendanceDbContext>((sp, options) =>
{
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("AttendanceDb"),
        sql => sql.EnableRetryOnFailure(3));
    options.AddInterceptors(
        sp.GetRequiredService<OutboxSaveChangesInterceptor>(),
        sp.GetRequiredService<AttendanceWorkflowOutboxInterceptor>());
});

// Repositories
builder.Services.AddScoped<ILeaveRequestRepository,               LeaveRequestRepository>();
builder.Services.AddScoped<ILeaveBalanceRepository,               LeaveBalanceRepository>();
builder.Services.AddScoped<ILeaveTypeRepository,                  LeaveTypeRepository>();
builder.Services.AddScoped<IAttendanceRecordRepository,           AttendanceRecordRepository>();
builder.Services.AddScoped<IAttendanceLogRepository,              AttendanceLogRepository>();
builder.Services.AddScoped<IWorkSessionRepository,                WorkSessionRepository>();
builder.Services.AddScoped<IShiftRepository,                      ShiftRepository>();
builder.Services.AddScoped<IShiftAssignmentRepository,            ShiftAssignmentRepository>();
builder.Services.AddScoped<IRosterRepository,                     RosterRepository>();
builder.Services.AddScoped<IRosterTrackerRepository,              RosterTrackerRepository>();
builder.Services.AddScoped<IRotationShiftRepository,              RotationShiftRepository>();
builder.Services.AddScoped<IRotationAssignmentRepository,         RotationAssignmentRepository>();
builder.Services.AddScoped<IHolidayRepository,                   HolidayRepository>();
builder.Services.AddScoped<IHolidayCalendarRepository,           HolidayCalendarRepository>();
builder.Services.AddScoped<IHolidayAssignmentRepository,         HolidayAssignmentRepository>();
builder.Services.AddScoped<IWorkWeekPolicyRepository,            WorkWeekPolicyRepository>();
builder.Services.AddScoped<IWorkWeekPolicyAssignmentRepository,  WorkWeekPolicyAssignmentRepository>();
builder.Services.AddScoped<IShiftSwapRepository,                 ShiftSwapRepository>();
builder.Services.AddScoped<ICompOffRepository,                   CompOffRepository>();
builder.Services.AddScoped<IAttendanceRegularizationRepository,  AttendanceRegularizationRepository>();
builder.Services.AddScoped<IAttendanceStatusRepository,          AttendanceStatusRepository>();
builder.Services.AddScoped<IOutboxRepository,                    OutboxRepository>();

// Application services
builder.Services.AddScoped<ILeaveService,           LeaveService>();
builder.Services.AddScoped<IAttendanceService,      AttendanceService>();
builder.Services.AddScoped<IShiftService,           ShiftService>();
builder.Services.AddScoped<IRosterService,          RosterService>();
builder.Services.AddScoped<IHolidayService,         HolidayService>();
builder.Services.AddScoped<IShiftSwapService,       ShiftSwapService>();
builder.Services.AddScoped<ICompOffService,         CompOffService>();
builder.Services.AddScoped<IScopeResolutionService, ScopeResolutionService>();

// Validators — registered automatically via FluentValidation assembly scan:
builder.Services.AddValidatorsFromAssemblyContaining<CreateLeaveRequestRequestValidator>();

// HTTP clients
services.AddHttpClient<IEmployeeClient, EmployeeClient>((sp, client) =>
{
    var options = sp.GetRequiredService<IOptions<ClientOptions>>().Value;
    HttpClientConfigurator.Configure(client, options);
})
.AddHttpMessageHandler<InternalApiKeyHandler>();

services.AddHttpClient<ITimeClient, TimeClient>((sp, client) =>
{
    var options = sp.GetRequiredService<IOptions<ClientOptions>>().Value;
    HttpClientConfigurator.Configure(client, options);
})
.AddHttpMessageHandler<InternalApiKeyHandler>();

// Caching
// Register Caching
builder.Services.AddSdxCoreCaching(builder.Configuration);

// Messaging — auto-registers OutboxProcessorBackgroundService
builder.Services.AddSdxCoreAttendanceMessaging(builder.Configuration);

app.UseMiddleware<AttendanceExceptionMiddleware>();
app.MapControllers();
```
### Employee Client

```csharp
using SdxCore.Attendance.Application.DTOs.Employee;

namespace SdxCore.Attendance.Application.Abstractions.Clients;
public interface IEmployeeClient
{
    Task<EmployeeSummaryResponse?> GetEmployeeeSummaryByIdAsync(Guid id, CancellationToken cancellationToken = default!);

    Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(IEnumerable<Guid> designationIds, string? scopeCode,
    Guid? scopeReferenceId, CancellationToken cancellationToken);
}

using Microsoft.AspNetCore.WebUtilities;
using SdxCore.Common.Models;
using SdxCore.Attendace.Application.Abstractions.Clients;
using SdxCore.Attendace.Application.DTOs.Employee;
using System.Net.Http.Json;

namespace SdxCore.Attendace.Application.Clients;
public class EmployeeClient : IEmployeeClient
{
    private readonly HttpClient _httpClient;

    public EmployeeClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<EmployeeSummaryResponse?> GetEmployeeeSummaryByIdAsync(
        Guid id,
        CancellationToken cancellationToken = default!)
    {
        var employee = await _httpClient.GetFromJsonAsync<EmployeeSummaryResponse>(
           $"api/v1/employees/{id}/summary",
           cancellationToken);

        return employee;
    }

    public async Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
            IEnumerable<Guid> designationIds,
            string? scopeCode,
            Guid? scopeReferenceId,
            CancellationToken cancellationToken)
    {
        var queryParams = new List<KeyValuePair<string, string>>();

        foreach (var designationId in designationIds)
        {
            queryParams.Add(new("designationIds", designationId.ToString()));
        }

        if (scopeCode is not null)
        {
            queryParams.Add(new("scopeCode", scopeCode));
        }

        if (scopeReferenceId.HasValue)
            queryParams.Add(new("scopeReferenceId", scopeReferenceId.Value.ToString()));

        var url = QueryHelpers.AddQueryString(
            "api/v1/employees/by-designation",
            queryParams!);

        var response = await _httpClient.GetFromJsonAsync<
            ApiResponse<IEnumerable<EmployeesByDesignationResponse>>>(
            url,
            cancellationToken);

        return response?.Data ?? Enumerable.Empty<EmployeesByDesignationResponse>();
    }
}
```

### Time Client
```csharp
using SdxCore.Attendance.Application.DTOs.Time;

namespace SdxCore.Attendance.Application.Abstractions.Clients;
public interface ITimeClient
{
    Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default!);
}

using MassTransit.Middleware;
using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.DTOs.Time;
using System.Net.Http.Json;

namespace SdxCore.Attendance.Application.Clients;
public class TimeClient : ITimeClient
{
    private readonly HttpClient _httpClient;

    public TimeClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default!)
    {
        var scopeTypes = await _httpClient.GetFromJsonAsync<IEnumerable<ScopeTypeResponse>>(
            $"api/v1/scope-types",
            cancellationToken);

        return scopeTypes ?? Enumerable.Empty<ScopeTypeResponse>();
    }
}
```


### Messaging Extension

```csharp


// Application/Extensions/ServiceCollectionExtensions.cs
namespace SdxCore.Attendance.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreWorkflowMessaging(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        string serviceName = configuration["ServiceName"]?.ToLowerInvariant() ?? "attendance";

        services.AddSdxMessaging(
            configuration,
            endpointPrefix: serviceName,
            configureBus =>
            {
                configureBus.AddConsumer<WorkflowInstanceStatusChangedConsumer>();
            });

        return services;
    }
}
```

---

## appsettings.json

```json
{
  "ServiceName": "attendance",
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost,1434;Database=SdxCore;User Id=sa;Password=Office.1234!;TrustServerCertificate=True;MultipleActiveResultSets=true"
  },
  "Authentication": {
    "InternalApiKey": "Gateway-Internal-Key-2024-SecureToken-DoNotExpose"
  },
  "OutboxSettings": {
    "BatchSize": 50,
    "MaxRetries": 3,
    "PollingIntervalSeconds": 5
  },
  "Redis": {
    "ConnectionString": "localhost:6379,password=redis.1234",
    "InstanceName": "sdxcore:attendance:"
  },
  "RabbitMQ": {
    "Host": "localhost",
    "Port": 5672,
    "VirtualHost": "sdxcore",
    "Username": "sdxcore",
    "Password": "sdxcore_secret"
  },
  "TimeClient": {
    "BaseUrl": "https://localhost:7003/",
    "TimeoutSeconds": 10
  },
  "EmployeeClient": {
    "BaseUrl": "https://localhost:7005/",
    "TimeoutSeconds": 10
  }
}
```

---

## Code Generation Rules

1. **One class per file.**
2. **C# 12 primary constructors** where practical.
3. **No magic strings** — use constants from `SdxCore.Common.Enum.Attendance.*`.
4. **No `SaveChangesAsync` in repositories** — only `AddAsync`, `Update`, `Remove`.
5. **Single `SaveChangesAsync` per service method** — stage all, one commit at end.
6. **Outbox interceptors do NOT call `SaveChangesAsync`** — caller commits.
7. **Computed columns** — `.HasComputedColumnSql(...)`. Never assign to computed properties.
8. **All controllers** — inherit `SdxControllerBase`, `[GatewayOnly]`, use `IRequestContext`.
9. **All PKs are `Guid`.**
10. **Caching** — `ICacheService.GetOrSetAsync` for reads. `ICacheKeyBuilder.BuildKey(entity, id)`. Invalidate on write.
11. **All DTO↔Entity mapping** via `PropertyMapper.Map<TSource, TDest>()`. No manual mapping.
12. **DTOs** grouped as `Application/DTOs/{EntityName}/Request/` and `.../Response/`.
13. **Validators** — one file per request DTO in `Application/Validators/{EntityName}/`.
14. **Service interface namespace** — `SdxCore.Attendance.Application.Abstractions.Services`.
15. **Domain service interface namespace** — `SdxCore.Attendance.Domain.Abstractions.Services`.
16. **Never reference Workflow/Employee/Time DbContext** — HTTP for sync, RabbitMQ for async.
17. **`WorkflowInstanceId` is nullable** — only set when `LeaveType.RequiresApproval = true`.
18. **`IsLocked=true` protection** — never overwrite unless `ForceRegenerate=true`.
19. **Night shift** — attendance credited to the date shift STARTED.
20. **Consumers must be idempotent.** Always re-throw exceptions.

---

## Complete Integration Diagram

```
Admin/HR              SdxCore.Attendance               SdxCore.Workflow
─────────            ────────────────────             ────────────────────

POST /rosters/upload  RosterService.UploadAsync()
(bi-weekly CSV)        → EmployeeShiftRoster (IsLocked=true)
                       → Tracker (WEEKLY/ADHOC)
                       → SaveChangesAsync() ✓

POST /rosters/generate RosterService.GenerateAsync()
(monthly job)          → employeeHttpClient.GetSummaryAsync()       ──HTTP──► Employee
                       → ResolveHolidaysAsync()   ──────────────────────────────────────
                       → ResolveWorkWeekPolicyAsync()
                       → ResolveRotationAssignment OR ResolveShift
                       → EmployeeShiftRoster rows (skip IsLocked=true)
                       → Tracker (MONTHLY)
                       → SaveChangesAsync() ✓

POST /leaves          LeaveService.SubmitAsync()
(employee submits)     → leaveRequestRepo.AddAsync()                 [staged]
                       → AttendanceWorkflowOutboxInterceptor
                            → OutboxMessage{LeaveRequestSubmittedEvent} [staged]
                       → SaveChangesAsync() ✓ [single commit]
                       → OutboxProcessorBackgroundService
                       → RabbitMQ ──────────────────────────────────►
                                                   LeaveRequestSubmittedConsumer
                                                     → WorkflowEngine.SubmitAsync()
                                                     → WorkflowInstance + Tasks created
                                                     → OutboxMessage{StatusChangedEvent}
                                                     → SaveChangesAsync() ✓
                                                     → OutboxProcessorBackgroundService
                       ◄────────────────────────── RabbitMQ (status_changed: IN_PROGRESS)
WorkflowInstanceStatusChangedConsumer
  → leaveService.UpdateStatusFromWorkflowAsync()
  → LeaveRequest.LeaveStatus = "IN_PROGRESS"
  → SaveChangesAsync() ✓

(Approver approves)                                  WorkflowEngine.ProcessApproveAsync()
                                                       → OutboxMessage{StatusChangedEvent: APPROVED}
                                                       → SaveChangesAsync() ✓
                       ◄────────────────────────── RabbitMQ (status_changed: APPROVED)
WorkflowInstanceStatusChangedConsumer
  → LeaveRequest.LeaveStatus = "APPROVED"
  → ApprovedBy = actionBy, ApprovedAt = now
  → SaveChangesAsync() ✓

ProcessDailyAsync()   AttendanceService.ProcessDailyAsync()
(cron 00:30)           → Get all EmployeeShiftRoster rows for date
                       → For each employee:
                            CheckApprovedLeave → IsOnLeave?
                            GetWorkSession     → CheckIn/CheckOut?
                            CalculateAttendance:
                              IsHoliday  → HOLIDAY
                              IsOffDay   → WEEKEND
                              OnLeave    → ON_LEAVE
                              NoCheckIn  → ABSENT
                              Worked<half→ ABSENT/HALF_DAY
                              Late       → LATE
                              else       → PRESENT
                       → Upsert AttendanceRecord
                       → SaveChangesAsync() ✓ [bulk]

                      Employee Service             Time Service
                      ────────────────             ────────────
                       ◄── HTTP GET /employees/{id}/summary
                           returns: deptId, teamId, locationId,
                                    managerId, designationId
                                                    ◄── HTTP GET /api/v1/scope-types
                                                        returns: hierarchy levels
```