# SdxCore.Attendance Microservice — AI Generation Prompt

## Purpose

This document is a complete specification for generating the **SdxCore.Attendance** microservice — a .NET 9 Clean Architecture service responsible for Leave Management, Shift Scheduling, Attendance Tracking, Roster Management, and Holiday Calendars within the SdxCore HRMS platform.

Provide this document to an AI code generator as a single self-contained prompt.

---

## Platform Architecture Context

SdxCore is a .NET 9 microservices platform. All services follow the same Clean Architecture pattern:

```
SdxCore.<Service>/
├── Domain/          Entities, Interfaces, Exceptions
├── Application/     Services, DTOs, Abstractions, Consumers, BackgroundServices, Validators
├── Persistence/     DbContext, Repositories, Interceptors
└── API/             Controllers, Middleware
```

### Shared Packages (NuGet — already built, just reference)

| Package | Purpose |
|---|---|
| `SdxCore.SharedKernel` | `BaseEntity<T>`, `BaseAuditEntity<T>`, `IPublishableEntity`, `OutboxMessage`, `IOutboxRepository`, `OutboxRepository<TDbContext>`, `SdxDbContext`, `OutboxSaveChangesInterceptor`, `IRequestContext` |
| `SdxCore.Messaging` | `IEventPublisher`, `AddSdxMessaging()`, `OutboxProcessorBackgroundService` |
| `SdxCore.Caching` | `ICacheService`, `ICacheKeyBuilder`, `CacheOptions` |
| `SdxCore.Common` | `PagedResponse<T>`, `ApiResponse<T>`, `PaginationFilter`, `PropertyMapper`, `PasswordHasher` |
| `SdxCore.Common.Security` | `[GatewayOnly]`, `SdxControllerBase` |

### Key Shared Patterns

**BaseAuditEntity<TKey>** — all domain entities extend this:
```csharp
public abstract class BaseAuditEntity<TKey> : BaseEntity<TKey>, IAuditableEntity
{
    public Guid?     Id            { get; set; }
    public DateTime  CreatedAt     { get; set; }
    public Guid?     CreatedBy     { get; set; }
    public DateTime  LastUpdatedAt { get; set; }
    public Guid?     LastUpdatedBy { get; set; }
}
```

**IPublishableEntity** — mark entities whose changes should trigger outbox events:
```csharp
public interface IPublishableEntity { }
```

**SdxDbContext** — base DbContext with transaction + execution strategy:
```csharp
public abstract class SdxDbContext : DbContext
{
    public override async Task<int> SaveChangesAsync(CancellationToken ct = default)
    {
        // Wraps in transaction via CreateExecutionStrategy
        // If a transaction is already open, just saves normally
    }
}
```

**OutboxSaveChangesInterceptor** — automatically writes `EntityChangedEvent` to `OutboxMessages` for every `IPublishableEntity` Add/Update/Delete.

**OutboxProcessorBackgroundService** — polls `OutboxMessages` and publishes to RabbitMQ via `IEventPublisher`. Registered once via `AddSdxMessaging()`.

**GatewayOnly** — all endpoints require `X-Internal-ApiKey` header (injected by YARP Gateway). Also injects `X-User-Id`, `X-User-Name`, `X-Roles` headers.

---

## Database Schema

Schema name: `attendance`  
Primary keys: `UNIQUEIDENTIFIER` → `Guid` in C#  
Audit columns: `CreatedAt`, `CreatedBy`, `LastUpdatedAt`, `LastUpdatedBy` on every table  
Status columns: FK to `shared.StatusLookup (StatusCode, StatusGroup)` — enforced via computed persisted `*Group` column  
Cross-schema dependencies: `employee.Employee`, `time.ScopeType`, `time.GeoFence`, `workflow.WorkflowInstance`, `shared.StatusLookup`

### Tables

| Table | Description |
|---|---|
| `AttendanceStatus` | Lookup — PRESENT, ABSENT, LEAVE, HOLIDAY, WEEKLY_OFF, etc. |
PRINT 'Inserting AttendanceStatus...';
INSERT INTO attendance.AttendanceStatus (Id, StatusCode, StatusName, IsPresent, IsAbsent, IsPaid, CountsAsWorkingDay, DisplayOrder, IsSystemStatus) VALUES
(NEWID(), 'PRESENT',         'Present',                              1, 0, 1, 1, 1, 1),
(NEWID(), 'ABSENT',          'Absent',                               0, 1, 0, 0, 2, 1),
(NEWID(), 'ON_LEAVE',        'On Approved Leave',                    0, 0, 1, 0, 3, 1),
(NEWID(), 'WORK_FROM_HOME',  'Work From Home',                       1, 0, 1, 1, 4, 1),
(NEWID(), 'HALF_DAY',        'Half Day Present',                     1, 0, 1, 1, 5, 1),
(NEWID(), 'LATE',            'Late Arrival',                         1, 0, 1, 1, 6, 1),
(NEWID(), 'HOLIDAY',         'Public Holiday',                       0, 0, 1, 0, 7, 1),
(NEWID(), 'WEEKEND',         'Weekend / Off Day',                    0, 0, 0, 0, 8, 1),
(NEWID(), 'ON_DUTY',         'On Official Duty',                     1, 0, 1, 1, 9, 1),
(NEWID(), 'COMP_OFF',        'Compensatory Off',                     0, 0, 1, 0, 10, 1),
(NEWID(), 'REGULARIZED',     'Attendance Regularized',               1, 0, 1, 1, 11, 1);

