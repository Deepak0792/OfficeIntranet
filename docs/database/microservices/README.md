# Office Intranet - Microservices Database Architecture

## Overview

This document describes the microservices-based database architecture for the Office Intranet application. The monolithic `dbo` schema has been decomposed into 8 independent service schemas, each encapsulating a specific business domain.

## Architecture Principles

1. **Service Boundaries**: Each schema represents an independent microservice with clear responsibilities
2. **Shared Nothing**: Services own their data; cross-service references use explicit foreign keys
3. **Domain Isolation**: Status codes use composite keys (`StatusCode` + `StatusGroup`) for type safety
4. **Audit Trail**: All tables include `CreatedAt` timestamps; update tracking uses `UpdatedAt` where needed
5. **Soft Delete**: `IsActive` flags instead of physical DELETE for data retention

---

## Service Schemas

| # | Schema | Tables | Microservice | Execution Order |
|---|--------|--------|--------------|-----------------|
| 1 | **shared** | 1 | Cross-Cutting | 1st |
| 2 | **time** | 11 | Infrastructure | 2nd |
| 3 | **workflow** | 7 | Workflow Engine | 3rd |
| 4 | **employee** | 12 | Employee Core | 4th |
| 5 | **attendance** | 24 | Time & Attendance | 5th |
| 6 | **hr** | 32 | HR Services | 6th |
| 7 | **payroll** | 20 | Payroll | 7th |
| 8 | **helpdesk** | 15 | IT Support | 8th |

**Total: 122 tables across 8 schemas**

---

## Schema Details

### 1. shared — Cross-Cutting Service

**Purpose**: Universal status codes and lookup data shared across all services.

**Tables:**
- `StatusLookup` — Composite primary key (StatusCode, StatusGroup) for domain-isolated status codes

**Status Groups (35+):**
```
EMPLOYMENT_TYPE, CONTACT_TYPE, LEAVE_REQUEST_STATUS, ATTENDANCE_STATUS,
SHIFT_SWAP_STATUS, ATTENDANCE_REGULARIZATION_STATUS, HELPDESK_TICKET_STATUS,
HELPDESK_TICKET_PRIORITY, HELPDESK_ASSET_STATUS, HELPDESK_LICENSE_TYPE,
ONBOARDING_TASK_STATUS, DOC_VERIFY_STATUS, BGV_STATUS, BGV_RESULT,
BGV_CHECK_TYPE, ONBOARDING_PHASE, EXIT_TYPE, EXIT_INTERVIEW_STATUS,
CLEARANCE_STATUS, FINAL_SETTLEMENT_STATUS, CLEARANCE_ITEM_STATUS,
POLICY_STATUS, POLICY_ACK_STATUS, SALARY_SLIP_STATUS, PERF_CYCLE_TYPE,
PERF_CYCLE_STATUS, PERF_REVIEW_STATUS, GOAL_STATUS, GOAL_KR_STATUS,
TRAINING_MODE, TRAINING_BATCH_STATUS, TRAINING_RECORD_STATUS,
RECOMMENDATION_STATUS, INTERVIEW_STATUS, JOB_POSTING_STATUS,
APPLICATION_STATUS, OFFER_STATUS, NEGOTIATION_STATUS, DECLARATION_STATUS,
PROOF_REVIEW_STATUS, DISBURSEMENT_STATUS, TRANSACTION_STATUS,
SALARY_REVISION_TYPE, BANK_ACCOUNT_TYPE, CALC_TYPE, DEDUCTION_CATEGORY,
PAYMENT_MODE_TYPE, INTERVIEW_TYPE, LEAVE_STATUS
```

**Dependencies**: None (foundational)

---

### 2. time — Infrastructure Service

**Purpose**: Time zones, geographic hierarchy, organizational structure, and device management.

**Tables:**
- `TimeZoneMaster` — Global time zone definitions with UTC offsets
- `Country` — Country codes, currencies, default time zones
- `Region` — State/city hierarchy (supports nested regions)
- `LegalEntity` — Company subsidiaries with tax IDs
- `OfficeLocation` — Office addresses with geo-coordinates
- `Department` — Organizational departments (supports hierarchy)
- `ScopeType` — Organizational hierarchy levels for dynamic assignment
- `Designation` — Job titles and grade levels
- `DocumentType` — Employee document categories
- `GeoFence` — GPS-based attendance zones
- `BiometricDevice` — Attendance device inventory

