# SdxCore Authentication Module

A comprehensive, pluggable authentication module for C# .NET Core applications with microservices architecture. Supports multiple authentication protocols through a unified provider abstraction pattern.

## Architecture Overview

The solution follows Clean Architecture principles with clear separation of concerns:

```
Client → SdxCore.Gateway (YARP) → SdxCore.Identity.API → Application → Domain
                                                                        ↑
                                                                   Persistence
```

### Project Structure

```
SdxCore.sln
├── src/
│   ├── Gateway/
│   │   └── SdxCore.Gateway.API          # YARP reverse proxy (entry point)
│   ├── Services/
│   │   └── Identity/
│   │       ├── SdxCore.Identity.API     # Web API controllers and middleware
│   │       ├── SdxCore.Identity.Application  # Business logic and services
│   │       ├── SdxCore.Identity.Domain  # Domain entities and interfaces
│   │       └── SdxCore.Identity.Persistence  # EF Core and SQL Server
│   └── BuildingBlocks/                  # Shared libraries (future use)
│       ├── SdxCore.SharedKernel
│       ├── SdxCore.Common
│       └── SdxCore.Contracts
├── tests/
│   └── Identity.Tests/                  # Unit, integration, and property tests
└── docker/
    └── docker-compose.yml               # Container orchestration
```

## Supported Authentication Protocols

- **InHouse**: Built-in username/password with SQL Server storage
- **SAML 2.0**: Enterprise SSO with assertion validation
- **OAuth 2.0**: Authorization code flow with PKCE support
- **OpenID Connect**: ID token validation
- **JWT**: Bearer token validation
- **LDAP**: Active Directory and LDAP server authentication

## Configuration Requirements

### Gateway (SdxCore.Gateway.API)

**appsettings.json:**
```json
{
  "ReverseProxy": {
    "Routes": {
      "identity-route": {
        "ClusterId": "identity-cluster",
        "Match": { "Path": "/api/auth/{**catch-all}" }
      }
    },
    "Clusters": {
      "identity-cluster": {
        "Destinations": {
          "identity-api": { "Address": "https://localhost:5001" }
        }
      }
    }
  }
}
```

### Identity API (SdxCore.Identity.API)

**Required Configuration Sections:**

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=SdxCoreIdentity;Trusted_Connection=true;TrustServerCertificate=true;"
  },
  "Authentication": {
    "Protocol": "InHouse",
    "Issuer": "SdxCore.Identity",
    "Audience": "SdxCore.API",
    "TokenLifetime": "01:00:00",
    "MaxFailedAttempts": 5,
    "LockoutDuration": "00:15:00",
    "SigningKeyPath": "keys/signing-key.json"
  }
}
```

**Protocol-Specific Sections:**

- **SAML**: `"Saml": { "IdpMetadataUrl": "...", "ServiceProviderEntityId": "..." }`
- **OAuth**: `"OAuth": { "ClientId": "...", "ClientSecret": "...", "AuthorityUrl": "..." }`
- **OIDC**: `"Oidc": { "Authority": "...", "ClientId": "...", "ClientSecret": "..." }`
- **LDAP**: `"Ldap": { "Server": "ldaps://...", "BaseDn": "...", "BindDn": "..." }`

## Running Locally

### Prerequisites

- .NET 9.0 SDK
- SQL Server (LocalDB, Docker, or full instance)
- Docker (optional, for containerized SQL Server)

### Step 1: Start SQL Server

**Option A: Docker**
```bash
cd docker
docker-compose up sql-server -d
```

**Option B: LocalDB**
```bash
# Update connection string in appsettings.Development.json to use LocalDB
```

### Step 2: Run Database Migrations

```bash
dotnet ef database update \
  --project src/Services/Identity/SdxCore.Identity.Persistence \
  --startup-project src/Services/Identity/SdxCore.Identity.API
```

### Step 3: Start Identity API

```bash
dotnet run --project src/Services/Identity/SdxCore.Identity.API
# Runs on https://localhost:5001
```

### Step 4: Start Gateway

```bash
dotnet run --project src/Gateway/SdxCore.Gateway.API
# Runs on https://localhost:5000
```

### Step 5: Test Authentication

```bash
# Create a test user (InHouse protocol)
curl -X POST https://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "TestPassword123!"}'
```

## Switching Authentication Protocols

Change the protocol by updating `appsettings.json`:

```json
{
  "Authentication": {
    "Protocol": "Saml"  // Change to: InHouse, Saml, OAuth, Oidc, Jwt, Ldap
  }
}
```

**Important**: You must register the corresponding provider in `Program.cs`:

```csharp
var protocol = builder.Configuration["Authentication:Protocol"];
switch (protocol?.ToLowerInvariant())
{
    case "inhouse":
        builder.Services.AddInHouseProvider();
        break;
    case "saml":
        builder.Services.AddSamlProvider(builder.Configuration);
        break;
    // ... other protocols
}
```

## Docker Compose Usage

### Full Stack Deployment

```bash
cd docker
cp .env.example .env
# Edit .env with your configuration
docker-compose up -d
```

**Services:**
- **sql-server**: SQL Server 2022 database
- **identity-api**: Identity service API
- **gateway**: YARP reverse proxy gateway

### Development with External Database

```bash
# Start only SQL Server
docker-compose up sql-server -d

# Run APIs locally for debugging
dotnet run --project src/Services/Identity/SdxCore.Identity.API
dotnet run --project src/Gateway/SdxCore.Gateway.API
```

## Testing

### Run All Tests

```bash
dotnet test tests/Identity.Tests/
```

### Test Categories

- **Unit Tests**: Individual component testing
- **Integration Tests**: API endpoints with test database
- **Property Tests**: FsCheck-based correctness validation
- **End-to-End Tests**: Full Gateway → API → Database flow

## Security Features

- **Argon2id Password Hashing**: Industry-standard with configurable parameters
- **JWT Token Management**: RS256/HS256 signing with revocation support
- **Account Lockout**: Configurable failed attempt thresholds
- **Audit Logging**: All authentication attempts logged to SQL Server
- **LDAPS Enforcement**: Encrypted LDAP connections by default
- **User Enumeration Prevention**: Generic error messages

## Configuration Validation

The system enforces explicit configuration:

- **No Default Protocols**: Must specify `Authentication:Protocol`
- **Provider Registration**: Must register the configured provider
- **Configuration Exceptions**: Clear error messages for missing/invalid config
- **Environment Overrides**: Support for Development/Production settings

## Troubleshooting

### Common Issues

1. **"Authentication protocol not configured"**
   - Add `"Authentication:Protocol"` to appsettings.json

2. **"Provider not registered"**
   - Register the provider in Program.cs startup

3. **Database connection errors**
   - Verify connection string and SQL Server availability
   - Run migrations: `dotnet ef database update`

4. **Token validation failures**
   - Check signing key configuration
   - Verify token expiry settings

### Logs

Enable detailed logging in appsettings.json:

```json
{
  "Logging": {
    "LogLevel": {
      "SdxCore.Identity": "Debug",
      "Microsoft.EntityFrameworkCore": "Information"
    }
  }
}
```

## Contributing

1. Follow Clean Architecture principles
2. Add property tests for new algorithms
3. Update integration tests for new endpoints
4. Document configuration requirements
5. Maintain SOLID principles compliance

## License

[Your License Here]