| `Shift` | Shift definitions with timings, grace, overtime rules |
| `ShiftAssignment` | Assigns shifts to scopes (Dept/Office/Employee) with effective dates |
| `EmployeeShiftRoster` | Daily roster per employee: shift, off-day, holiday, planned/actual times |
| `WorkSession` | Raw check-in/check-out sessions linked to roster |
| `AttendanceRecord` | Processed daily attendance: status, worked minutes, overtime, leave flags |
| `AttendanceLog` | Raw biometric device punches |
| `MobileAttendanceLog` | GPS mobile punches with geofence validation |
| `LeaveType` | Leave type master: ANNUAL, SICK, EMERGENCY, COMP_OFF, etc. |
INSERT INTO attendance.LeaveType (Id, LeaveCode, LeaveName, IsPaid, MaxDaysPerYear, AllowCarryForward, RequiresApproval, AllowHalfDay) VALUES
(NEWID(), 'CL',      'Casual Leave',                         1, 12.00, 0, 1, 1),
(NEWID(), 'SL',      'Sick Leave',                           1, 12.00, 0, 1, 1),
(NEWID(), 'EL',      'Earned Leave / Privilege Leave',       1, 18.00, 1, 1, 1),
(NEWID(), 'ML',      'Maternity Leave',                      1, 182.00,0, 1, 0),
(NEWID(), 'PL',      'Paternity Leave',                      1, 15.00, 0, 1, 0),
(NEWID(), 'OL',      'Optional / Restricted Holiday Leave',  0, 2.00,  0, 1, 1),
(NEWID(), 'LWP',     'Leave Without Pay',                    0, NULL,  0, 1, 0),
(NEWID(), 'COMPOFF', 'Compensatory Off Leave',               1, NULL,  0, 1, 1),
(NEWID(), 'BL',      'Bereavement Leave',                    1, 5.00,  0, 1, 0),
(NEWID(), 'STUDYLEAVE','Study / Exam Leave',                 1, 5.00,  0, 1, 0);

| `LeaveRequest` | Employee leave requests with workflow integration |
| `LeaveBalance` | Per-employee, per-type, per-year balance tracking |
| `CompOffType` | Comp-off type master with expiry rules |
| `CompOffBalance` | Earned comp-off days per employee with expiry |
| `AttendanceRegularization` | Request to correct missed/wrong attendance entries |
| `RotationShift` | Rotation shift cycle master |
| `RotationShiftDetail` | Day-by-day shift sequence within a rotation cycle |
| `RotationShiftAssignment` | Assigns rotation shift to scopes |
| `HolidayCalendar` | Holiday calendar master |
| `HolidayType` | Holiday type: NATIONAL, REGIONAL, OPTIONAL, RESTRICTED |
| `Holiday` | Individual holiday entries per calendar |
| `HolidayCalendarAssignment` | Assigns calendars to scopes (GLOBAL/COUNTRY/DEPT/etc.) |
| `WorkWeekPolicy` | Working days configuration (Mon-Fri, Sun-Thu, etc.) |
| `WorkWeekPolicyDay` | Per-day config within a policy |
| `WorkWeekPolicyAssignment` | Assigns work week policy to scopes |
| `ShiftSwapRequest` | Swap shift request between two employees |
| `EmployeeRosterGenerationTracker` | Tracks roster generation status per employee/month |
| `OutboxMessages` | RabbitMQ outbox for this service |

### Key Column Details

**LeaveRequest:**
- `WorkflowInstanceId UNIQUEIDENTIFIER NULL` — FK to `workflow.WorkflowInstance`
- `LeaveStatus NVARCHAR(50)` + computed `LeaveStatusGroup` → FK to `shared.StatusLookup`
- Status values: `PENDING`, `IN_PROGRESS`, `APPROVED`, `REJECTED`, `WITHDRAWN`, `CANCELLED`

**AttendanceRegularization:**
- `WorkflowInstanceId UNIQUEIDENTIFIER NULL` — FK to `workflow.WorkflowInstance`
- `RegularizationStatus` + computed `RegularizationStatusGroup` → FK to `shared.StatusLookup`
- Status values: `PENDING`, `IN_PROGRESS`, `APPROVED`, `REJECTED`, `WITHDRAWN`

**ShiftSwapRequest:**
- `WorkflowInstanceId UNIQUEIDENTIFIER NULL` — FK to `workflow.WorkflowInstance`
- `ShiftSwapStatus` + computed `ShiftSwapStatusGroup` → FK to `shared.StatusLookup`

**CompOffBalance:**
- `WorkflowInstanceId UNIQUEIDENTIFIER NULL` — FK to `workflow.WorkflowInstance`

