PRINT 'Sprint01 Starting deployment...';
-- Schema Changes (in dependency order)
SET NOCOUNT ON;
BEGIN TRANSACTION;

:r .\attendance\_include.sql

COMMIT TRANSACTION;

PRINT 'Sprint01 deployment completed successfully';
GO
