## Refresh Token Cleanup Jobs by SQL Server Agents
``` SQL
DELETE FROM [dbo].[RefreshTokens]
WHERE [ExpiresAt] < SYSDATETIMEOFFSET()
  AND [RevokedAt] IS NOT NULL
```