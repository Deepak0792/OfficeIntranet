-- =============================================================================================================
-- OFFICE INTRANET - MICROSERVICES MIGRATION SCRIPT
-- Runs all schema scripts in the correct dependency order
-- =============================================================================================================
-- Execution Order:
--   1. 01-shared.sql      - StatusLookup (foundational)
--   2. 02-time.sql       - Time zones, locations, departments, biometric
--   3. 03-employee.sql   - Core employee data (references time, shared)
--   4. 07-workflow.sql   - Workflow engine (references employee, time, shared)
--   5. 04-attendance.sql - Leave, shift, holiday (references employee, workflow, time, shared)
--   6. 05-hr.sql         - HR lifecycle (references employee, workflow, time, shared)
--   7. 06-payroll.sql    - Payroll (references employee, time, shared)
--   8. 08-helpdesk.sql   - IT support (references employee, time, shared)
-- =============================================================================================================

PRINT '========================================';
PRINT 'Starting Office Intranet Migration';
PRINT '========================================';
PRINT '';

-- =============================================================================================================
-- STEP 1: Create Shared Schema (StatusLookup)
-- =============================================================================================================
PRINT 'Step 1: Creating Shared Schema...';
GO
:r 01-shared.sql
GO

-- =============================================================================================================
-- STEP 2: Create Time Schema
-- =============================================================================================================
PRINT 'Step 2: Creating Time Schema...';
GO
:r 02-time.sql
GO

-- =============================================================================================================
-- STEP 3: Create Workflow Schema
-- =============================================================================================================
PRINT 'Step 3: Creating Workflow Schema...';
GO
:r 03-workflow.sql
GO

-- =============================================================================================================
-- STEP 4: Create Employee Schema
-- =============================================================================================================
PRINT 'Step 4: Creating Employee Schema...';
GO
:r 04-employee.sql
GO

-- =============================================================================================================
-- STEP 5: Create Attendance Schema
-- =============================================================================================================
PRINT 'Step 5: Creating Attendance Schema...';
GO
:r 05-attendance.sql
GO

-- =============================================================================================================
-- STEP 6: Create HR Schema
-- =============================================================================================================
PRINT 'Step 6: Creating HR Schema...';
GO
:r 06-hr.sql
GO

-- =============================================================================================================
-- STEP 7: Create Payroll Schema
-- =============================================================================================================
PRINT 'Step 7: Creating Payroll Schema...';
GO
:r 07-payroll.sql
GO

-- =============================================================================================================
-- STEP 8: Create Helpdesk Schema
-- =============================================================================================================
PRINT 'Step 8: Creating Helpdesk Schema...';
GO
:r 08-helpdesk.sql
GO

-- =============================================================================================================
-- VERIFICATION
-- =============================================================================================================
PRINT '';
PRINT '========================================';
PRINT 'Migration Complete - Verification';
PRINT '========================================';

SELECT
    schema_name AS SchemaName,
    COUNT(*) AS TableCount
FROM information_schema.tables
WHERE table_schema IN ('shared', 'time', 'employee', 'workflow', 'attendance', 'hr', 'payroll', 'helpdesk')
  AND table_type = 'BASE TABLE'
GROUP BY schema_name
ORDER BY schema_name;

PRINT '';
PRINT 'All 8 schemas created successfully!';
PRINT 'Microservices Architecture Setup Complete';
GO