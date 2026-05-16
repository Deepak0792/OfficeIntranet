PRINT 'Starting Base Schema deployment...';

-- Schema Changes (in dependency order)
/*
 * Base Schema Migration - Include Script
 * 
 * This script migrates all existing database objects from docs/database/microservices
 * into the SSDT project structure without modification.
 * 
 * Execution Order (matches dependency graph):
 *   1. 00-migration.sql  - Master migration orchestrator
 *   2. 01-shared.sql     - Foundational status lookup
 *   3. 02-time.sql       - Infrastructure (time, location, organization)
 *   4. 03-workflow.sql   - Workflow engine
 *   5. 04-employee.sql   - Employee core data
 *   6. 05-attendance.sql - Time & attendance
 *   7. 06-hr.sql         - HR lifecycle
 *   8. 07-payroll.sql    - Payroll processing
 *   9. 08-helpdesk.sql   - IT support
 *  10. 09-auth.sql       - Authentication & authorization
 *  11. 10-event.sql      - Event sourcing
 *  12. 11-survey.sql     - Survey management
 *  13. 12-audit.sql      - Audit logging
 * 
 * Note: These scripts are executed as-is from the original migration files.
 * No restructuring is applied at this level.
 */

:r 00-migration.sql

PRINT 'Base Schema deployment completed successfully';
GO
