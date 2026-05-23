# SdxCore Database & Schema Architecture

The SdxCore ecosystem utilizes a **Multi-Schema Database Architecture**. Rather than deploying a physical SQL Server database for every single microservice (which introduces heavy cross-database transaction latency and orchestration complexity), the system uses **SQL Schemas** to logically isolate data domains within a single centralized database (`SdxCore DB`).

> **Note**: The `Identity.API` is the only exception to this rule. It uses a completely separate physical database (`SdxCoreIdentity`) to guarantee the highest level of security isolation for credential hashes and OAuth tokens.

---

## 🏛️ Schema to Microservice Mapping

Each schema in this database represents a strict **Bounded Context**. In our microservices architecture, a single schema maps directly to a specific microservice's Entity Framework Core `DbContext`. 

**Microservices are strictly forbidden from querying tables outside of their designated schema.** Cross-domain data needs must be resolved via Gateway-routed HTTP calls or asynchronous event messaging.

### Core Schemas

| Schema | Purpose / Domain | Corresponding Microservice (Future/Current) |
| :--- | :--- | :--- |
| **`[dbo]` / `[migration]`** | Database deployment state, EF Core `__EFMigrationsHistory`, and SSDT sprint execution logs. | *(Infrastructure)* |
| **`[shared]`** | Global configurations, application-wide enums, and centralized lookups (e.g., States, Currencies). | `Shared.API` |
| **`[time]`** | Organizational hierarchies (Regions, Departments), Geofences, and Biometric Device configurations. | `Time.API` |
| **`[auth]`** | Application-level RBAC (Role-Based Access Control) mapping, feature toggles, and UI permissions (distinct from Identity JWT generation). | `Identity.API` (Integration) |

### Human Resources & Workforce Schemas

| Schema | Purpose / Domain | Corresponding Microservice (Future/Current) |
| :--- | :--- | :--- |
| **`[employee]`** | Employee master data, personal profiles, job history, and employment status. | `Employee.API` |
| **`[attendance]`** | Shift scheduling, rosters, physical check-ins/outs, and calculated timesheets. | `Attendance.API` |
| **`[hr]`** | Leave management, performance reviews, onboarding/offboarding workflows, and compliance. | `HR.API` |
| **`[payroll]`** | Salary structures, tax calculations, deductions, benefits, and payslip generation. | `Payroll.API` |
| **`[expense]`** | Employee expense claims, receipt attachments, and budget tracking. | `Expense.API` |

### Cross-Cutting & Utility Schemas

| Schema | Purpose / Domain | Corresponding Microservice (Future/Current) |
| :--- | :--- | :--- |
| **`[workflow]`** | Multi-stage approval engine. Defines routing rules, escalation matrices, and generic approval requests. | `Workflow.API` |
| **`[helpdesk]`** | Internal IT/HR ticketing, SLAs, issue tracking, and resolution threads. | `Helpdesk.API` |
| **`[survey]`** | Employee engagement, eNPS, custom questionnaires, and feedback loops. | `Survey.API` |
| **`[event]`** | Outbox pattern tables, system-wide notifications, and webhook delivery logs. | `Notification.API` |
| **`[audit]`** | Deep forensic tracking. Stores `BulkOperationLogs`, data export tracking, and cross-cutting auditable events. | *(Observability/Admin)* |

---

## 🔒 Design Constraints & Guidelines

If you are developing a new feature or microservice, you must adhere to the following database rules:

1. **Strict Schema Isolation**: The `Time.API` microservice's `TimeDbContext` is configured with `modelBuilder.HasDefaultSchema("time");`. It cannot include `DbSet<Employee>`. If Time needs Employee data, it must make an API request or consume an event.
2. **No Foreign Keys Across Schemas**: Because schemas represent microservice boundaries that might eventually be split into separate physical databases, **foreign keys across schemas are highly discouraged**. Use soft-references (e.g., storing an `int EmployeeId` in the `[attendance].[Timesheet]` table without a hard SQL constraint to `[employee].[Employees]`).
3. **Automated Auditing**: All business tables across all schemas must include the standard SdxCore audit columns (`CreatedAt`, `CreatedBy`, `LastUpdatedAt`, `LastUpdatedBy`, `IsActive`). These are managed automatically by the `BaseRepository` in C#.
4. **Deployments**: This database is deployed using the custom PowerShell SSDT generator. Do not run manual `ALTER` scripts on production. Ensure your changes are tracked in the appropriate Sprint folder. (See `BuildREADME.md`).