**ShiftAssignment / WorkWeekPolicyAssignment / HolidayCalendarAssignment / RotationShiftAssignment:**
- `ScopeTypeId UNIQUEIDENTIFIER` FK to `time.ScopeType` (GLOBAL=1, COUNTRY=2, LEGAL_ENTITY=3, OFFICE=4, DEPARTMENT=5, TEAM=6, EMPLOYEE=7)
- `ScopeReferenceId UNIQUEIDENTIFIER NULL` — the actual entity ID for the scope

---

## Status Code Constants

```csharp
public static class LeaveStatus
{
    public const string Pending    = "PENDING";
    public const string InProgress = "IN_PROGRESS";
    public const string Approved   = "APPROVED";
    public const string Rejected   = "REJECTED";
    public const string Cancelled  = "CANCELLED";
    public const string Withdrawn  = "WITHDRAWN";
}

public static class RegularizationStatus
{
    public const string Pending    = "PENDING";
    public const string InProgress = "IN_PROGRESS";
    public const string Approved   = "APPROVED";
    public const string Rejected   = "REJECTED";
    public const string Withdrawn  = "WITHDRAWN";
}

public static class ShiftSwapStatus
{
    public const string Pending    = "PENDING";
    public const string InProgress = "IN_PROGRESS";
    public const string Approved   = "APPROVED";
    public const string Rejected   = "REJECTED";
    public const string Cancelled  = "CANCELLED";
}

public static class WorkflowModuleCodes
{
    public const string Leave                    = "LEAVE_REQUEST";
    public const string AttendanceRegularization = "ATTENDANCE_REGULARIZATION";
    public const string ShiftSwap                = "SHIFT_SWAP_REQUEST";
    public const string CompOff                  = "COMP_OFF_REDEMPTION";
}

public static class RosterGenerationType
{
    public const string Shift       = "SHIFT";
    public const string Rotation    = "ROTATION";
    public const string Manual      = "MANUAL";
}
```

---

## Domain Entities

Generate one C# class per entity. All extend `BaseAuditEntity<Guid>`. Entities that should publish change events implement `IPublishableEntity`.

### Entities implementing `IPublishableEntity`
- `LeaveType`
- `Shift`
- `HolidayCalendar`
- `Holiday`
- `WorkWeekPolicy`

### Entity Relationships

```
LeaveRequest       → LeaveType (FK LeaveTypeId)
LeaveRequest       → WorkflowInstance (FK WorkflowInstanceId, nullable)
LeaveBalance       → Employee (FK EmployeeId), LeaveType (FK LeaveTypeId)
AttendanceRecord   → Employee, EmployeeShiftRoster, WorkSession, Shift, AttendanceStatus
EmployeeShiftRoster → Employee, Shift
WorkSession        → Employee, EmployeeShiftRoster
AttendanceLog      → Employee
MobileAttendanceLog → Employee, GeoFence (time schema)
AttendanceRegularization → Employee, WorkflowInstance (nullable)
ShiftSwapRequest   → Employee (Requester), Employee (Target), EmployeeShiftRoster (×2), WorkflowInstance (nullable)
CompOffBalance     → Employee, CompOffType, AttendanceRecord (nullable), WorkflowInstance (nullable)
RotationShiftDetail → RotationShift, Shift
Holiday            → HolidayCalendar, HolidayType
WorkWeekPolicyDay  → WorkWeekPolicy
EmployeeRosterGenerationTracker → Employee
```

---

## Application Services

### ILeaveService
```csharp
Task<PagedResponse<IEnumerable<LeaveRequestResponse>>> GetAllAsync(PaginationFilter filter, Guid? employeeId, string? status, CancellationToken ct);
Task<LeaveRequestResponse?> GetByIdAsync(Guid id, CancellationToken ct);
Task<IEnumerable<LeaveBalanceResponse>> GetBalanceAsync(Guid employeeId, int year, CancellationToken ct);
Task<LeaveRequestResponse> SubmitAsync(CreateLeaveRequestRequest request, CancellationToken ct);
Task<bool> CancelAsync(Guid id, CancellationToken ct);
Task<bool> WithdrawAsync(Guid id, CancellationToken ct);
Task<LeaveRequestResponse?> GetByWorkflowInstanceAsync(Guid workflowInstanceId, CancellationToken ct);
Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, CancellationToken ct);
```

### IShiftService
```csharp
Task<PagedResponse<IEnumerable<ShiftResponse>>> GetAllAsync(PaginationFilter filter, CancellationToken ct);
Task<ShiftResponse?> GetByIdAsync(Guid id, CancellationToken ct);
Task<ShiftResponse> CreateAsync(CreateShiftRequest request, CancellationToken ct);
Task<bool> UpdateAsync(Guid id, UpdateShiftRequest request, CancellationToken ct);
Task<bool> ToggleStatusAsync(Guid id, CancellationToken ct);
Task<ShiftResponse?> ResolveForEmployeeAsync(Guid employeeId, DateOnly date, CancellationToken ct);
```

### IRosterService
```csharp
Task<IEnumerable<RosterResponse>> GetByEmployeeAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken ct);
Task<RosterResponse?> GetByDateAsync(Guid employeeId, DateOnly date, CancellationToken ct);
Task GenerateAsync(GenerateRosterRequest request, CancellationToken ct);
Task<bool> LockAsync(Guid id, CancellationToken ct);
Task<bool> UnlockAsync(Guid id, CancellationToken ct);
Task<bool> UpdateAsync(Guid id, UpdateRosterRequest request, CancellationToken ct);
```