**Key Features:**
- Hierarchical regions (country → state → city)
- Multi-level department structure
- Scope-based assignment support (global → employee level)
- Geo-fencing for mobile attendance validation

**Dependencies**: `shared` (StatusLookup)

---

### 3. workflow — Workflow Engine Service

**Purpose**: Configurable multi-step approval workflow engine.

**Tables:**
- `WorkflowModule` — Registered business modules (Leave, Attendance, etc.)
- `WorkflowDefinition` — Versioned workflow templates
- `WorkflowStep` — Ordered steps within a workflow
- `WorkflowStepApprover` — Approver configuration per step
- `WorkflowAssignment` — Scope-based workflow assignment
- `WorkflowInstance` — Runtime workflow execution
- `WorkflowActionHistory` — Immutable audit trail

**Key Features:**
- Dynamic approver resolution (reporting manager, role, specific user)
- Escalation support with `EscalationAfterHours`
- Scope-based assignment (Global, Country, Legal Entity, Office, Department, Team, Employee)
- Full action audit trail

**Dependencies**: `shared`, `employee`, `time`

---

### 4. employee — Employee Core Service

**Purpose**: Core employee master data and organizational relationships.

**Tables:**
- `Employee` — Employee profile (code, name, email, designation, employment type)
- `EmployeeLegalEntity` — Employee ↔ legal entity mapping
- `EmployeeDepartment` — Employee ↔ department mapping (supports split allocation)
- `EmployeeLocation` — Employee ↔ office location mapping
- `EmployeeRelationship` — Reporting hierarchy (manager, mentor, dotted-line)
- `EmployeeContact` — Additional contact methods (phone, Slack, Teams)
- `EmployeeDocument` — Uploaded documents with verification status
- `Skill` — Skill catalog
- `EmployeeSkill` — Employee skill mapping with proficiency
- `Team` — Cross-functional teams
- `EmployeeTeam` — Employee ↔ team mapping
- `BiometricEmployeeMapping` — Employee ↔ biometric device mapping

**Key Features:**
- Multiple employment types (Full-time, Part-time, Contract, Intern)
- Primary and secondary relationships
- Split department allocation with percentage
- Skill proficiency tracking

**Dependencies**: `shared`, `time`, `workflow`

---

### 5. attendance — Time & Attendance Service

**Purpose**: Leave management, shift scheduling, roster management, and holiday calendars.

**Tables:**
- `AttendanceStatus` — Present, Absent, On Leave, WFH, Late
- `AttendanceRecord` — Daily attendance with check-in/out times
- `AttendanceLog` — Raw biometric punches
- `MobileAttendanceLog` — GPS-based mobile attendance
- `LeaveType` — Leave categories with accrual rules
- `LeaveRequest` — Leave applications with approval workflow
- `LeaveBalance` — Annual leave balances per employee
- `CompOffType` — Comp-off categories
- `CompOffBalance` — Earned/availed comp-off tracking
- `AttendanceRegularization` — Attendance correction requests
- `Shift` — Shift timing configuration
- `ShiftAssignment` — Shift ↔ scope assignment
- `ShiftSwapStatus` — Shift swap status lookup
- `ShiftSwapRequest` — Shift swap requests
- `RotationShift` — Cyclic rotation schedules
- `RotationShiftDetail` — Rotation sequence
- `RotationShiftAssignment` — Rotation ↔ scope assignment
- `EmployeeShiftRoster` — Daily employee schedules
- `HolidayCalendar` — Named holiday calendars
- `HolidayType` — National, Regional, Optional holidays
- `Holiday` — Individual holiday entries
- `HolidayCalendarAssignment` — Calendar ↔ scope assignment
- `WorkWeekPolicy` — Work week templates (Mon-Fri, Sun-Thu)
- `WorkWeekPolicyDay` — Per-day working rules
- `WorkWeekPolicyAssignment` — Policy ↔ scope assignment

**Key Features:**
- Half-day leave support
- Overtime tracking
- Shift swap with approval workflow
- Rotation shifts for cyclic scheduling
- Scope-based holiday calendar assignment

**Dependencies**: `shared`, `employee`, `time`, `workflow`

---

### 6. hr — HR Services

**Purpose**: Complete HR lifecycle management from recruitment to exit.

