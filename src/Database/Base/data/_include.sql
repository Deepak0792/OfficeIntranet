PRINT 'Starting Base Schema Seed Data deployment...';

-- Schema Changes (in dependency order)
:r .\shared\seed-data.sql
:r .\time\seed-data.sql
:r .\workflow\seed-data.sql
:r .\employee\seed-data.sql
:r .\attendance\seed-data.sql
:r .\hr\seed-data.sql
:r .\payroll\seed-data.sql
:r .\helpdesk\seed-data.sql
:r .\auth\seed-data.sql
:r .\expense\seed-data.sql

PRINT 'Base Schema Seed Data deployment completed successfully';
GO