### IAttendanceService
```csharp
Task<PagedResponse<IEnumerable<AttendanceRecordResponse>>> GetAllAsync(PaginationFilter filter, Guid? employeeId, DateOnly? from, DateOnly? to, CancellationToken ct);
Task<AttendanceRecordResponse?> GetByIdAsync(Guid id, CancellationToken ct);
Task<AttendanceRecordResponse?> GetByEmployeeDateAsync(Guid employeeId, DateOnly date, CancellationToken ct);
Task CheckInAsync(CheckInRequest request, CancellationToken ct);
Task CheckOutAsync(CheckOutRequest request, CancellationToken ct);
Task ProcessDailyAsync(DateOnly date, CancellationToken ct);
Task RegularizeAsync(CreateRegularizationRequest request, CancellationToken ct);
Task UpdateRegularizationStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, CancellationToken ct);
```

### IHolidayService
```csharp
Task<IEnumerable<HolidayResponse>> GetByCalendarAsync(Guid calendarId, int year, CancellationToken ct);
Task<IEnumerable<HolidayResponse>> GetApplicableAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken ct);
Task<HolidayResponse> CreateAsync(CreateHolidayRequest request, CancellationToken ct);
Task<bool> UpdateAsync(Guid id, UpdateHolidayRequest request, CancellationToken ct);
Task<bool> ToggleStatusAsync(Guid id, CancellationToken ct);
Task<HolidayCalendarResponse?> ResolveCalendarForEmployeeAsync(Guid employeeId, CancellationToken ct);
```

### IShiftSwapService
```csharp
Task<ShiftSwapResponse> RequestSwapAsync(CreateShiftSwapRequest request, CancellationToken ct);
Task<bool> CancelAsync(Guid id, CancellationToken ct);
Task<ShiftSwapResponse?> GetByIdAsync(Guid id, CancellationToken ct);
Task<IEnumerable<ShiftSwapResponse>> GetMyRequestsAsync(Guid employeeId, CancellationToken ct);
Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, CancellationToken ct);
```

### ICompOffService
```csharp
Task<IEnumerable<CompOffBalanceResponse>> GetBalanceAsync(Guid employeeId, CancellationToken ct);
Task<CompOffBalanceResponse> EarnAsync(EarnCompOffRequest request, CancellationToken ct);
Task RedeemAsync(RedeemCompOffRequest request, CancellationToken ct);
Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, CancellationToken ct);
```

---

## Workflow Integration

### Modules That Use Workflow

| Module | WorkflowModuleCode | Entity | Status Field |
|---|---|---|---|
| Leave Request | `LEAVE_REQUEST` | `LeaveRequest` | `LeaveStatus` |
| Attendance Regularization | `ATTENDANCE_REGULARIZATION` | `AttendanceRegularization` | `RegularizationStatus` |
| Shift Swap | `SHIFT_SWAP_REQUEST` | `ShiftSwapRequest` | `ShiftSwapStatus` |
| Comp-Off Redemption | `COMP_OFF_REDEMPTION` | `CompOffBalance` | (tracked via WorkflowInstanceId) |

### Submission Flow (Attendance → Workflow)

When an employee submits a leave/regularization/swap/comp-off, the Attendance service publishes a domain event to RabbitMQ via the outbox pattern. The Workflow service consumes this and initiates a `WorkflowInstance`.

**Step 1: Custom Outbox Interceptor**

```csharp
// SdxCore.Attendance.Persistence.Interceptors.AttendanceWorkflowOutboxInterceptor
// Extends SaveChangesInterceptor
// Watches for newly ADDED: LeaveRequest, AttendanceRegularization, ShiftSwapRequest, CompOffBalance
// For each new entity, writes a LeaveRequestSubmittedEvent (or equivalent) to attendance.OutboxMessages
// Does NOT call SaveChangesAsync — caller owns the commit
```

**Step 2: Events to Publish**

```csharp
// In SdxCore.SharedKernel.Events:

public record LeaveRequestSubmittedEvent(
    Guid     LeaveRequestId,
    Guid     EmployeeId,
    string   LeaveTypeCode,    // e.g. "ANNUAL", "SICK"
    string   WorkflowCode,     // e.g. "STANDARD_LEAVE_V1" — maps leave type to workflow
    string   ModuleCode,       // "LEAVE_REQUEST"
    DateOnly FromDate,
    DateOnly ToDate,
    string?  Reason,
    DateTime OccurredOnUtc);

public record AttendanceRegularizationSubmittedEvent(
    Guid     RegularizationId,
    Guid     EmployeeId,
    string   WorkflowCode,     // "ATTENDANCE_REGULARIZATION_V1"
    string   ModuleCode,       // "ATTENDANCE_REGULARIZATION"
    DateOnly AttendanceDate,
    string?  Reason,
    DateTime OccurredOnUtc);

public record ShiftSwapRequestSubmittedEvent(
    Guid     ShiftSwapRequestId,
    Guid     RequesterEmployeeId,
    Guid     TargetEmployeeId,
    string   WorkflowCode,     // "SHIFT_SWAP_V1"
    string   ModuleCode,       // "SHIFT_SWAP_REQUEST"
    DateOnly SwapDate,
    DateTime OccurredOnUtc);

public record CompOffRedemptionSubmittedEvent(
    Guid     CompOffBalanceId,
    Guid     EmployeeId,
    string   WorkflowCode,     // "COMP_OFF_REDEMPTION_V1"
    string   ModuleCode,       // "COMP_OFF_REDEMPTION"
    decimal  RequestedDays,
    DateTime OccurredOnUtc);
```

