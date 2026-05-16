PRINT 'Base Starting schema migration...';

SET NOCOUNT ON;
BEGIN TRANSACTION;

:r .\schema\_include.sql
:r .\data\_include.sql

COMMIT TRANSACTION;

PRINT 'Base schema migration completed successfully';
GO