**Tables:**
- `InterviewRound` — Interview stages (HR Screen, Technical, Manager)
- `PanelRole` — Panel lead, interviewer, observer
- `JobPosting` — Job requisitions with status tracking
- `Candidate` — Applicant profiles
- `Application` — Job applications with pipeline status
- `ApplicationStatusHistory` — Pipeline audit trail
- `InterviewRoundConfig` — Per-posting round configuration
- `Interview` — Scheduled interview sessions
- `InterviewPanel` — Panelist assignments
- `InterviewFeedback` — Structured scores and recommendations
- `PackageNegotiation` — Salary negotiation thread
- `OfferLetter` — Offer issuance and acceptance tracking
- `OnboardingChecklist` — Template checklists
- `OnboardingChecklistItem` — Task definitions
- `OnboardingTask` — Employee-specific onboarding tasks
- `DocumentVerification` — Document submission and verification
- `BGVAgency` — Background verification agencies
- `BackgroundVerification` — BGV status and results
- `PolicyCategory` — Policy categories (HR, IT, Finance)
- `PolicyDocument` — Policy master records
- `PolicyVersion` — Version history with file URLs
- `PolicyAcknowledgement` — Employee policy acknowledgements
- `PerformanceCycle` — Appraisal periods (Annual, Quarterly, etc.)
- `Goal` — Employee goals (OKR-style)
- `GoalKeyResult` — Measurable outcomes
- `PerformanceReview` — Formal review records
- `PerformanceReviewHistory` — Status audit trail
- `TrainingProgram` — Course definitions
- `TrainingBatch` — Scheduled training cohorts
- `EmployeeTrainingRecord` — Enrollment and completion tracking
- `ExitRecord` — Departure process with clearance status
- `ExitClearanceItem` — Clearance checklist items

**Key Features:**
- Full recruitment pipeline (Apply → Interview → Offer → Hired)
- Multi-stage interview process with structured feedback
- Onboarding task tracking with phase-based workflows
- Policy version management with acknowledgement tracking
- OKR-style goal setting with key results
- Training program enrollment and completion certificates
- Exit clearance with department-wise tasks

**Dependencies**: `shared`, `employee`, `time`, `workflow`

---

### 7. payroll — Payroll Service

**Purpose**: Salary processing, tax calculations, and bank disbursement.

**Tables:**
- `TaxProofCategory` — IT declaration sections (80C, 80D, etc.)
- `SalaryGrade` — Pay bands/grades
- `SalaryStructure` — Salary templates per legal entity
- `PayrollComponent` — Basic, HRA, PF, etc.
- `SalaryStructureComponent` — Component computation rules
- `PayrollAttendanceSummary` — Monthly attendance aggregates
- `EmployeeSalary` — CTC, gross, net records with effective dates
- `EmployeeSalaryComponent` — Per-month component values
- `SalaryRevision` — Compensation change history
- `BankMaster` — Bank reference data
- `EmployeeBankAccount` — Employee bank details
- `PayrollDisbursement` — Monthly salary batch
- `PayrollDisbursementTransaction` — Per-employee credit transactions
- `TaxRegime` — Old/New tax regime definitions
- `TaxSlab` — Tax bracket configuration
- `EmployeeTaxDeclaration` — Annual declarations
- `TaxDeclarationItem` — Section-wise breakdown
- `TaxDeclarationProof` — Uploaded proof documents
- `EmployeeTaxDeduction` — Monthly TDS records
- `TaxDeductionBreakdown` — TDS line-item detail
- `SalarySlipPublication` — Payslip PDF artefact

**Key Features:**
- Multiple salary structures per legal entity
- Component-based salary calculation (Fixed, Percentage, Formula)
- Time-bound salary records (effective dates)
- Tax regime support (Old vs New)
- Monthly payroll disbursement with transaction status
- Salary slip generation linked to disbursement

**Dependencies**: `shared`, `employee`, `time`

---

### 8. helpdesk — IT Support Service

**Purpose**: Ticket management, SLA tracking, asset inventory, and software licensing.

**Tables:**
- `TicketCategory` — Hardware, Software, Network, Access, etc.
- `SupportGroup` — IT team definitions
- `AssetCategory` — Laptop, Desktop, Mobile, Server, etc.
- `Vendor` — Hardware/software vendors
- `Ticket` — Support requests with priority and status
- `TicketComment` — Communication history
- `TicketAttachment` — Evidence files
- `SlaPolicy` — Response/resolution timelines per priority
- `TicketSlaTracking` — SLA compliance tracking
- `Asset` — Inventory with status tracking
- `AssetAssignment` — Employee ↔ asset mapping
- `AssetMaintenance` — Repair and maintenance records
- `SoftwareProduct` — Software catalog
- `SoftwareLicense` — License keys and subscriptions
- `SoftwareInstallation` — Deployment tracking

