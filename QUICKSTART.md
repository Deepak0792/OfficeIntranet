# SdxCore Gateway Quick Start Guide

This guide will help you quickly set up and test the SdxCore Gateway with authentication.

## Prerequisites

- .NET 9.0 SDK
- SQL Server (LocalDB or full instance)
- Visual Studio 2022 or VS Code

## Quick Setup

### 1. Clone and Build

```bash
# Build the solution
dotnet build SdxCore.sln

# Or build individual projects
dotnet build src/Services/Identity/SdxCore.Identity.API/SdxCore.Identity.API.csproj
dotnet build src/Gateway/SdxCore.Gateway.API/SdxCore.Gateway.API.csproj
```

### 2. Configure Database

The Identity service uses SQL Server. Update the connection string in `src/Services/Identity/SdxCore.Identity.API/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=SdxCoreIdentity;Trusted_Connection=true;MultipleActiveResultSets=true"
  }
}
```

### 3. Run Database Migrations

```bash
cd src/Services/Identity/SdxCore.Identity.API
dotnet ef database update
```

### 4. Start Services

**Terminal 1 - Identity Service:**
```bash
cd src/Services/Identity/SdxCore.Identity.API
dotnet run
```
*Identity service will run on https://localhost:5001*

**Terminal 2 - Gateway:**
```bash
cd src/Gateway/SdxCore.Gateway.API
dotnet run
```
*Gateway will run on https://localhost:5000*

## Testing the Setup

### 1. Test Health Endpoints

```bash
# Gateway health
curl https://localhost:5000/health

# Identity service health (through Gateway)
curl https://localhost:5000/api/auth/login -X POST -H "Content-Type: application/json" -d "{}"
```

### 2. Create a Test User

First, you'll need to create a user in the database. You can do this through the Identity service or by running SQL directly:

```sql
INSERT INTO Users (Id, Username, Email, PasswordHash, IsActive, CreatedAt, FailedAttempts)
VALUES (
    NEWID(),
    'testuser',
    'test@example.com',
    '$argon2id$v=19$m=65536,t=3,p=1$SALT$HASH', -- You'll need to generate this
    1,
    GETUTCDATE(),
    0
);
```

### 3. Test Authentication Flow

**Step 1: Login to get a token**
```bash
curl -X POST https://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "testpassword"
  }'
```

**Expected Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresAt": "2026-05-01T11:30:00Z"
}
```

**Step 2: Use the token for protected endpoints**
```bash
curl -X GET https://localhost:5000/api/auth/test-protected \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "message": "Token is valid",
  "timestamp": "2026-05-01T10:30:00Z"
}
```

**Note:** When the Gateway forwards this request to the Identity service, it will automatically add an `X-User-Id` header containing the user's ID extracted from the JWT token. The downstream service can access this header to know which user is making the request.

### 4. Test Public Endpoints

Public endpoints work without authentication:

```bash
# Health check (always public)
curl https://localhost:5000/health

# Any route configured as public
curl https://localhost:5000/api/public/status
```

## Configuration Examples

### Adding a New Microservice

1. **Add route configuration to Gateway** (`src/Gateway/SdxCore.Gateway.API/appsettings.json`):

```json
{
  "ReverseProxy": {
    "Routes": {
      "my-service-route": {
        "ClusterId": "my-service-cluster",
        "Match": {
          "Path": "/api/myservice/{**catch-all}"
        }
      }
    },
    "Clusters": {
      "my-service-cluster": {
        "Destinations": {
          "my-service-api": {
            "Address": "https://localhost:5010"
          }
        }
      }
    }
  }
}
```

2. **Start your service** on the configured port (5010 in this example)

3. **Test the routing**:
```bash
curl https://localhost:5000/api/myservice/test \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Note:** The Gateway will automatically add an `X-User-Id` header to the forwarded request, so your service can access the user context like this:

```csharp
[HttpGet("test")]
public IActionResult Test()
{
    var userId = Request.Headers["X-User-Id"].FirstOrDefault();
    return Ok(new { Message = "Hello", UserId = userId });
}
```

### Making Routes Public

To make certain routes public (no authentication required), add them to the `PublicRoutes` array:

```json
{
  "Authentication": {
    "PublicRoutes": [
      "/health",
      "/api/auth/login",
      "/api/myservice/public/*",
      "/api/catalog/products"
    ]
  }
}
```

## Common Issues and Solutions

### Issue: "Authentication protocol is not configured"

**Solution:** Ensure the Identity service has the authentication protocol configured:

```json
{
  "Authentication": {
    "Protocol": "InHouse"
  }
}
```

### Issue: "Token validation failed"

**Possible causes:**
1. Token is expired
2. Token signature is invalid
3. Identity service is not running
4. Wrong `IdentityServiceUrl` in Gateway configuration

**Solution:** Check the Gateway logs and verify the Identity service is accessible.

### Issue: "Route not found"

**Possible causes:**
1. Route not configured in Gateway
2. Destination service not running
3. Wrong port configuration

**Solution:** Verify the route configuration and ensure the destination service is running.

## Development Tips

### 1. Use the HTTP Files

Both projects include `.http` files for testing:
- `src/Gateway/SdxCore.Gateway.API/SdxCore.Gateway.API.http`
- `src/Services/Identity/SdxCore.Identity.API/SdxCore.Identity.API.http`

### 2. Enable Debug Logging

For troubleshooting, enable debug logging in `appsettings.Development.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "SdxCore.Gateway.API.Middleware": "Debug",
      "Yarp": "Debug"
    }
  }
}
```

### 3. Use Environment-Specific Configuration

- `appsettings.Development.json` - Local development
- `appsettings.Production.json` - Production deployment

### 4. Monitor Health Endpoints

Both services provide health endpoints:
- Gateway: `https://localhost:5000/health`
- Identity: `https://localhost:5001/health`

## Next Steps

1. **Add your microservices** and configure routing
2. **Implement business logic** in your services
3. **Configure authentication providers** (SAML, OAuth, etc.) as needed
4. **Set up monitoring and logging** for production
5. **Implement CI/CD pipelines** for deployment

## Production Considerations

### Security
- Use HTTPS in production
- Configure proper CORS policies
- Implement rate limiting
- Use strong JWT signing keys
- Regular security audits

### Performance
- Configure connection pooling
- Implement caching where appropriate
- Monitor and optimize token validation
- Use load balancing for high availability

### Monitoring
- Implement comprehensive logging
- Set up health checks
- Monitor authentication metrics
- Alert on security events

For more detailed information, see:
- [Authentication Flow Documentation](AUTHENTICATION_FLOW.md)
- [Gateway README](src/Gateway/README.md)
- [Requirements Document](.kiro/specs/authentication-module/requirements.md)