**Step 3: WorkflowCode Mapping**

The `WorkflowCode` determines which workflow definition to use within the module. Store this on `LeaveType.WorkflowCode` so it's data-driven:

```csharp
// LeaveType entity
public string? WorkflowCode { get; set; }   // "STANDARD_LEAVE_V1", "EMERGENCY_LEAVE_V1"

// In LeaveService.SubmitAsync — derive WorkflowCode from LeaveType
string workflowCode = leaveType.WorkflowCode ?? "STANDARD_LEAVE_V1";
```

**Step 4: Back-channel — Workflow → Attendance**

The Workflow service publishes `WorkflowInstanceStatusChangedEvent` when status changes. The Attendance service consumes this and updates the relevant entity.

```csharp
// In SdxCore.SharedKernel.Events:
public record WorkflowInstanceStatusChangedEvent(
    Guid     WorkflowInstanceId,
    string   ModuleCode,              // "LEAVE_REQUEST"
    Guid     ReferenceTransactionId,  // LeaveRequestId / RegularizationId / etc.
    string   NewStatus,               // "APPROVED", "REJECTED", etc.
    string   EventType,               // "status_changed", "returned", "delegated"
    Guid     ActionBy,
    string?  Remarks,
    DateTime CreatedAt);
```

### Consumer: `WorkflowInstanceStatusChangedConsumer`

```csharp
// SdxCore.Attendance.Application.Consumers.WorkflowInstanceStatusChangedConsumer
// IConsumer<WorkflowInstanceStatusChangedEvent>
// Routes by ModuleCode to the correct service:

public async Task Consume(ConsumeContext<WorkflowInstanceStatusChangedEvent> context)
{
    var evt = context.Message;

    // Skip delegated — no entity status change needed
    if (evt.EventType == "delegated") return;

    switch (evt.ModuleCode)
    {
        case "LEAVE_REQUEST":
            await leaveService.UpdateStatusFromWorkflowAsync(
                evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, ct);
            break;

        case "ATTENDANCE_REGULARIZATION":
            await attendanceService.UpdateRegularizationStatusFromWorkflowAsync(
                evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, ct);
            break;

        case "SHIFT_SWAP_REQUEST":
            await shiftSwapService.UpdateStatusFromWorkflowAsync(
                evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, ct);
            // If APPROVED: execute the actual shift swap on EmployeeShiftRoster
            if (evt.NewStatus == "APPROVED")
                await rosterService.ExecuteShiftSwapAsync(evt.WorkflowInstanceId, ct);
            break;

        case "COMP_OFF_REDEMPTION":
            await compOffService.UpdateStatusFromWorkflowAsync(
                evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, ct);
            break;
    }
}
```

---

## RabbitMQ Messaging

### Events Published by Attendance

| Event | Routing Key | Consumed By |
|---|---|---|
| `LeaveRequestSubmittedEvent` | `sdxcore.events.leaverequest.submitted` | Workflow |
| `AttendanceRegularizationSubmittedEvent` | `sdxcore.events.regularization.submitted` | Workflow |
| `ShiftSwapRequestSubmittedEvent` | `sdxcore.events.shiftswap.submitted` | Workflow |
| `CompOffRedemptionSubmittedEvent` | `sdxcore.events.compoff.submitted` | Workflow |
| `EntityChangedEvent` (via `OutboxSaveChangesInterceptor`) | `sdxcore.events.{entityname}.lower` | Other services (cache invalidation) |

### Events Consumed by Attendance

| Event | Queue Name | Published By |
|---|---|---|
| `WorkflowInstanceStatusChangedEvent` | `attendance.workflow.status-changed` | Workflow |

### Messaging Registration

```csharp
// SdxCore.Attendance.Application.Extensions.ServiceCollectionExtensions

public static IServiceCollection AddSdxCoreAttendanceMessaging(
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
```

`AddSdxMessaging` automatically registers `OutboxProcessorBackgroundService` — no separate `AddHostedService` call needed.

---

## API Controllers

All controllers:
- Inherit `SdxControllerBase`
- Decorated with `[GatewayOnly]`
- Route prefix: `api/v1/`
- Use `IRequestContext` to extract `UserId` (Guid) from `X-User-Id` header

### Endpoints

#### Leave Controller — `api/v1/leaves`
```
GET    /                          GetAll (filter, employeeId?, status?)
GET    /{id}                      GetById
GET    /employee/{employeeId}     GetByEmployee
GET    /employee/{employeeId}/balance?year=  GetBalance
POST   /                          Submit leave request
PATCH  /{id}/cancel               Cancel
PATCH  /{id}/withdraw             Withdraw
GET    /workflow/{instanceId}     GetByWorkflowInstance
```