**Key Features:**
- Ticket lifecycle with priority levels (Critical, High, Medium, Low)
- SLA tracking with response and resolution due times
- Asset lifecycle (Available → In Use → Under Repair → Retired)
- Software license utilization tracking

**Dependencies**: `shared`, `employee`, `time`

---

## Execution Order & Dependencies

```
┌─────────────────────────────────────────────────────────────────────┐
│ Phase 1: Foundational (No dependencies)                              │
├─────────────────────────────────────────────────────────────────────┤
│  1. shared        ──► StatusLookup (60+ status codes)              │
│  2. time          ──► Locations, departments, devices                │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│ Phase 2: Core Services                                              │
├─────────────────────────────────────────────────────────────────────┤
│  3. workflow      ──► Approval engine (needs employee for approvers)│
│  4. employee     ──► Employee core (needs time for locations)      │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│ Phase 3: Business Services                                          │
├─────────────────────────────────────────────────────────────────────┤
│  5. attendance   ──► Leave, shift, holiday (needs employee, workflow)│
│  6. hr          ──► HR lifecycle (needs employee, workflow)        │
│  7. payroll     ──► Salary, tax (needs employee, time)            │
│  8. helpdesk    ──► IT support (needs employee, time)             │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Cross-Service References

| Service | References |
|---------|------------|
| `shared` | None (foundational) |
| `time` | None |
| `workflow` | `employee.Employee`, `time.ScopeType` |
| `employee` | `time.Designation`, `time.OfficeLocation`, `time.LegalEntity`, `time.Department`, `time.DocumentType`, `shared.StatusLookup`, `workflow.WorkflowInstance`, `hr.BiometricDevice` |
| `attendance` | `employee.Employee`, `time.Shift`, `time.ScopeType`, `shared.StatusLookup`, `workflow.WorkflowInstance`, `hr.GeoFence`, `attendance.*` |
| `hr` | `employee.Employee`, `time.Department`, `time.Designation`, `time.OfficeLocation`, `time.LegalEntity`, `time.DocumentType`, `time.ScopeType`, `shared.StatusLookup`, `workflow.WorkflowInstance` |
| `payroll` | `employee.Employee`, `time.LegalEntity`, `shared.StatusLookup` |
| `helpdesk` | `employee.Employee`, `time.OfficeLocation`, `time.Department`, `shared.StatusLookup` |

---

## Database Patterns

### 1. Status Code Pattern (Domain Isolation)
All status columns use composite foreign keys:
```sql
StatusCode      NVARCHAR(50) NOT NULL,
StatusGroup     AS CAST('STATUS_GROUP_NAME' AS NVARCHAR(50)) PERSISTED,
CONSTRAINT FK_Table_Status
    FOREIGN KEY (StatusCode, StatusGroup)
    REFERENCES shared.StatusLookup(StatusCode, StatusGroup)
```

### 2. Audit Trail Pattern
```sql
CreatedAt   DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
UpdatedAt   DATETIME2 NULL,
```

### 3. Soft Delete Pattern
```sql
IsActive    BIT NOT NULL DEFAULT 1
```

### 4. Computed Columns
```sql
TotalDays   AS (OpeningBalance + Allocated - Availed - Encashed)
```

---

## File Structure

```
database/microservices/
├── 00-migration.sql    # Master migration script (run order: 1→8)
├── 01-shared.sql       # Cross-cutting status codes
├── 02-time.sql         # Infrastructure (time, location, device)
├── 03-workflow.sql      # Workflow engine
├── 04-employee.sql      # Employee core data
├── 05-attendance.sql   # Time & attendance
├── 06-hr.sql           # HR lifecycle
├── 07-payroll.sql      # Payroll processing
├── 08-helpdesk.sql     # IT support
└── README.md           # This file
```

---

## Usage

### Run Full Migration
```sql
-- Execute from database/microservices folder
:rx 00-migration.sql
```

### Verify Schema Creation
```sql
SELECT schema_name, COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema IN ('shared','time','workflow','employee','attendance','hr','payroll','helpdesk')
  AND table_type = 'BASE TABLE'
GROUP BY schema_name
ORDER BY schema_name;
```

---

## Future Enhancements

- Schema-level security (schemas as security boundaries)
- Event sourcing for inter-service communication
- Read replicas for reporting workloads
- Further decomposition for true microservices deployment