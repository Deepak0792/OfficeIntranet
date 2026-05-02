# End-to-End Verification Scripts

This directory contains scripts to verify the complete authentication flow of the SdxCore Authentication Module.

## Scripts

- `verify-e2e.ps1` - PowerShell script for Windows
- `verify-e2e.sh` - Bash script for Linux/macOS
- `README.md` - This file

## Prerequisites

Before running the verification scripts, ensure:

1. **SQL Server is running**
   ```bash
   # Using Docker
   cd docker
   docker-compose up sql-server -d
   
   # Or use LocalDB/SQL Server instance
   ```

2. **Database migrations applied**
   ```bash
   dotnet ef database update \
     --project src/Services/Identity/SdxCore.Identity.Persistence \
     --startup-project src/Services/Identity/SdxCore.Identity.API
   ```

3. **Services are running**
   ```bash
   # Terminal 1: Identity API
   dotnet run --project src/Services/Identity/SdxCore.Identity.API
   
   # Terminal 2: Gateway
   dotnet run --project src/Gateway/SdxCore.Gateway.API
   ```

## Usage

### Windows (PowerShell)
```powershell
# Basic verification
.\scripts\verify-e2e.ps1

# With custom URLs
.\scripts\verify-e2e.ps1 -Protocol "InHouse" -GatewayUrl "http://localhost:5000" -IdentityUrl "http://localhost:5001"
```

### Linux/macOS (Bash)
```bash
# Make executable (Linux/macOS only)
chmod +x scripts/verify-e2e.sh

# Basic verification
./scripts/verify-e2e.sh

# With custom parameters
./scripts/verify-e2e.sh "InHouse" "http://localhost:5000" "http://localhost:5001"
```

## What the Scripts Test

1. **Service Health Checks**
   - Verifies Identity API is responding
   - Verifies Gateway is responding

2. **Direct Authentication**
   - Tests authentication directly against Identity API
   - Uses test credentials (testuser/TestPassword123!)

3. **Gateway Authentication**
   - Tests authentication through the Gateway
   - Verifies YARP routing is working

4. **Token Validation**
   - Validates issued JWT tokens
   - Tests token middleware

5. **Configuration Verification**
   - Checks current authentication protocol
   - Provides guidance on protocol switching

## Expected Results

### Successful Run
```
=== SdxCore Authentication Module E2E Verification ===
✓ Identity API is healthy
✓ Gateway is healthy
✓ Authentication successful
✓ Token validation successful
✓ End-to-end flow verification successful!
```

### Common Issues

1. **Services not responding**
   - Ensure services are running on correct ports
   - Check firewall settings
   - Verify appsettings.json configuration

2. **Authentication failures**
   - For InHouse protocol: Create test user first
   - For external protocols: Verify provider configuration
   - Check database connectivity

3. **Token validation failures**
   - Verify signing key configuration
   - Check token expiry settings
   - Ensure middleware is properly configured

## Creating Test Users (InHouse Protocol)

For the InHouse protocol, you'll need to create test users. This can be done through:

1. **Integration Tests** (recommended)
   ```bash
   dotnet test tests/Identity.Tests/ --filter "Category=Integration"
   ```

2. **Direct Database Insert** (for testing only)
   ```sql
   -- Note: Use proper password hashing in production
   INSERT INTO Users (Id, Username, PasswordHash, Email, IsActive, CreatedAt)
   VALUES (NEWID(), 'testuser', '[Argon2id hash]', 'test@example.com', 1, GETUTCDATE())
   ```

3. **API Endpoint** (if implemented)
   ```bash
   curl -X POST http://localhost:5001/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser","password":"TestPassword123!","email":"test@example.com"}'
   ```

## Protocol Switching

To test different protocols:

1. Update `appsettings.json`:
   ```json
   {
     "Authentication": {
       "Protocol": "Saml"  // Change to: InHouse, Saml, OAuth, Oidc, Jwt, Ldap
     }
   }
   ```

2. Restart the Identity API service

3. Run the verification script again

4. Ensure the corresponding provider is registered in `Program.cs`