#### Attendance Controller — `api/v1/attendance`
```
GET    /                          GetAll (filter, employeeId?, from?, to?)
GET    /{id}                      GetById
GET    /employee/{employeeId}/date/{date}  GetByEmployeeDate
POST   /check-in                  CheckIn
POST   /check-out                 CheckOut
POST   /process-daily             ProcessDaily (admin)
```

#### Regularization Controller — `api/v1/attendance/regularizations`
```
GET    /                          GetAll (filter, employeeId?)
GET    /{id}                      GetById
POST   /                          Submit regularization request
PATCH  /{id}/withdraw             Withdraw
GET    /workflow/{instanceId}     GetByWorkflowInstance
```

#### Shift Controller — `api/v1/shifts`
```
GET    /                          GetAll (paginated)
GET    /{id}                      GetById
GET    /resolve?employeeId=&date= ResolveForEmployee
POST   /                          Create
PUT    /{id}                      Update
PATCH  /{id}/status               ToggleStatus
```

#### Roster Controller — `api/v1/rosters`
```
GET    /employee/{employeeId}?from=&to=    GetByEmployee
GET    /employee/{employeeId}/date/{date}  GetByDate
POST   /generate                  GenerateRoster
PATCH  /{id}/lock                 Lock
PATCH  /{id}/unlock               Unlock
PUT    /{id}                      Update
```

#### Shift Swap Controller — `api/v1/shift-swaps`
```
GET    /                          GetMyRequests
GET    /{id}                      GetById
POST   /                          RequestSwap
PATCH  /{id}/cancel               Cancel
```

#### Holiday Controller — `api/v1/holidays`
```
GET    /calendars                 GetAllCalendars
GET    /calendars/{id}            GetCalendar
POST   /calendars                 CreateCalendar
GET    /calendars/{id}/holidays   GetHolidaysByCalendar
POST   /calendars/{id}/holidays   CreateHoliday
PUT    /holidays/{id}             UpdateHoliday
PATCH  /holidays/{id}/status      ToggleStatus
GET    /applicable?employeeId=&from=&to=  GetApplicableHolidays
```

#### CompOff Controller — `api/v1/comp-offs`
```
GET    /employee/{employeeId}     GetBalance
POST   /earn                      EarnCompOff
POST   /redeem                    RedeemCompOff
```

---

## Persistence Layer

### AttendanceDbContext

```csharp
// Extends SdxDbContext
// Schema: attendance
// Registers all DbSets
// Configures:
//   - Computed column: LeaveStatusGroup AS CAST('LEAVE_STATUS' AS NVARCHAR(50)) PERSISTED
//   - Computed column: RegularizationStatusGroup AS CAST('ATTENDANCE_REGULARIZATION_STATUS' AS NVARCHAR(50)) PERSISTED
//   - Computed column: ShiftSwapStatusGroup AS CAST('SHIFT_SWAP_STATUS' AS NVARCHAR(50)) PERSISTED
//   - Computed column: GenerationTypeGroup AS CAST('ROSTER_GENERATION_TYPE' AS NVARCHAR(50)) PERSISTED
//   - All computed columns: .HasComputedColumnSql("...", stored: true) — EF never writes these
//   - OutboxMessages table: ToTable("OutboxMessages", "attendance")
//   - Interceptors: OutboxSaveChangesInterceptor + AttendanceWorkflowOutboxInterceptor
//   - Keyless view entity: EmployeeShiftRosterSummary → vwEmployeeShiftRoster (if view exists)
```

### Repositories

Generate one repository per entity following the pattern:

```csharp
// Interface in Domain/Interfaces/
public interface ILeaveRequestRepository
{
    Task<LeaveRequest?> GetByIdAsync(Guid id, CancellationToken ct);
    Task<(IEnumerable<LeaveRequest> Items, int TotalCount)> GetPagedAsync(int page, int pageSize, Guid? employeeId, string? status, CancellationToken ct);
    Task<LeaveRequest?> GetByWorkflowInstanceIdAsync(Guid workflowInstanceId, CancellationToken ct);
    Task<IEnumerable<LeaveRequest>> GetByEmployeeAsync(Guid employeeId, CancellationToken ct);
    Task<LeaveRequest> AddAsync(LeaveRequest entity, CancellationToken ct);
    void Update(LeaveRequest entity);
    Task<int> SaveChangesAsync(CancellationToken ct);
}

// Implementation extends BaseRepository<LeaveRequest, Guid, AttendanceDbContext>
```

### Outbox Repository

```csharp
// SdxCore.Attendance.Persistence.Repositories.OutboxRepository
// Extends OutboxRepository<AttendanceDbContext>
// Implements IOutboxRepository
```

---

## External Service Calls

### Employee Service

Called via HTTP client (`HttpClient` named `"employee"`):

| Purpose | Endpoint | When Used |
|---|---|---|
| Get employee summary (org data) | `GET /api/v1/employees/{id}/summary` | Shift/Holiday resolution, Roster generation |
| Get employees by designation in scope | `GET /api/v1/employees/by-designation?designationIds=&scopeTypeId=&scopeReferenceId=` | Workflow approver resolution |

