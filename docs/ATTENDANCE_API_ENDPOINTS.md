# SdxCore.Attendance — API Endpoints Reference
## MedCare India Pvt. Ltd.

---

## Table of Contents

1. [Schema Overview](#schema-overview)
2. [Architecture & Processing Model](#architecture--processing-model)
3. [Shift & Rotation Design](#shift--rotation-design)
4. [Roster Generation Strategy](#roster-generation-strategy)
5. [WorkSession Concept](#worksession-concept)
6. [Background Processors](#background-processors)
7. [Workflow Integration](#workflow-integration)
8. [API Endpoints](#api-endpoints)
9. [Microservice Integration Architecture](#microservice-integration-architecture)
10. [Docker Compose & Configuration](#docker-compose--configuration)
11. [Endpoint Count Summary](#endpoint-count-summary)
12. [Dependency Seeding Order](#dependency-seeding-order)

---

## Schema Overview

**Schema:** `attendance`
**Service:** `SdxCore.Attendance.API`
**Port:** `http://localhost:5007`
**Gateway Route Prefix:** `/api/v1/attendance/**`
**Purpose:** Leave management, attendance recording, shift scheduling, roster management, holiday calendars, comp-off, attendance regularization, work sessions, and scheduled background processors.

**Cross-schema Dependencies:**

| Dependency | Schema | Used By |
|------------|--------|---------|
| `Employee` | `employee` | All attendance records, leave requests, rosters |
| `StatusLookup` | `shared` | LeaveStatus, ShiftSwapStatus, RegularizationStatus, AttendanceStatus, RosterGenerationType |
| `GeoFence` | `time` | MobileAttendanceLog geo-validation |
| `ScopeType` | `time` | ShiftAssignment, RotationShiftAssignment, HolidayCalendarAssignment, WorkWeekPolicyAssignment |
| `WorkflowInstance` | `workflow` | LeaveRequest, AttendanceRegularization, ShiftSwapRequest, CompOffBalance |

**Gateway Security:** ALL endpoints require `[GatewayOnly]`. Direct external access returns `403 Forbidden`.

**Soft Delete Pattern:** All tables use `IsActive`. No hard deletes. Use `PATCH /{id}/status`.

---

## Architecture & Processing Model

SdxCore Attendance uses a **scheduled batch processing model**, not a purely event-driven one. Attendance is never calculated dynamically on every read request. Instead, dedicated background processors run on fixed schedules, computing and finalizing attendance state from raw data.

```
Raw Punches (Biometric / Mobile)
      │
      ▼
AttendanceLog (raw punch store)
      │
      ▼
[Processor 1] WorkSession Builder
      │ Pairs IN/OUT punches → creates WorkSession rows
      ▼
WorkSession (paired in/out records)
      │
      ▼
[Processor 2] Attendance Finalizer
      │ Runs after: ShiftEnd + AttendanceFinalizeBufferMinutes
      │ Computes: worked minutes, late, overtime, night shift flags
      ▼
AttendanceRecord (final computed record per employee per date)
      │
      ▼
[Processor 3] Reprocessor (on demand)
      │ Triggered by: leave approval, regularization, shift change, holiday declaration
      ▼
AttendanceRecord (updated)
```

**Key principles:**
- Raw punches are stored as-is in `AttendanceLog` — never discarded.
- `WorkSession` handles cross-midnight and night shifts using actual timestamps, not date matching.
- `AttendanceRecord` is the final single row per employee per date — the source of truth for payroll, HR, and reports.
- Attendance is **never recalculated from scratch for an entire month**. Only affected records are reprocessed.
- Leave approved after the fact does **not** remove the roster entry — only the `AttendanceRecord.AttendanceStatus` is updated to `ON_LEAVE`.

---

## Shift & Rotation Design

### Shift Master — Seeded Shifts (MedCare)

All shifts are stored in `attendance.Shift`. No `OFF` shifts exist — off-days are represented in the roster with `ShiftId = NULL` and `IsOffDay = 1`.

| ShiftCode | ShiftName | StartTime | EndTime | CrossesMidnight | IsNightShift | BreakMin | GraceIn | GraceOut | MinWork | MaxWork | FinalizeBuffer |
|-----------|-----------|-----------|---------|-----------------|--------------|----------|---------|---------|---------|---------|----------------|
| `SHF-GEN` | General Shift (9AM–6PM) | 09:00 | 18:00 | No | No | 60 | 15 | 15 | 420 | 540 | 240 |
| `SHF-MORN` | Morning Shift (8AM–2PM) | 08:00 | 14:00 | No | No | 30 | 10 | 10 | 330 | 360 | 240 |
| `SHF-AFT` | Afternoon Shift (2PM–8PM) | 14:00 | 20:00 | No | No | 30 | 10 | 10 | 330 | 360 | 240 |
| `SHF-NIGHT` | Night Shift (8PM–8AM) | 20:00 | 08:00 | **Yes** | **Yes** | 60 | 10 | 10 | 660 | 720 | 240 |
| `SHF-EMER-D` | Emergency Day Shift (8AM–8PM) | 08:00 | 20:00 | No | No | 60 | 10 | 10 | 660 | 720 | 240 |
| `SHF-EMER-N` | Emergency Night Shift (8PM–8AM) | 20:00 | 08:00 | **Yes** | **Yes** | 60 | 10 | 10 | 660 | 720 | 240 |
| `SHF-OPD` | OPD Shift (10AM–5PM) | 10:00 | 17:00 | No | No | 30 | 15 | 15 | 360 | 420 | 240 |
| `SHF-FLEX` | Flexible Shift (10AM–7PM) | 10:00 | 19:00 | No | No | 60 | 30 | 30 | 420 | 540 | 240 |

> **All shifts have `MaxAllowedCheckoutDelayMinutes = 120` and `AllowOvertime = true`.**

**Shift fields relevant to processing:**

| Field | Purpose |
|-------|---------|
| `AttendanceFinalizeBufferMinutes` | Processor waits this many minutes after `EndTime` before finalizing. Default 240 (4 hours). |
| `MaxAllowedCheckoutDelayMinutes` | Maximum delay between shift end and expected checkout. Used to detect missing checkouts. |
| `GraceInMinutes` | Late threshold — employee is not marked late until this grace period passes. |
| `GraceOutMinutes` | Early-exit threshold. |
| `CrossesMidnight` | When true, `WorkSession` spans two calendar dates. Attendance is credited to the session-start date. |

### Department → Shift Assignment Map

| Department | Shift Assigned | Notes |
|-----------|---------------|-------|
| Global (default) | `SHF-GEN` | Admin, Support, Finance |
| HR | `SHF-GEN` | |
| Finance | `SHF-GEN` | |
| Admin | `SHF-GEN` | |
| IT | `SHF-FLEX` | 10AM–7PM flexible |
| Clinical | `SHF-MORN` | Primary shift |
| Cardiology | `SHF-OPD` | OPD hours |
| Oncology | `SHF-OPD` | |
| Neurology | `SHF-OPD` | |
| Pediatrics | `SHF-OPD` | |
| Pharmacy | `SHF-MORN` | |
| Emergency | `SHF-EMER-D` | 12-hour day shift as primary |
| Nursing | `ROT-NURSING-3SHIFT` | Rotation |
| ICU | `ROT-NURSING-3SHIFT` | Rotation |

### Rotation Shifts — Sequence-Based Patterns

Two rotations are seeded for MedCare:

#### ROT-NURSING-3SHIFT — Nursing 3-Shift Rotation (21-day cycle)

| SequenceNo | Shift | DurationDays | IsOffDay | Notes |
|------------|-------|-------------|----------|-------|
| 1 | `SHF-MORN` | 6 | 0 | 6 days morning |
| 2 | NULL | 1 | 1 | 1 day off |
| 3 | `SHF-AFT` | 6 | 0 | 6 days afternoon |
| 4 | NULL | 1 | 1 | 1 day off |
| 5 | `SHF-NIGHT` | 6 | 0 | 6 days night |
| 6 | NULL | 1 | 1 | 1 day off |

`CycleLengthDays = 21`

#### ROT-EMER-12HR — Emergency 12-Hour 2-Shift Rotation (6-day cycle)

| SequenceNo | Shift | DurationDays | IsOffDay | Notes |
|------------|-------|-------------|----------|-------|
| 1 | `SHF-EMER-D` | 2 | 0 | 2 days emergency day |
| 2 | NULL | 1 | 1 | 1 day off |
| 3 | `SHF-EMER-N` | 2 | 0 | 2 days emergency night |
| 4 | NULL | 1 | 1 | 1 day off |

`CycleLengthDays = 6`

### Rotation Offset — Staggering Employees (Nursing)

`RotationOffsetDays` on `RotationShiftAssignment` staggers employees across the same rotation so not all nursing staff land on the same shift or off-day simultaneously.

**Seeded employee offsets (nursing):**

| EmployeeCode | RotationOffsetDays | Effect |
|-------------|-------------------|--------|
| EMP010 (Sr. ICU Nurse) | 0 | Starts at sequence 1 (Morning) |
| EMP011 (Staff Nurse) | 3 | Enters cycle 3 days in (offset into Morning block) |
| EMP012 (Nurse) | 6 | Enters cycle 6 days in (starts at Afternoon) |

**Priority resolution when multiple rotation assignments match:**

```
Employee-specific RotationShiftAssignment  (highest priority)
      ↓ fallback if none
Department-level RotationShiftAssignment
      ↓ fallback if none
Global-level RotationShiftAssignment
```

Employee-level overrides are used for staggering (EMP010, EMP011, EMP012). Remaining nursing staff inherit from department-level assignment.

---

## Roster Generation Strategy

The roster (`attendance.EmployeeShiftRoster`) is the **pre-generated planned schedule** per employee per date. It is computed once and stored — processors read from it rather than recalculating shift assignments dynamically.

### Generation Frequency

| Assignment Type | Recommended Frequency | Reason |
|----------------|----------------------|--------|
| General / Fixed Shifts | Monthly | Stable, predictable |
| Rotation Shifts | Weekly | Cycle-based, frequent validation needed |
| New Joinee / Missing Entries | Daily incremental | Fill gaps without regenerating full month |

### Roster Entry Rules

| Scenario | ShiftId | IsOffDay | IsHoliday | Notes |
|----------|---------|----------|-----------|-------|
| Working day | set | 0 | 0 | Normal shift |
| Weekly off | NULL | 1 | 0 | No fake OFF shift |
| Public holiday | NULL | 0 | 1 | Holiday from calendar |
| Holiday + weekly off | NULL | 1 | 1 | Both flags set |
| Leave approved | (unchanged) | (unchanged) | (unchanged) | Roster not modified; `AttendanceRecord.AttendanceStatus = ON_LEAVE` |

**Sample seeded roster entries (April 2025):**

| Employee | RosterDate | Shift | IsOffDay | PlannedStart | PlannedEnd |
|---------|-----------|-------|----------|-------------|-----------|
| EMP001 (CMO) | 2025-04-01 | SHF-GEN | 0 | 09:00 | 18:00 |
| EMP001 | 2025-04-02 | SHF-GEN | 0 | 09:00 | 18:00 |
| EMP001 | 2025-04-03 | SHF-GEN | 0 | 09:00 | 18:00 |
| EMP010 (Sr. ICU Nurse) | 2025-04-01 | SHF-MORN | 0 | 07:00 | 15:00 |
| EMP010 | 2025-04-02 | SHF-AFT | 0 | 14:00 | 22:00 |
| EMP010 | 2025-04-03 | SHF-NIGHT | 0 | 22:00 | 06:00 (+1) |
| EMP020 (Emergency Physician) | 2025-04-01 | SHF-EMER-D | 0 | 08:00 | 20:00 |
| EMP020 | 2025-04-02 | NULL | 1 (Off) | — | — |
| EMP020 | 2025-04-03 | SHF-EMER-N | 0 | 20:00 | 08:00 (+1) |
| EMP005 (HR Manager) | 2025-04-01 | SHF-GEN | 0 | 09:00 | 18:00 |

---

## WorkSession Concept

`WorkSession` represents a single continuous work block for an employee, derived from pairing IN and OUT punches from `AttendanceLog`.

### Night Shift Example (EMP010)

```
Employee on SHF-NIGHT (20:00–08:00)
IN punch:  2025-04-03 22:00
OUT punch: 2025-04-04 06:10  (following day)

WorkSession.SessionDate   = 2025-04-03   ← credited to IN punch date
WorkSession.CheckInTime   = 2025-04-03 22:00
WorkSession.CheckOutTime  = 2025-04-04 06:10
WorkSession.WorkedMinutes = 490

AttendanceRecord for 2025-04-03:
  IsNightShift         = 1
  IsCrossDayAttendance = 1
  WorkedMinutes        = 490
  AttendanceStatus     = PRESENT
```

### Seeded Sample Punches (April 1, 2025)

| Employee | PunchTime | PunchType | Device | Worked (min) |
|---------|-----------|-----------|--------|-------------|
| EMP001 | 08:52 IN / 18:07 OUT | Biometric | BIO-MUM-01 | 495 |
| EMP005 | 09:11 IN / 18:03 OUT | Biometric | BIO-MUM-01 | 472 (11 min late) |
| EMP010 | 06:55 IN / 15:05 OUT | Biometric | BIO-MUM-02 | 490 |
| EMP020 | 07:52 IN / 20:10 OUT | Biometric | BIO-DEL-01 | 730 |
| EMP025 | 09:58 IN / 19:02 OUT | Mobile GPS | GEO-BLR-01 | — |
| EMP030 | 09:05 IN / 18:00 OUT | Mobile GPS | GEO-CHN-01 | — |

---

## Background Processors

All processors run as background hosted services within `SdxCore.Attendance.API` or `SdxCore.Attendance.Processor`. Schedules are configurable via `appsettings.json`.

### Processor Schedule Summary

| Processor | Schedule | Notes |
|-----------|----------|-------|
| Roster Generation (monthly) | 1st of month, 01:00 UTC | Fixed shifts (SHF-GEN, SHF-OPD, etc.) |
| Roster Generation (weekly) | Monday, 02:00 UTC | Rotation shifts (ROT-NURSING-3SHIFT, ROT-EMER-12HR) |
| Roster Generation (incremental) | Daily, 03:00 UTC | New joinees, gaps |
| Raw Punch Sync | Every 5 min | Validates and normalises biometric/mobile punches |
| WorkSession Builder | Every 5–10 min | Pairs IN/OUT from `AttendanceLog` |
| Attendance Finalizer | Dynamic per shift | `ShiftEnd + AttendanceFinalizeBufferMinutes` |
| Missing Checkout Auto-Close | Every 30 min | Open sessions past `MaxAllowedCheckoutDelayMinutes` |
| Reprocessing | On-demand / event-driven | Leave approval, regularization, shift changes |
| Holiday & Weekly Off | During roster gen + on-demand | Propagates holiday calendar changes |
| Regularization | Event-driven (RabbitMQ) | Workflow callback on APPROVED |

**Dynamic finalizer timings (based on seeded shifts):**

| Shift | End Time | Buffer | Finalizes At |
|-------|---------|--------|-------------|
| SHF-GEN | 18:00 | 240 min | 22:00 |
| SHF-MORN | 14:00 | 240 min | 18:00 |
| SHF-AFT | 20:00 | 240 min | 00:00 (+1) |
| SHF-NIGHT | 08:00 | 240 min | 12:00 |
| SHF-EMER-D | 20:00 | 240 min | 00:00 (+1) |
| SHF-EMER-N | 08:00 | 240 min | 12:00 |
| SHF-OPD | 17:00 | 240 min | 21:00 |
| SHF-FLEX | 19:00 | 240 min | 23:00 |

---

## Work Week Policies

Four policies are seeded for MedCare:

| PolicyCode | PolicyName | Days | Standard Hours |
|-----------|-----------|------|---------------|
| `WWP-ADMIN-INDIA` | Standard 5-Day (Mon–Fri) | Mon–Fri working, Sat–Sun off | 480 min / day |
| `WWP-CLINICAL-6DAY` | Clinical 6-Day (Mon–Sat) | Mon–Fri full, Sat half-day | 480 min (240 Sat) |
| `WWP-NURSING-SHIFT` | Nursing Rotating Shift | All 7 days working (off managed by roster) | 480 min / day |
| `WWP-EMERGENCY-7DAY` | Emergency 7-Day | All 7 days | 720 min / day (12-hour shifts) |

**Policy assignment by scope:**

| Scope | Policy |
|-------|--------|
| Global (default) | `WWP-ADMIN-INDIA` |
| Clinical, Cardiology, Oncology departments | `WWP-CLINICAL-6DAY` |
| Nursing, ICU departments | `WWP-NURSING-SHIFT` |
| Emergency department | `WWP-EMERGENCY-7DAY` |

---

## Holiday Calendars

### Seeded Calendars

| CalendarCode | Name | IsDefault | Assigned To |
|-------------|------|-----------|-------------|
| `HC-INDIA-NATIONAL` | India National Holidays | **Yes** | Country: India (all locations) |
| `HC-MH-STATE` | Maharashtra State Holidays | No | LOC-MUM-HQ, LOC-PUN-01 |
| `HC-DL-STATE` | Delhi State Holidays | No | LOC-DEL-01 |
| `HC-KA-STATE` | Karnataka State Holidays | No | LOC-BLR-01 |
| `HC-TN-STATE` | Tamil Nadu State Holidays | No | LOC-CHN-01 |
| `HC-TS-STATE` | Telangana State Holidays | No | LOC-HYD-01 |
| `HC-WB-STATE` | West Bengal State Holidays | No | LOC-KOL-01 |
| `HC-OPTIONAL` | Optional / Restricted Holidays | No | Employee choice |

**Merge strategy:** `MERGE` — national calendar applies globally; state calendar layers on top per office.

### National Holidays (2025)

| HolidayCode | Holiday Name | Date | Type |
|-------------|-------------|------|------|
| HOL-REPDAY | Republic Day | 2025-01-26 | National |
| HOL-HOLI | Holi | 2025-03-14 | Religious |
| HOL-EID | Eid-ul-Fitr | 2025-03-31 | Religious |
| HOL-UGADI | Ugadi / Gudi Padwa | 2025-03-30 | Religious |
| HOL-AMBEDKAR | Dr. B.R. Ambedkar Jayanti | 2025-04-14 | National |
| HOL-GOODFRI | Good Friday | 2025-04-18 | Religious |
| HOL-LABDAY | Labour Day / May Day | 2025-05-01 | National |
| HOL-INDEPDAY | Independence Day | 2025-08-15 | National |
| HOL-JANMASHTAMI | Janmashtami | 2025-08-16 | Religious |
| HOL-GANDHIJAY | Gandhi Jayanti | 2025-10-02 | National |
| HOL-DUSSEHRA | Dussehra / Navratri | 2025-10-02 | Religious |
| HOL-DIWALI | Diwali (Lakshmi Puja) | 2025-10-20 | Religious |
| HOL-DIWALINEXT | Diwali Holiday | 2025-10-21 | Religious |
| HOL-CHRISTMAS | Christmas Day | 2025-12-25 | Religious |

### State-Specific Holidays

| State | Holiday | Date |
|-------|---------|------|
| Maharashtra | Maharashtra Day | 2025-05-01 |
| Maharashtra | Chhath Puja | 2025-10-28 |
| Karnataka | Karnataka Rajyotsava | 2025-11-01 |
| Tamil Nadu | Pongal | 2025-01-14 |
| Tamil Nadu | Thiruvalluvar Day | 2025-01-15 |
| West Bengal | Durga Puja (Ashtami) | 2025-10-01 |
| West Bengal | Durga Puja (Navami) | 2025-10-02 |
| West Bengal | Durga Puja (Dashami) | 2025-10-03 |

---

## Leave Management

### Leave Types

| LeaveCode | LeaveName | IsPaid | MaxDays/Year | CarryForward | HalfDay |
|-----------|----------|--------|-------------|-------------|---------|
| `CL` | Casual Leave | Yes | 12 | No | Yes |
| `SL` | Sick Leave | Yes | 12 | No | Yes |
| `EL` | Earned Leave / Privilege Leave | Yes | 18 | **Yes** | Yes |
| `ML` | Maternity Leave | Yes | 182 | No | No |
| `PL` | Paternity Leave | Yes | 15 | No | No |
| `OL` | Optional / Restricted Holiday Leave | **No** | 2 | No | Yes |
| `LWP` | Leave Without Pay | **No** | Unlimited | No | No |
| `COMPOFF` | Compensatory Off Leave | Yes | Unlimited | No | Yes |
| `BL` | Bereavement Leave | Yes | 5 | No | No |
| `STUDYLEAVE` | Study / Exam Leave | Yes | 5 | No | No |

### Sample Leave Balances (2025)

| Employee | Leave Type | Opening | Allocated | Availed | Carry Forward |
|---------|-----------|---------|-----------|---------|---------------|
| EMP001 (CMO) | EL | 5.00 | 18.00 | 0 | 5.00 |
| EMP001 | CL / SL | 0 | 12.00 each | 0 | 0 |
| EMP009 (Resident) | SL | 0 | 12.00 | **3.00** | 0 |
| EMP010 (Sr. ICU Nurse) | EL | 3.00 | 18.00 | 0 | 3.00 |
| EMP011 (Staff Nurse) | CL | 0 | 12.00 | **1.00** | 0 |
| EMP005 (HR Manager) | EL | 7.00 | 18.00 | 0 | 7.00 |

### Sample Leave Requests

| Employee | Type | Status | Period | Days | Reason |
|---------|------|--------|--------|------|--------|
| EMP009 | SL | APPROVED | 2025-03-10 to 03-12 | 3 | Viral fever |
| EMP011 | CL | APPROVED | 2025-04-14 | 1 | Personal work |
| EMP028 | ML | APPROVED | 2025-05-01 to 10-30 | 183 | Maternity leave |
| EMP013 | EL | **PENDING** | 2025-05-20 to 05-24 | 5 | Family vacation |

### Comp-Off Types

| Code | Name | ExpiryDays |
|------|------|-----------|
| `CO-WEEKENDDUTY` | Weekend Duty Comp-Off | 90 |
| `CO-HOLIDAYDUTY` | Holiday Duty Comp-Off | 90 |
| `CO-OVERTIME` | Overtime Comp-Off | 60 |
| `CO-EMERGENCYDUTY` | Emergency Call Duty Comp-Off | 45 |

---

## Attendance Status

System statuses (not user-modifiable) seeded in `attendance.AttendanceStatus`:

| StatusCode | IsPresent | IsAbsent | IsPaid | CountsAsWorkingDay |
|-----------|-----------|---------|--------|-------------------|
| PRESENT | Yes | No | Yes | Yes |
| ABSENT | No | Yes | No | No |
| ON_LEAVE | No | No | Yes | No |
| WORK_FROM_HOME | Yes | No | Yes | Yes |
| HALF_DAY | Yes | No | Yes | Yes |
| LATE | Yes | No | Yes | Yes |
| HOLIDAY | No | No | Yes | No |
| WEEKEND | No | No | No | No |
| ON_DUTY | Yes | No | Yes | Yes |
| COMP_OFF | No | No | Yes | No |
| REGULARIZED | Yes | No | Yes | Yes |

### Sample Attendance Records (April 1, 2025)

| Employee | Shift | Status | CheckIn | CheckOut | Worked | Late |
|---------|-------|--------|---------|---------|--------|------|
| EMP001 (CMO) | SHF-GEN | PRESENT | 08:52 | 18:07 | 495 min | 0 min |
| EMP005 (HR Mgr) | SHF-GEN | **LATE** | 09:11 | 18:03 | 472 min | **11 min** |
| EMP010 (Sr. Nurse) | SHF-MORN | PRESENT | 06:55 | 15:05 | 490 min | 0 min |
| EMP020 (ER Physician) | SHF-EMER-D | PRESENT | 07:52 | 20:10 | 730 min | 0 min |

---

## Workflow Integration

The Attendance service does **not** implement approval logic internally. All approval-based operations delegate to `SdxCore.Workflow.API`.

```
1. Employee submits request → Attendance.API saves record with status PENDING
2. Attendance.API calls POST /api/v1/workflow/instances (internal, via Gateway)
3. Workflow.API resolves approvers and creates tasks
4. Approvers act via Workflow.API task inbox
5. Workflow.API publishes workflow.instance.status_changed to RabbitMQ
6. Attendance.API consumes event → updates record status (APPROVED / REJECTED)
7. Attendance Reprocessing Processor recalculates affected AttendanceRecord rows
```

### Attendance Modules that use Workflow

| Entity | WorkflowModule Code | Status Column Updated |
|--------|---------------------|-----------------------|
| `LeaveRequest` | `LEAVE` | `LeaveRequest.LeaveStatus` → then `AttendanceRecord.AttendanceStatus = ON_LEAVE` |
| `AttendanceRegularization` | `ATTENDANCE_REGULARIZATION` | `RegularizationStatus` → then reprocess `AttendanceRecord` |
| `ShiftSwapRequest` | `SHIFT_SWAP` | `ShiftSwapStatus` → then swap `EmployeeShiftRoster` entries |
| `CompOffBalance` | `COMP_OFF` | `WorkflowInstanceId` → credit `CompOffBalance` on APPROVED |

---

## API Endpoints

### Common Rules

**Gateway Security — `[GatewayOnly]`:**
All controllers validate `X-Internal-ApiKey`. Rejection:
```json
{
  "success": false,
  "message": "Access denied. This endpoint is only accessible through the API Gateway.",
  "data": null,
  "errors": ["Direct access is not permitted."]
}
```

**Audit:** `CreatedBy` / `LastUpdatedBy` from `IRequestContext.UserId` (Gateway-injected `X-User-Id`). Never in request body.

**Data Type Mapping:**

| SQL Type | C# Type |
|----------|---------|
| `BIGINT` | `long` |
| `INT` | `int` |
| `SMALLINT` | `short` |
| `TINYINT` | `byte` |
| `BIT` | `bool` |
| `DECIMAL` | `decimal` |
| `DATETIME2` | `DateTime` |
| `DATE` | `DateOnly` |
| `TIME` | `TimeOnly` |
| `NVARCHAR` | `string` |

---

### 1. AttendanceStatus (Master Data)

**Base route:** `/api/v1/attendance/statuses`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/statuses` | List all attendance status types |
| GET | `/api/v1/attendance/statuses/{id}` | Status detail with IsPresent, IsAbsent, IsPaid flags |
| POST | `/api/v1/attendance/statuses` | Create a new attendance status |
| PUT | `/api/v1/attendance/statuses/{id}` | Update status flags and display order |
| PATCH | `/api/v1/attendance/statuses/{id}/status` | Activate or deactivate |

**System statuses (not modifiable):** `PRESENT`, `ABSENT`, `ON_LEAVE`, `WORK_FROM_HOME`, `HALF_DAY`, `LATE`, `HOLIDAY`, `WEEKEND`, `ON_DUTY`, `COMP_OFF`, `REGULARIZED`

---

### 2. Shift (Master Data)

**Base route:** `/api/v1/attendance/shifts`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/shifts` | List all active shifts |
| GET | `/api/v1/attendance/shifts/{id}` | Shift detail including timing, grace, and processor config |
| POST | `/api/v1/attendance/shifts` | Create a new shift |
| PUT | `/api/v1/attendance/shifts/{id}` | Update timings, grace periods, buffer, and overtime config |
| PATCH | `/api/v1/attendance/shifts/{id}/status` | Activate or deactivate |

**Seeded shifts:** `SHF-GEN`, `SHF-MORN`, `SHF-AFT`, `SHF-NIGHT`, `SHF-EMER-D`, `SHF-EMER-N`, `SHF-OPD`, `SHF-FLEX`

> **No OFF shifts in master.** Off-days are represented on the roster with `ShiftId = NULL`, `IsOffDay = 1`.

---

### 3. ShiftAssignment

**Base route:** `/api/v1/attendance/shift-assignments`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/shift-assignments` | All shift assignments |
| GET | `/api/v1/attendance/shift-assignments/{id}` | Single assignment detail |
| GET | `/api/v1/attendance/shift-assignments/resolve` | Resolve effective shift for an employee + date |
| POST | `/api/v1/attendance/shift-assignments` | Assign a shift to an org scope |
| PUT | `/api/v1/attendance/shift-assignments/{id}` | Update effective dates or priority |
| PATCH | `/api/v1/attendance/shift-assignments/{id}/status` | Activate or deactivate |

**`GET /resolve` query params:** `employeeId` (required), `date` (required)

---

### 4. RotationShift (Master Data)

**Base route:** `/api/v1/attendance/rotation-shifts`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/rotation-shifts` | List all rotation patterns |
| GET | `/api/v1/attendance/rotation-shifts/{id}` | Rotation header detail |
| GET | `/api/v1/attendance/rotation-shifts/{id}/details` | All sequence steps for a rotation |
| GET | `/api/v1/attendance/rotation-shifts/{id}/preview` | Preview resolved shifts for an employee + date range |
| POST | `/api/v1/attendance/rotation-shifts` | Create a new rotation pattern |
| PUT | `/api/v1/attendance/rotation-shifts/{id}` | Update name and cycle length |
| PATCH | `/api/v1/attendance/rotation-shifts/{id}/status` | Activate or deactivate |

**Seeded rotations:** `ROT-NURSING-3SHIFT` (19-day), `ROT-EMER-12HR` (6-day)

**`GET /{id}/preview` query params:** `employeeId`, `fromDate`, `toDate`, `offsetDays`

---

### 5. RotationShiftDetail

**Base route:** `/api/v1/attendance/rotation-shifts/{rotationId}/details`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/rotation-shifts/{rotationId}/details` | All sequence steps ordered by SequenceNo |
| GET | `/api/v1/attendance/rotation-shifts/{rotationId}/details/{id}` | Single step detail |
| POST | `/api/v1/attendance/rotation-shifts/{rotationId}/details` | Add a sequence step |
| PUT | `/api/v1/attendance/rotation-shifts/{rotationId}/details/{id}` | Update shift, duration, off-day flag |
| PATCH | `/api/v1/attendance/rotation-shifts/{rotationId}/details/{id}/status` | Activate or deactivate |

**DB Constraints:**
- `CK_RotationShiftDetail_OffDayShift` — `IsOffDay = 1` requires `ShiftId = NULL`; `IsOffDay = 0` requires `ShiftId IS NOT NULL`.
- `UQ_RotationShiftDetail_Sequence` — `(RotationShiftId, SequenceNo)` must be unique.

---

### 6. RotationShiftAssignment

**Base route:** `/api/v1/attendance/rotation-assignments`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/rotation-assignments` | All rotation assignments |
| GET | `/api/v1/attendance/rotation-assignments/{id}` | Single assignment with offset info |
| GET | `/api/v1/attendance/rotation-assignments/resolve` | Resolve active rotation for employee + date |
| POST | `/api/v1/attendance/rotation-assignments` | Assign a rotation to an org scope |
| PUT | `/api/v1/attendance/rotation-assignments/{id}` | Update start date, effective dates, offset |
| PATCH | `/api/v1/attendance/rotation-assignments/{id}/status` | Activate or deactivate |

**Seeded assignments:**

| Rotation | Scope | RotationStartDate | OffsetDays |
|---------|-------|------------------|-----------|
| ROT-NURSING-3SHIFT | DEPARTMENT: Nursing | 2024-01-01 | 0 |
| ROT-NURSING-3SHIFT | DEPARTMENT: ICU | 2024-01-01 | 0 |
| ROT-NURSING-3SHIFT | EMPLOYEE: EMP010 | 2024-01-01 | **0** |
| ROT-NURSING-3SHIFT | EMPLOYEE: EMP011 | 2024-01-01 | **3** |
| ROT-NURSING-3SHIFT | EMPLOYEE: EMP012 | 2024-01-01 | **6** |
| ROT-EMER-12HR | DEPARTMENT: Emergency | 2024-01-01 | 0 |

---

### 7. EmployeeShiftRoster

**Base route:** `/api/v1/attendance/rosters`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/rosters/by-employee/{employeeId}` | All roster entries for an employee |
| GET | `/api/v1/attendance/rosters/by-employee/{employeeId}/month` | Monthly view (`?year=&month=`) |
| GET | `/api/v1/attendance/rosters/{id}` | Single roster entry |
| GET | `/api/v1/attendance/rosters/team` | Team roster view (`?managerId=&month=&year=`) |
| POST | `/api/v1/attendance/rosters` | Create a single roster entry manually |
| POST | `/api/v1/attendance/rosters/generate` | Trigger bulk roster generation for a scope + date range |
| PUT | `/api/v1/attendance/rosters/{id}` | Update planned times, shift, off-day flag |
| PATCH | `/api/v1/attendance/rosters/{id}/lock` | Lock a roster entry to prevent changes |
| PATCH | `/api/v1/attendance/rosters/{id}/unlock` | Unlock a locked entry (admin only) |
| PATCH | `/api/v1/attendance/rosters/{id}/status` | Activate or deactivate |

**`POST /generate` body:**
```json
{
  "scopeTypeId": 5,
  "scopeReferenceId": 12,
  "fromDate": "2025-12-01",
  "toDate": "2025-12-31",
  "generationType": "MONTHLY"
}
```

---

### 8. EmployeeRosterGenerationTracker

**Base route:** `/api/v1/attendance/roster-tracker`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/roster-tracker/by-employee/{employeeId}` | All generation records for an employee |
| GET | `/api/v1/attendance/roster-tracker/by-employee/{employeeId}/month` | Tracker for a specific year+month (`?year=&month=`) |
| GET | `/api/v1/attendance/roster-tracker/pending` | Employees whose roster generation is pending or overdue |
| PATCH | `/api/v1/attendance/roster-tracker/{id}/lock` | Lock tracker to prevent regeneration (payroll cutoff) |
| PATCH | `/api/v1/attendance/roster-tracker/{id}/unlock` | Unlock tracker (admin correction) |

**GenerationType values (from StatusLookup group `ROSTER_GENERATION_TYPE`):** `MONTHLY`, `WEEKLY`, `ADHOC`

---

### 9. WorkSession

**Base route:** `/api/v1/attendance/work-sessions`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/work-sessions/by-employee/{employeeId}` | All work sessions for an employee |
| GET | `/api/v1/attendance/work-sessions/by-employee/{employeeId}/range` | Sessions in a date range |
| GET | `/api/v1/attendance/work-sessions/{id}` | Single session detail |
| GET | `/api/v1/attendance/work-sessions/open` | All sessions with no CheckOutTime (admin monitor) |
| PATCH | `/api/v1/attendance/work-sessions/{id}/close` | Manually close an open session (admin correction) |

**`PATCH /{id}/close` body:**
```json
{
  "checkOutTime": "2025-04-03T22:10:00Z",
  "remarks": "Manual close — employee forgot to punch out"
}
```

---

### 10. AttendanceLog (Biometric Punches)

**Base route:** `/api/v1/attendance/logs`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/logs/by-employee/{employeeId}` | All raw punches for an employee |
| GET | `/api/v1/attendance/logs/by-employee/{employeeId}/range` | Punches in a date range |
| GET | `/api/v1/attendance/logs/unprocessed` | Unprocessed punches (batch processor monitor) |
| POST | `/api/v1/attendance/logs` | Register a biometric punch (device sync agent) |
| POST | `/api/v1/attendance/logs/bulk` | Bulk insert punches (device sync agent batch push) |
| PATCH | `/api/v1/attendance/logs/{id}/mark-processed` | Mark a log as processed (processor callback) |

**`PunchType` values:** `IN`, `OUT`, `BREAK`, `RETURN`

**Seeded biometric devices:**

| DeviceCode | Location | Office |
|-----------|---------|--------|
| BIO-MUM-01 | Mumbai Main Gate | LOC-MUM-HQ |
| BIO-MUM-02 | Mumbai Ward Block | LOC-MUM-HQ |
| BIO-MUM-03 | Mumbai Emergency Entry | LOC-MUM-HQ |
| BIO-DEL-01 | Delhi Main Gate | LOC-DEL-01 |
| BIO-BLR-01 | Bengaluru Main Gate | LOC-BLR-01 |
| BIO-CHN-01 | Chennai Main Entrance | LOC-CHN-01 |

---

### 11. MobileAttendanceLog (GPS Punches)

**Base route:** `/api/v1/attendance/mobile-logs`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/mobile-logs/by-employee/{employeeId}` | All mobile punches for an employee |
| GET | `/api/v1/attendance/mobile-logs/by-employee/{employeeId}/range` | Punches in a date range |
| POST | `/api/v1/attendance/mobile-logs/check-in` | Mobile check-in with geo-fence validation |
| POST | `/api/v1/attendance/mobile-logs/check-out` | Mobile check-out |

**Seeded geo-fences:**

| GeoFenceCode | Location | Radius |
|-------------|---------|--------|
| GEO-MUM-HQ | Mumbai HQ | 150 m |
| GEO-BLR-01 | Bengaluru Hospital | 150 m |
| GEO-CHN-01 | Chennai Hospital | 150 m |
| GEO-DEL-01 | Delhi Hospital | 200 m |
| GEO-HYD-01 | Hyderabad Hospital | 150 m |
| GEO-KOL-01 | Kolkata Hospital | 150 m |

**`POST /check-in` body:**
```json
{
  "employeeId": 201,
  "latitude": 12.971598,
  "longitude": 77.594566,
  "deviceInfo": "Samsung Galaxy S24 | Android 14"
}
```

**Geo-validation flow:**
```
Attendance.API → POST /api/v1/geofences/check (Time.API, internal)
Time.API returns { isInside, matchedFences }
→ MobileAttendanceLog.IsInsideGeoFence = result
→ AttendanceLog entry created → feeds WorkSession Builder
```

---

### 12. AttendanceRecord

**Base route:** `/api/v1/attendance/records`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/records` | Paged list with filters |
| GET | `/api/v1/attendance/records/{id}` | Full computed record detail |
| GET | `/api/v1/attendance/records/by-employee/{employeeId}` | All records for an employee |
| GET | `/api/v1/attendance/records/by-employee/{employeeId}/range` | Records in a date range (`?from=&to=`) |
| GET | `/api/v1/attendance/records/by-employee/{employeeId}/date/{date}` | Single day record |
| GET | `/api/v1/attendance/records/summary` | Aggregate summary by employee + month (`?employeeId=&month=&year=`) |
| POST | `/api/v1/attendance/records` | Create a manual attendance entry |
| PUT | `/api/v1/attendance/records/{id}` | Update a manual entry |
| PATCH | `/api/v1/attendance/records/{id}/approve` | Approve a manual entry |
| PATCH | `/api/v1/attendance/records/{id}/lock` | Lock record (payroll cutoff — admin only) |
| PATCH | `/api/v1/attendance/records/{id}/reprocess` | Trigger reprocessing for a specific record (admin) |
| PATCH | `/api/v1/attendance/records/{id}/status` | Activate or deactivate |

**Key Fields:** `EmployeeId`, `EmployeeShiftId`, `WorkSessionId`, `AttendanceDate`, `ShiftId`, `AttendanceStatus`, `CheckInTime`, `CheckOutTime`, `LateByMinutes`, `EarlyExitMinutes`, `WorkedMinutes`, `BreakMinutes`, `OvertimeMinutes`, `IsNightShift`, `IsCrossDayAttendance`, `IsWeeklyOff`, `IsHoliday`, `IsOnLeave`, `IsManualEntry`, `IsAutoProcessed`, `IsAttendanceLocked`, `Remarks`, `ApprovedBy`, `ApprovedAt`

**Query Filters:**
- `?employeeId=`, `?date=`, `?from=&to=`, `?status=`, `?isManualEntry=`, `?isLocked=`, `?page=&pageSize=`

---

### 13. Attendance Processing — Admin Endpoints

**Base route:** `/api/v1/attendance/processing`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| POST | `/api/v1/attendance/processing/reprocess` | Trigger manual reprocessing for a scope + date range |
| POST | `/api/v1/attendance/processing/finalize` | Manually trigger finalization for a specific shift + date |
| GET | `/api/v1/attendance/processing/status` | Current processor run status and last-run timestamps |

**`POST /reprocess` body:**
```json
{
  "employeeIds": [201, 202],
  "fromDate": "2025-04-01",
  "toDate": "2025-04-30",
  "reason": "Holiday declared retrospectively"
}
```

**`GET /status` response:**
```json
{
  "rosterGeneration": { "lastRun": "2025-11-01T01:00:00Z", "status": "SUCCESS" },
  "workSessionBuilder": { "lastRun": "2025-11-14T10:05:00Z", "status": "RUNNING" },
  "attendanceFinalizer": { "lastRun": "2025-11-14T09:00:00Z", "status": "SUCCESS" },
  "missingCheckoutCloser": { "lastRun": "2025-11-14T09:30:00Z", "status": "SUCCESS" }
}
```

---

### 14. LeaveType (Master Data)

**Base route:** `/api/v1/attendance/leave-types`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/leave-types` | List all active leave types |
| GET | `/api/v1/attendance/leave-types/{id}` | Leave type detail |
| POST | `/api/v1/attendance/leave-types` | Create a new leave type |
| PUT | `/api/v1/attendance/leave-types/{id}` | Update rules |
| PATCH | `/api/v1/attendance/leave-types/{id}/status` | Activate or deactivate |

**Seeded leave types:** `CL`, `SL`, `EL`, `ML`, `PL`, `OL`, `LWP`, `COMPOFF`, `BL`, `STUDYLEAVE`
**Key Fields:** `LeaveCode`, `LeaveName`, `IsPaid`, `MaxDaysPerYear`, `AllowCarryForward`, `RequiresApproval`, `AllowHalfDay`, `IsActive`

---

### 15. LeaveRequest

**Base route:** `/api/v1/attendance/leave-requests`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/leave-requests` | Paged list with filters |
| GET | `/api/v1/attendance/leave-requests/{id}` | Detail with workflow status |
| GET | `/api/v1/attendance/leave-requests/by-employee/{employeeId}` | All requests for an employee |
| GET | `/api/v1/attendance/leave-requests/by-employee/{employeeId}/balance` | Current balances by leave type |
| GET | `/api/v1/attendance/leave-requests/team-calendar` | Team leave view (`?managerId=&month=&year=`) |
| POST | `/api/v1/attendance/leave-requests` | Create a draft leave request |
| PUT | `/api/v1/attendance/leave-requests/{id}` | Update a DRAFT request |
| PATCH | `/api/v1/attendance/leave-requests/{id}/submit` | Submit draft to workflow |
| PATCH | `/api/v1/attendance/leave-requests/{id}/cancel` | Cancel a pending or approved leave |
| PATCH | `/api/v1/attendance/leave-requests/{id}/status` | Activate or deactivate |

**`LeaveStatus` values (from `LEAVE_STATUS` group):** `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED`
**Key Fields:** `EmployeeId`, `LeaveTypeId`, `LeaveStatus`, `FromDate`, `ToDate`, `TotalDays`, `IsHalfDay`, `HalfDaySession`, `Reason`, `WorkflowInstanceId`, `ApprovedBy`, `ApprovedAt`

**Workflow integration:**
```
PATCH /submit → status = PENDING
             → POST /api/v1/workflow/instances { moduleCode: "LEAVE", ... }
RabbitMQ callback (APPROVED)
             → LeaveStatus = APPROVED
             → Deduct LeaveBalance
             → Trigger Reprocessing Processor for affected dates
```

---

### 16. LeaveBalance

**Base route:** `/api/v1/attendance/leave-balances`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/leave-balances/by-employee/{employeeId}` | All balances for an employee |
| GET | `/api/v1/attendance/leave-balances/by-employee/{employeeId}/year/{year}` | Balances for a specific year |
| GET | `/api/v1/attendance/leave-balances/{id}` | Single balance record |
| POST | `/api/v1/attendance/leave-balances` | Create a balance entry (HR year-open) |
| PUT | `/api/v1/attendance/leave-balances/{id}` | HR correction adjustment |
| PATCH | `/api/v1/attendance/leave-balances/{id}/carry-forward` | Apply carry-forward from previous year |
| PATCH | `/api/v1/attendance/leave-balances/{id}/status` | Activate or deactivate |

**`ClosingBalance` is a computed column:** `OpeningBalance + Allocated + CarryForward - Availed - Encashed`

**Key Fields:** `EmployeeId`, `LeaveTypeId`, `BalanceYear`, `OpeningBalance`, `Allocated`, `Availed`, `Encashed`, `CarryForward`, `ClosingBalance` (computed column)

---

### 17. CompOffType (Master Data)

**Base route:** `/api/v1/attendance/comp-off-types`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/comp-off-types` | List all comp-off types |
| GET | `/api/v1/attendance/comp-off-types/{id}` | Type detail |
| POST | `/api/v1/attendance/comp-off-types` | Create a new comp-off type |
| PUT | `/api/v1/attendance/comp-off-types/{id}` | Update expiry days and name |
| PATCH | `/api/v1/attendance/comp-off-types/{id}/status` | Activate or deactivate |

**Seeded types:** `CO-WEEKENDDUTY` (90d), `CO-HOLIDAYDUTY` (90d), `CO-OVERTIME` (60d), `CO-EMERGENCYDUTY` (45d)
**Key Fields:** `CompOffTypeCode`, `CompOffTypeName`, `ExpiryDays`, `IsActive`

---

### 18. CompOffBalance

**Base route:** `/api/v1/attendance/comp-off`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/comp-off/by-employee/{employeeId}` | All comp-off records for an employee |
| GET | `/api/v1/attendance/comp-off/{id}` | Detail with expiry and availed info |
| GET | `/api/v1/attendance/comp-off/by-employee/{employeeId}/available` | Unexpired available balance |
| POST | `/api/v1/attendance/comp-off` | Create a comp-off earning record |
| PATCH | `/api/v1/attendance/comp-off/{id}/submit` | Submit for workflow approval |
| PATCH | `/api/v1/attendance/comp-off/{id}/avail` | Deduct availed days from balance |
| PATCH | `/api/v1/attendance/comp-off/{id}/status` | Activate or deactivate |

**Key Fields:** `EmployeeId`, `CompOffTypeId`, `EarnedDate`, `ExpiryDate`, `TotalDays`, `AvailedDays`, `RemainingDays` (computed), `AttendanceRecordId`, `WorkflowInstanceId`

---

### 19. AttendanceRegularization

**Base route:** `/api/v1/attendance/regularizations`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/regularizations` | Paged list with filters |
| GET | `/api/v1/attendance/regularizations/{id}` | Detail with workflow status |
| GET | `/api/v1/attendance/regularizations/by-employee/{employeeId}` | All requests for an employee |
| POST | `/api/v1/attendance/regularizations` | Create a regularization request |
| PUT | `/api/v1/attendance/regularizations/{id}` | Update a DRAFT |
| PATCH | `/api/v1/attendance/regularizations/{id}/submit` | Submit draft to workflow |
| PATCH | `/api/v1/attendance/regularizations/{id}/cancel` | Cancel a pending request |
| PATCH | `/api/v1/attendance/regularizations/{id}/status` | Activate or deactivate |

**`RegularizationStatus` values (from `ATTENDANCE_REGULARIZATION_STATUS` group):** `PENDING`, `APPROVED`, `REJECTED`
**Key Fields:** `EmployeeId`, `AttendanceDate`, `RequestedCheckIn`, `RequestedCheckOut`, `Reason`, `RegularizationStatus`, `WorkflowInstanceId`, `ApprovedBy`, `ApprovedAt`

**On APPROVED:** Regularization Processor updates `AttendanceRecord.CheckInTime`, `CheckOutTime`, then re-runs finalization logic for that date.

---

### 20. ShiftSwapRequest

**Base route:** `/api/v1/attendance/shift-swaps`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/shift-swaps` | Paged list with filters |
| GET | `/api/v1/attendance/shift-swaps/{id}` | Detail with workflow status |
| GET | `/api/v1/attendance/shift-swaps/by-employee/{employeeId}` | All swap requests for an employee |
| GET | `/api/v1/attendance/shift-swaps/by-employee/{employeeId}/pending` | Pending requests where employee is the target |
| POST | `/api/v1/attendance/shift-swaps` | Create a shift swap request |
| PATCH | `/api/v1/attendance/shift-swaps/{id}/submit` | Submit for workflow approval |
| PATCH | `/api/v1/attendance/shift-swaps/{id}/cancel` | Cancel a pending swap |
| PATCH | `/api/v1/attendance/shift-swaps/{id}/status` | Activate or deactivate |

**`ShiftSwapStatus` values (from `SHIFT_SWAP_STATUS` group):** `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED`

**Key Fields:** `RequesterEmployeeId`, `TargetEmployeeId`, `RequesterRosterId`, `TargetRosterId`, `ShiftSwapStatus`, `WorkflowInstanceId`, `ApprovedBy`, `ApprovedAt`

**On APPROVED:** Swap the `ShiftId` and planned times on both `EmployeeShiftRoster` rows.

---

### 21. HolidayCalendar (Master Data)

**Base route:** `/api/v1/attendance/holiday-calendars`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/holiday-calendars` | List all calendars |
| GET | `/api/v1/attendance/holiday-calendars/{id}` | Calendar detail |
| GET | `/api/v1/attendance/holiday-calendars/{id}/holidays` | All holidays in this calendar |
| POST | `/api/v1/attendance/holiday-calendars` | Create a new calendar |
| PUT | `/api/v1/attendance/holiday-calendars/{id}` | Update name and default flag |
| PATCH | `/api/v1/attendance/holiday-calendars/{id}/status` | Activate or deactivate |

**Seeded calendars:** `HC-INDIA-NATIONAL` (default), `HC-MH-STATE`, `HC-DL-STATE`, `HC-KA-STATE`, `HC-TN-STATE`, `HC-TS-STATE`, `HC-WB-STATE`, `HC-OPTIONAL`

---

### 22. HolidayType (Master Data)

**Base route:** `/api/v1/attendance/holiday-types`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/holiday-types` | List all holiday types |
| GET | `/api/v1/attendance/holiday-types/{id}` | Type detail |
| POST | `/api/v1/attendance/holiday-types` | Create a new holiday type |
| PUT | `/api/v1/attendance/holiday-types/{id}` | Update name and optional flag |
| PATCH | `/api/v1/attendance/holiday-types/{id}/status` | Activate or deactivate |

**Seeded types:** `NATIONAL`, `STATE`, `RELIGIOUS`, `OPTIONAL`

---

### 23. Holiday

**Base route:** `/api/v1/attendance/holidays`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/holidays` | Paged list with filters |
| GET | `/api/v1/attendance/holidays/{id}` | Holiday detail |
| GET | `/api/v1/attendance/holidays/by-calendar/{calendarId}` | All holidays in a calendar |
| GET | `/api/v1/attendance/holidays/by-calendar/{calendarId}/year/{year}` | Holidays for a specific year |
| POST | `/api/v1/attendance/holidays` | Add a holiday — triggers Holiday Processor for affected rosters |
| PUT | `/api/v1/attendance/holidays/{id}` | Update name, date, half-day flag |
| PATCH | `/api/v1/attendance/holidays/{id}/status` | Activate or deactivate |

**Key Fields:** `HolidayCalendarId`, `HolidayTypeId`, `HolidayCode`, `HolidayName`, `HolidayDate`, `IsHalfDay`, `HalfDaySession`, `IsRecurring`, `ApplicableYear`, `Description`

> When a holiday is declared after roster is already generated, the Holiday & Weekly Off Processor propagates it to affected `EmployeeShiftRoster` and `AttendanceRecord` rows.

---

### 24. HolidayCalendarAssignment

**Base route:** `/api/v1/attendance/holiday-calendar-assignments`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/holiday-calendar-assignments` | All assignments |
| GET | `/api/v1/attendance/holiday-calendar-assignments/{id}` | Single assignment detail |
| GET | `/api/v1/attendance/holiday-calendar-assignments/resolve` | Resolve active calendar for employee + date |
| POST | `/api/v1/attendance/holiday-calendar-assignments` | Assign calendar to org scope |
| PUT | `/api/v1/attendance/holiday-calendar-assignments/{id}` | Update effective dates and priority |
| PATCH | `/api/v1/attendance/holiday-calendar-assignments/{id}/status` | Activate or deactivate |

---

### 25. WorkWeekPolicy (Master Data)

**Base route:** `/api/v1/attendance/work-week-policies`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/work-week-policies` | List all work week policies |
| GET | `/api/v1/attendance/work-week-policies/{id}` | Policy detail |
| GET | `/api/v1/attendance/work-week-policies/{id}/days` | Day-level config (7 rows) |
| POST | `/api/v1/attendance/work-week-policies` | Create a new policy |
| PUT | `/api/v1/attendance/work-week-policies/{id}` | Update name and default flag |
| PATCH | `/api/v1/attendance/work-week-policies/{id}/status` | Activate or deactivate |

**Seeded policies:** `WWP-ADMIN-INDIA` (default), `WWP-CLINICAL-6DAY`, `WWP-NURSING-SHIFT`, `WWP-EMERGENCY-7DAY`

---

### 26. WorkWeekPolicyDay

**Base route:** `/api/v1/attendance/work-week-policies/{policyId}/days`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/work-week-policies/{policyId}/days` | All day configs |
| GET | `/api/v1/attendance/work-week-policies/{policyId}/days/{id}` | Single day config |
| POST | `/api/v1/attendance/work-week-policies/{policyId}/days` | Add a day configuration |
| PUT | `/api/v1/attendance/work-week-policies/{policyId}/days/{id}` | Update working day, hours, half-day |
| PATCH | `/api/v1/attendance/work-week-policies/{policyId}/days/{id}/status` | Activate or deactivate |


**Key Fields:** `WorkWeekPolicyId`, `DayOfWeek` (0=Sun … 6=Sat), `IsWorkingDay`, `StandardWorkingMinutes`, `IsHalfDay`

**`DayOfWeek` encoding:** 0 = Sunday, 1 = Monday … 6 = Saturday

---

### 27. WorkWeekPolicyAssignment

**Base route:** `/api/v1/attendance/work-week-policy-assignments`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/attendance/work-week-policy-assignments` | All policy assignments |
| GET | `/api/v1/attendance/work-week-policy-assignments/{id}` | Single assignment detail |
| GET | `/api/v1/attendance/work-week-policy-assignments/resolve` | Resolve active policy for employee + date |
| POST | `/api/v1/attendance/work-week-policy-assignments` | Assign policy to org scope |
| PUT | `/api/v1/attendance/work-week-policy-assignments/{id}` | Update effective dates and priority |
| PATCH | `/api/v1/attendance/work-week-policy-assignments/{id}/status` | Activate or deactivate |

---

## Microservice Integration Architecture

```
Client Request (via Gateway)
      │
      ▼
Attendance.API
      │
      ├── Reads from Time.API (internal via Gateway)
      │   ├── POST /api/v1/geofences/check      → Mobile geo-fence validation
      │   └── GET  /api/v1/scope-types           → Scope resolution for assignments
      │
      ├── Reads from Employee.API (internal via Gateway)
      │   ├── GET /api/v1/employees/{id}          → Validate employee + dept/location
      │   └── GET /api/v1/employees/{id}/manager  → For notifications
      │
      ├── Calls Workflow.API (internal via Gateway) on approval submissions
      │   └── POST /api/v1/workflow/instances
      │
      ├── Publishes to RabbitMQ (outbox pattern)
      │   ├── attendance.leave.submitted          → Notification consumer → email to manager
      │   ├── attendance.leave.approved           → Notification consumer → email to employee
      │   ├── attendance.roster.generated         → Cache invalidation consumer
      │   └── attendance.record.finalized         → Elasticsearch indexing consumer
      │
      └── Consumes from RabbitMQ
          ├── workflow.instance.status_changed    → Updates leave/regularization/swap status
          │                                          → Triggers Reprocessing Processor
          └── employee.employee.updated           → Refreshes local employee cache
```

---

## Docker Compose & Configuration

```yaml
  attendance-api:
    build:
      context: ..
      dockerfile: src/Services/Attendance/SdxCore.Attendance.API/Dockerfile
    container_name: sdxcore-attendance-api
    environment:
      - ASPNETCORE_ENVIRONMENT=${ASPNETCORE_ENVIRONMENT:-Development}
      - ASPNETCORE_URLS=http://+:80
      - ConnectionStrings__DefaultConnection=Server=sql-server;Database=SdxCore;User Id=sa;Password=${SQL_SA_PASSWORD};TrustServerCertificate=True;MultipleActiveResultSets=true
      - Authentication__InternalApiKey=${AUTH_GATEWAY_INTERNAL_API_KEY}
      - Redis__ConnectionString=redis:6379
      - RabbitMQ__Host=rabbitmq
      - RabbitMQ__VirtualHost=sdxcore
      - RabbitMQ__Username=${RABBITMQ_DEFAULT_USER}
      - RabbitMQ__Password=${RABBITMQ_DEFAULT_PASS}
      - InternalServices__WorkflowApiUrl=http://workflow-api:80
      - InternalServices__EmployeeApiUrl=http://employee-api:80
      - InternalServices__TimeApiUrl=http://time-api:80
      - Processors__RosterGeneration__MonthlySchedule=0 1 1 * *
      - Processors__RosterGeneration__WeeklySchedule=0 2 * * 1
      - Processors__RosterGeneration__IncrementalSchedule=0 3 * * *
      - Processors__RawPunchSync__IntervalSeconds=300
      - Processors__WorkSessionBuilder__IntervalSeconds=300
      - Processors__MissingCheckout__IntervalSeconds=1800
    ports:
      - "${ATTENDANCE_PORT:-5007}:80"
    networks:
      - sdxcore-network
    depends_on:
      sql-server:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    healthcheck:
      test: curl --fail http://localhost:80/health || exit 1
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
    restart: unless-stopped
```

**Gateway YARP cluster:**
```yaml
- ReverseProxy__Clusters__attendance-cluster__Destinations__attendance-api__Address=http://attendance-api:80
```

**`.env.example`:**
```dotenv
ATTENDANCE_PORT=5007
```

**EF Core Migration:**
```bash
dotnet ef migrations add InitialAttendance \
  --project src/Services/Attendance/SdxCore.Attendance.Persistence \
  --startup-project src/Services/Attendance/SdxCore.Attendance.API

dotnet ef database update \
  --project src/Services/Attendance/SdxCore.Attendance.Persistence \
  --startup-project src/Services/Attendance/SdxCore.Attendance.API
```

---

## Endpoint Count Summary

| Resource | GET | POST | PUT | PATCH | Total |
|----------|-----|------|-----|-------|-------|
| AttendanceStatus | 2 | 1 | 1 | 1 | 5 |
| Shift | 2 | 1 | 1 | 1 | 5 |
| ShiftAssignment | 3 | 1 | 1 | 1 | 6 |
| RotationShift | 4 | 1 | 1 | 1 | 7 |
| RotationShiftDetail | 2 | 1 | 1 | 1 | 5 |
| RotationShiftAssignment | 3 | 1 | 1 | 1 | 6 |
| EmployeeShiftRoster | 4 | 2 | 1 | 3 | 10 |
| EmployeeRosterGenerationTracker | 3 | — | — | 2 | 5 |
| WorkSession | 4 | — | — | 1 | 5 |
| AttendanceLog | 3 | 2 | — | 1 | 6 |
| MobileAttendanceLog | 2 | 2 | — | — | 4 |
| AttendanceRecord | 6 | 1 | 1 | 4 | 12 |
| Attendance Processing (admin) | 1 | 2 | — | — | 3 |
| LeaveType | 2 | 1 | 1 | 1 | 5 |
| LeaveRequest | 5 | 1 | 1 | 3 | 10 |
| LeaveBalance | 3 | 1 | 1 | 2 | 7 |
| CompOffType | 2 | 1 | 1 | 1 | 5 |
| CompOffBalance | 3 | 1 | — | 3 | 7 |
| AttendanceRegularization | 3 | 1 | 1 | 3 | 8 |
| ShiftSwapRequest | 4 | 1 | — | 3 | 8 |
| HolidayCalendar | 3 | 1 | 1 | 1 | 6 |
| HolidayType | 2 | 1 | 1 | 1 | 5 |
| Holiday | 4 | 1 | 1 | 1 | 7 |
| HolidayCalendarAssignment | 3 | 1 | 1 | 1 | 6 |
| WorkWeekPolicy | 3 | 1 | 1 | 1 | 6 |
| WorkWeekPolicyDay | 2 | 1 | 1 | 1 | 5 |
| WorkWeekPolicyAssignment | 3 | 1 | 1 | 1 | 6 |
| **TOTAL** | **86** | **28** | **20** | **40** | **174** |

---

## Dependency Seeding Order

1. `shared.StatusLookup` — groups: `LEAVE_STATUS`, `SHIFT_SWAP_STATUS`, `ATTENDANCE_REGULARIZATION_STATUS`, `ATTENDANCE_STATUS`, `ROSTER_GENERATION_TYPE`
2. `attendance.AttendanceStatus` — 11 system records: PRESENT, ABSENT, ON_LEAVE, WORK_FROM_HOME, HALF_DAY, LATE, HOLIDAY, WEEKEND, ON_DUTY, COMP_OFF, REGULARIZED
3. `attendance.LeaveType` — 10 types: CL, SL, EL, ML, PL, OL, LWP, COMPOFF, BL, STUDYLEAVE
4. `attendance.CompOffType` — 4 types: CO-WEEKENDDUTY, CO-HOLIDAYDUTY, CO-OVERTIME, CO-EMERGENCYDUTY
5. `attendance.HolidayType` — NATIONAL, STATE, RELIGIOUS, OPTIONAL
6. `attendance.HolidayCalendar` — HC-INDIA-NATIONAL (default), 6 state calendars, HC-OPTIONAL
7. `attendance.Holiday` — 14 national + state-specific 2025 holidays
8. `attendance.HolidayCalendarAssignment` — national → COUNTRY: IN; state calendars → office locations
9. `attendance.WorkWeekPolicy` — 4 policies: WWP-ADMIN-INDIA (default), WWP-CLINICAL-6DAY, WWP-NURSING-SHIFT, WWP-EMERGENCY-7DAY
10. `attendance.WorkWeekPolicyDay` — 7 rows per policy (28 total)
11. `attendance.WorkWeekPolicyAssignment` — global default + dept overrides
12. `attendance.Shift` — 8 shifts: SHF-GEN, SHF-MORN, SHF-AFT, SHF-NIGHT, SHF-EMER-D, SHF-EMER-N, SHF-OPD, SHF-FLEX
13. `attendance.ShiftAssignment` — global default (SHF-GEN) + dept-level + 1 employee override (EMP009)
14. `attendance.RotationShift` + `RotationShiftDetail` — ROT-NURSING-3SHIFT (6 steps, 19-day), ROT-EMER-12HR (4 steps, 6-day)
15. `attendance.RotationShiftAssignment` — Nursing dept + ICU dept + 3 employee overrides (EMP010/011/012 with offsets 0/3/6); Emergency dept
16. Run Roster Generation Processor — generates `EmployeeShiftRoster` for current + next month
17. `attendance.LeaveBalance` — seed 2025 balances for key employees (EMP001, EMP005, EMP009, EMP010, EMP011)
18. `attendance.LeaveRequest` — sample approved/pending requests (EMP009 SL, EMP011 CL, EMP028 ML, EMP013 EL)
19. `attendance.CompOffBalance` — sample earned comp-off (EMP010 weekend duty, EMP020 holiday duty)
20. `attendance.EmployeeShiftRoster` — sample April 2025 entries for EMP001, EMP005, EMP010, EMP020
21. `attendance.AttendanceLog` — sample biometric punches April 1, 2025 (8 records)
22. `attendance.MobileAttendanceLog` — sample GPS punches April 1, 2025 (EMP025 Bengaluru, EMP030 Chennai)
23. `attendance.AttendanceRecord` — 4 finalized records for April 1, 2025
24. `workflow.WorkflowModule` — seed LEAVE, ATTENDANCE_REGULARIZATION, SHIFT_SWAP, COMP_OFF
25. `workflow.WorkflowDefinition` + steps + approvers — configure approval templates
26. `workflow.WorkflowAssignment` — assign definitions to org scopes