```csharp
// SdxCore.Attendance.Application.Services.EmployeeHttpClient
public interface IEmployeeHttpClient
{
    Task<EmployeeSummaryResponse?> GetSummaryAsync(Guid employeeId, CancellationToken ct);
    Task<IEnumerable<EmployeesByDesignationResponse>> GetByDesignationInScopeAsync(List<short> designationIds, short? scopeTypeId, int? scopeReferenceId, CancellationToken ct);
}
```

### Time Service

Called via HTTP client (`HttpClient` named `"time"`):

| Purpose | Endpoint | When Used |
|---|---|---|
| Get scope types | `GET /api/v1/scope-types` | Shift/Holiday/WorkWeek resolution |
| Get designations | `GET /api/v1/designations` | Approver resolution |

---

## Scope Resolution Pattern

Used for resolving shift, holiday calendar, and work week policy for an employee. Same hierarchy as Workflow service:

```
EMPLOYEE (7) → TEAM (6) → DEPARTMENT (5) → OFFICE (4) → LEGAL_ENTITY (3) → COUNTRY (2) → GLOBAL (1)
```

Walk from most specific to most general; return first match by `PriorityOrder`.

```csharp
// SdxCore.Attendance.Application.Services.ScopeResolutionService
public interface IScopeResolutionService
{
    Task<Shift?> ResolveShiftAsync(EmployeeSummaryResponse employee, DateOnly date, CancellationToken ct);
    Task<HolidayCalendar?> ResolveHolidayCalendarAsync(EmployeeSummaryResponse employee, CancellationToken ct);
    Task<WorkWeekPolicy?> ResolveWorkWeekPolicyAsync(EmployeeSummaryResponse employee, DateOnly date, CancellationToken ct);
}
```

---

## Roster Generation Logic

The `GenerateRosterAsync` method creates `EmployeeShiftRoster` records for a date range:

```
For each employee in scope, for each date in range:
  1. Check EmployeeRosterGenerationTracker — skip if already locked
  2. Determine if date is a holiday → IsHoliday = true, ShiftId = null
  3. Determine if date is a weekly off (from WorkWeekPolicy) → IsOffDay = true, ShiftId = null
  4. Resolve applicable Shift via ShiftAssignment scope hierarchy
     OR check RotationShiftAssignment → derive shift from rotation cycle day
  5. Create/Update EmployeeShiftRoster record
  6. Update EmployeeRosterGenerationTracker
```

Generation types: `SHIFT` (standard), `ROTATION` (rotation-based), `MANUAL` (individual override).

---

## Attendance Processing Logic

`ProcessDailyAsync(DateOnly date)` runs as a background job:

```
For each employee with a roster on the given date:
  1. Get EmployeeShiftRoster → get ShiftId, PlannedStartTime, IsOffDay, IsHoliday
  2. Get WorkSession records for that day (CheckIn/CheckOut)
  3. Calculate WorkedMinutes, LateByMinutes, EarlyExitMinutes, OvertimeMinutes
  4. Determine AttendanceStatus:
     - No check-in + working day → ABSENT
     - On approved leave → LEAVE
     - Weekly off → WEEKLY_OFF
     - Holiday → HOLIDAY
     - Check-in exists → PRESENT (or LATE_ARRIVAL based on grace)
  5. Upsert AttendanceRecord
```

---

## DI Registration

### Program.cs

```csharp
// DbContext
builder.Services.AddDbContext<AttendanceDbContext>((sp, options) =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("AttendanceDb"),
        sql => sql.EnableRetryOnFailure(3));
    options.AddInterceptors(
        sp.GetRequiredService<OutboxSaveChangesInterceptor>(),
        sp.GetRequiredService<AttendanceWorkflowOutboxInterceptor>());
});

// Repositories
builder.Services.AddScoped<ILeaveRequestRepository, LeaveRequestRepository>();
builder.Services.AddScoped<IAttendanceRecordRepository, AttendanceRecordRepository>();
builder.Services.AddScoped<IShiftRepository, ShiftRepository>();
builder.Services.AddScoped<IRosterRepository, RosterRepository>();
builder.Services.AddScoped<IHolidayRepository, HolidayRepository>();
builder.Services.AddScoped<IShiftSwapRepository, ShiftSwapRepository>();
builder.Services.AddScoped<ICompOffRepository, CompOffRepository>();
builder.Services.AddScoped<IOutboxRepository, OutboxRepository>();

// Interceptors (singleton — no scoped dependencies)
builder.Services.AddSingleton<OutboxSaveChangesInterceptor>();
builder.Services.AddSingleton<AttendanceWorkflowOutboxInterceptor>();

// Application services
builder.Services.AddScoped<ILeaveService, LeaveService>();
builder.Services.AddScoped<IAttendanceService, AttendanceService>();
builder.Services.AddScoped<IShiftService, ShiftService>();
builder.Services.AddScoped<IRosterService, RosterService>();
builder.Services.AddScoped<IHolidayService, HolidayService>();
builder.Services.AddScoped<IShiftSwapService, ShiftSwapService>();
builder.Services.AddScoped<ICompOffService, CompOffService>();
builder.Services.AddScoped<IScopeResolutionService, ScopeResolutionService>();

// HTTP clients
builder.Services.AddHttpClient<IEmployeeHttpClient, EmployeeHttpClient>(c =>
    c.BaseAddress = new Uri(builder.Configuration["ServiceUrls:Employee"]!));
builder.Services.AddHttpClient<ITimeHttpClient, TimeHttpClient>(c =>
    c.BaseAddress = new Uri(builder.Configuration["ServiceUrls:Time"]!));

// Caching
builder.Services.AddScoped<ICacheService, RedisCacheService>();
builder.Services.AddScoped<ICacheKeyBuilder, CacheKeyBuilder>();

// Messaging (includes OutboxProcessorBackgroundService)
builder.Services.AddSdxCoreAttendanceMessaging(builder.Configuration);

// Middleware
app.UseMiddleware<AttendanceExceptionMiddleware>();
app.MapControllers();
```

---

## appsettings.json

```json
{
  "ServiceName": "attendance",
  "ConnectionStrings": {
    "AttendanceDb": "Server=.;Database=SdxCoreDb;Trusted_Connection=True;"
  },
  "ServiceUrls": {
    "Employee": "http://employee-service",
    "Time":     "http://time-service",
    "Workflow": "http://workflow-service"
  },
  "RabbitMq": {
    "Host":     "localhost",
    "Username": "guest",
    "Password": "guest"
  },
  "Redis": {
    "ConnectionString": "localhost:6379"
  },
  "OutboxSettings": {
    "BatchSize":             50,
    "MaxRetries":            3,
    "PollingIntervalSeconds": 5
  },
  "Gateway": {
    "InternalApiKey": "your-internal-key"
  }
}
```

---

## Code Generation Rules

Follow these rules exactly when generating code:

1. **One class per file** — never put multiple classes in one `.cs` file.
2. **Primary constructors** — use C# 12 primary constructors where practical.
3. **No magic strings** — use constants from the status classes above.
4. **No SaveChangesAsync in repositories** — repositories only call `AddAsync` / `Update` / `Remove`. Unit of work (`SaveChangesAsync`) is called in Application services.
5. **Single SaveChangesAsync per service method** — stage all changes, then one commit at the end.
6. **Outbox interceptor does NOT call SaveChangesAsync** — it stages outbox messages; the service owns the single commit.
7. **Computed columns in EF**: `.HasComputedColumnSql("...", stored: true)` — never write to these.
8. **All controllers use `[GatewayOnly]`** and inherit `SdxControllerBase`.
9. **All IDs are `Guid`** — never `int` or `short` for attendance entities.
10. **Caching**: Use `ICacheService.GetOrSetAsync` for all read operations in Application services. Cache keys via `ICacheKeyBuilder.BuildKey(entityName, id)`.
11. **Exception middleware** — catch domain exceptions and return structured `ApiResponse<T>`.
12. **Never reference Workflow DbContext directly** — communicate only via RabbitMQ events.
13. **Never reference Employee/Time DbContext directly** — communicate only via HTTP clients.
14. **WorkflowInstanceId is nullable** — not all leave types require approval (`LeaveType.RequiresApproval`).

---

## Integration Summary Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    SdxCore.Attendance                           │
│                                                                 │
│  LeaveService.SubmitAsync()                                     │
│    → AttendanceWorkflowOutboxInterceptor                        │
│    → attendance.OutboxMessages (LeaveRequestSubmittedEvent)     │
│    → OutboxProcessorBackgroundService                           │
│    → RabbitMQ ──────────────────────────────────────────────►  │
│                                                                 │
│  WorkflowInstanceStatusChangedConsumer                          │
│  ◄──────────────────────────────────────────  RabbitMQ          │
│    → LeaveService.UpdateStatusFromWorkflowAsync()               │
│    → LeaveRequest.LeaveStatus = "APPROVED"                      │
│    → AttendanceDbContext.SaveChangesAsync()                     │
└─────────────────────────────────────────────────────────────────┘
         │ HTTP                              │ HTTP
         ▼                                  ▼
┌──────────────────┐              ┌──────────────────────┐
│ Employee Service │              │    Time Service       │
│                  │              │                      │
│ GET /summary     │              │ GET /scope-types     │
│ GET /by-desig.   │              │ GET /designations    │
└──────────────────┘              └──────────────────────┘

         │ RabbitMQ Events
         ▼
┌──────────────────────────────────────────────────────────────────┐
│                    SdxCore.Workflow                              │
│                                                                  │
│  LeaveRequestSubmittedConsumer                                   │
│    → ResolveWorkflowDefinitionAsync(moduleCode, workflowCode,    │
│                                     employeeSummary, scopeTypes) │
│    → WorkflowEngine.SubmitAsync()                                │
│    → Creates WorkflowInstance + WorkflowTasks                    │
│    → workflow.OutboxMessages (WorkflowInstanceStatusChangedEvent)│
│    → OutboxProcessorBackgroundService → RabbitMQ → Attendance   │
└──────────────────────────────────────────────────────────────────┘
```