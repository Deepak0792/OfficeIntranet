# Implementation Plan: Authentication Module

## Overview

This implementation plan breaks down the authentication module into discrete coding tasks following Clean Architecture principles. The solution follows a microservices architecture with proper folder organization.

**Solution Structure:**
```
SdxCore.sln
├── src/
│   ├── Gateway/
│   │   └── SdxCore.Gateway.API (YARP reverse proxy)
│   ├── Services/
│   │   └── Identity/
│   │       ├── SdxCore.Identity.API
│   │       ├── SdxCore.Identity.Application
│   │       ├── SdxCore.Identity.Domain
│   │       └── SdxCore.Identity.Persistence
│   └── BuildingBlocks/ (shared code)
│       ├── SdxCore.SharedKernel
│       ├── SdxCore.Common
│       └── SdxCore.Contracts
├── tests/
│   └── Identity.Tests/
└── docker/
    └── docker-compose.yml
```

The implementation follows a bottom-up approach: Domain → Persistence → Application → API → Gateway, ensuring each layer is functional before building the next. Configuration is mandatory and read from appsettings.json with no fallback behavior.

## Tasks

- [ ] 1. Set up solution structure and create projects
  - [x] 1.1 Create solution and folder structure
    - Create SdxCore.sln in root directory
    - Create folder structure: src/Gateway, src/Services/Identity, src/BuildingBlocks, tests, docker
    - _Requirements: 24.1_

  - [x] 1.2 Create Gateway project
    - Create src/Gateway/SdxCore.Gateway.API (ASP.NET Core Web API)
    - Add Yarp.ReverseProxy NuGet package
    - Add project to solution under Gateway solution folder
    - _Requirements: 23.1_

  - [x] 1.3 Create Identity service projects
    - Create src/Services/Identity/SdxCore.Identity.Domain (Class Library)
    - Create src/Services/Identity/SdxCore.Identity.Application (Class Library)
    - Create src/Services/Identity/SdxCore.Identity.Persistence (Class Library)
    - Create src/Services/Identity/SdxCore.Identity.API (ASP.NET Core Web API)
    - Add projects to solution under Services/Identity solution folder
    - Set up project references: API → Application → Domain ← Persistence
    - _Requirements: 24.1, 24.2, 24.3, 24.4, 24.5_

  - [x] 1.4 Create BuildingBlocks projects (placeholders for future shared code)
    - Create src/BuildingBlocks/SdxCore.SharedKernel (Class Library)
    - Create src/BuildingBlocks/SdxCore.Common (Class Library)
    - Create src/BuildingBlocks/SdxCore.Contracts (Class Library)
    - Add projects to solution under BuildingBlocks solution folder
    - _Requirements: 24.1_

  - [x] 1.5 Create test projects
    - Create tests/Identity.Tests (xUnit Test Project)
    - Add project reference to Identity projects
    - Add NuGet packages: xUnit, Moq, FluentAssertions, FsCheck.Xunit, Testcontainers.MsSql
    - Add project to solution under tests solution folder
    - _Requirements: 24.1_

  - [x] 1.7 Create docker configuration
    - Create docker/docker-compose.yml with services: gateway, identity-api, sql-server
    - Create docker/.env.example for environment variables
    - _Requirements: 24.1_

- [ ] 2. Implement Identity Domain layer
  - [x] 2.1 Define domain entities
    - Create SdxCore.Identity.Domain/Entities/UserRecord.cs
    - Create SdxCore.Identity.Domain/Entities/AuditEvent.cs
    - _Requirements: 24.2_

  - [x] 2.2 Define domain enums
    - Create SdxCore.Identity.Domain/Enums/AuthProtocol.cs
    - _Requirements: 24.2_

  - [x] 2.3 Define domain interfaces
    - Create SdxCore.Identity.Domain/Interfaces/IAuthenticationService.cs
    - Create SdxCore.Identity.Domain/Interfaces/IAuthenticationProvider.cs
    - Create SdxCore.Identity.Domain/Interfaces/IInHouseProvider.cs
    - Create SdxCore.Identity.Domain/Interfaces/ITokenFactory.cs
    - Create SdxCore.Identity.Domain/Interfaces/IAuditLogger.cs
    - Create SdxCore.Identity.Domain/Interfaces/IUserRepository.cs
    - Create SdxCore.Identity.Domain/Interfaces/IAuditRepository.cs
    - Create SdxCore.Identity.Domain/Interfaces/IPasswordHasher.cs
    - Create SdxCore.Identity.Domain/Interfaces/IProviderRegistry.cs
    - _Requirements: 24.2, 24.10, 24.11_

  - [x] 2.4 Define DTOs
    - Create SdxCore.Identity.Domain/DTOs/AuthenticationRequest.cs
    - Create SdxCore.Identity.Domain/DTOs/AuthenticationResult.cs
    - Create SdxCore.Identity.Domain/DTOs/AuthToken.cs
    - Create SdxCore.Identity.Domain/DTOs/ProviderResult.cs
    - Create SdxCore.Identity.Domain/DTOs/CreateUserRequest.cs
    - Create SdxCore.Identity.Domain/DTOs/ChangePasswordRequest.cs
    - _Requirements: 24.2_

  - [x] 2.5 Define custom exceptions
    - Create SdxCore.Identity.Domain/Exceptions/ConfigurationException.cs
    - Create SdxCore.Identity.Domain/Exceptions/ProviderNotFoundException.cs
    - Create SdxCore.Identity.Domain/Exceptions/AuthProviderUnavailableException.cs
    - _Requirements: 24.2_

- [ ] 2. Implement persistence layer with EF Core
  - [x] 2.1 Add required NuGet packages to Persistence project
    - Add Microsoft.EntityFrameworkCore.SqlServer
    - Add Microsoft.EntityFrameworkCore.Design
    - Add Microsoft.Extensions.Configuration.Abstractions
    - _Requirements: 25.5_

  - [x] 2.2 Create DbContext and entity configurations
    - Create SdxCore.Identity.Persistence/Data/IdentityDbContext.cs with DbSet for UserRecord and AuditEvent
    - Create SdxCore.Identity.Persistence/Configurations/UserRecordConfiguration.cs (Fluent API)
    - Create SdxCore.Identity.Persistence/Configurations/AuditEventConfiguration.cs (Fluent API)
    - Configure indexes, constraints, and column types
    - _Requirements: 25.1, 25.2, 25.3_

  - [x] 2.3 Implement repository interfaces
    - Create SdxCore.Identity.Persistence/Repositories/UserRepository.cs implementing IUserRepository
    - Implement methods: FindByUsernameAsync, CreateAsync, IncrementFailedAttemptsAsync, ResetFailedAttemptsAsync, UpdateLastLoginAsync, DeactivateAsync
    - Create SdxCore.Identity.Persistence/Repositories/AuditRepository.cs implementing IAuditRepository
    - Implement method: InsertAsync
    - _Requirements: 25.4, 25.5, 25.8_

  - [x] 2.4 Create database migrations
    - Generate initial migration for UserRecord and AuditEvent tables
    - Run: dotnet ef migrations add InitialCreate --project src/Services/Identity/SdxCore.Identity.Persistence --startup-project src/Services/Identity/SdxCore.Identity.API
    - _Requirements: 25.9_

  - [x] 2.5 Create DI registration extension
    - Create SdxCore.Identity.Persistence/Extensions/ServiceCollectionExtensions.cs
    - Implement AddSdxCorePersistence extension method
    - Register DbContext with SQL Server provider using connection string from IConfiguration
    - Register repository implementations
    - _Requirements: 12.6, 12.7, 25.6, 25.7_

- [ ] 3. Implement application layer core services
  - [x] 3.1 Add required NuGet packages to Application project
    - Add System.IdentityModel.Tokens.Jwt
    - Add Konscious.Security.Cryptography.Argon2
    - Add Microsoft.Extensions.Configuration.Abstractions
    - Add Microsoft.Extensions.Logging.Abstractions
    - Add project reference to Domain
    - _Requirements: 24.3_

  - [ ] 3.2 Implement PasswordHasher with Argon2id
    - Create SdxCore.Identity.Application/Services/PasswordHasher.cs implementing IPasswordHasher
    - Implement Hash method with random salt generation
    - Implement Verify method with constant-time comparison
    - Configure Argon2id parameters for 200-300ms hashing time
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ] 3.3 Write property test for PasswordHasher
    - Create tests/Identity.Tests/PropertyTests/PasswordHasherPropertyTests.cs
    - **Property 1: Hash verification consistency**
    - **Validates: Requirements 8.1, 8.2, 8.3**
    - For all passwords, Verify(password, Hash(password)) returns true

  - [ ] 3.4 Write property test for PasswordHasher salt randomization
    - **Property 2: Salt randomization**
    - **Validates: Requirements 8.5**
    - For all passwords, Hash(password) called twice produces different outputs

  - [ ] 3.5 Implement TokenFactory
    - Create SdxCore.Identity.Application/Services/TokenFactory.cs implementing ITokenFactory
    - Implement IssueToken: create JWT with RS256/HS256 signing, embed claims (sub, iat, exp, jti)
    - Implement ValidateToken: verify signature, expiry, and revocation list
    - Implement RevokeToken: add jti to in-memory revocation list
    - Load signing credentials from configuration
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10_

  - [ ] 3.6 Write property test for TokenFactory issuance and validation
    - **Property 3: Token issuance and immediate validation**
    - **Validates: Requirements 4.1, 4.6, 4.7**
    - For all claim sets, IssueToken followed by ValidateToken returns non-null ClaimsPrincipal

  - [ ] 3.7 Write property test for TokenFactory revocation
    - **Property 4: Token revocation**
    - **Validates: Requirements 4.9, 4.10**
    - For all tokens, RevokeToken followed by ValidateToken returns false

  - [ ] 3.8 Implement AuditLogger
    - Create SdxCore.Identity.Application/Services/AuditLogger.cs implementing IAuditLogger
    - Implement LogAsync: write AuditEvent to database via IAuditRepository
    - Use fire-and-forget pattern with bounded channel for performance
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

- [ ] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement provider registry and authentication service
  - [ ] 5.1 Implement ProviderRegistry
    - Create SdxCore.Identity.Application/Services/ProviderRegistry.cs implementing IProviderRegistry
    - Use ConcurrentDictionary for provider storage
    - Implement Register method
    - Implement Resolve method
    - Implement ResolveFromConfiguration: read "Authentication:Protocol" from IConfiguration, throw ConfigurationException if null/empty/invalid, throw ProviderNotFoundException if not registered
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 19.1, 19.2, 19.3, 19.4_

  - [ ] 5.2 Write property test for ProviderRegistry configuration validation
    - Create tests/Identity.Tests/PropertyTests/ProviderRegistryPropertyTests.cs
    - **Property 5: Configuration exception when protocol not configured**
    - **Validates: Requirements 1.2**
    - When "Authentication:Protocol" is null or empty, ResolveFromConfiguration throws ConfigurationException

  - [ ] 5.3 Write property test for ProviderRegistry invalid protocol
    - **Property 6: Configuration exception for invalid protocol**
    - **Validates: Requirements 1.3**
    - When "Authentication:Protocol" is invalid, ResolveFromConfiguration throws ConfigurationException

  - [ ] 5.4 Write property test for ProviderRegistry unregistered protocol
    - **Property 7: Provider not found exception**
    - **Validates: Requirements 1.4**
    - When configured protocol is not registered, ResolveFromConfiguration throws ProviderNotFoundException

  - [ ] 5.5 Implement AuthenticationService
    - Create SdxCore.Identity.Application/Services/AuthenticationService.cs implementing IAuthenticationService
    - Implement AuthenticateAsync: validate request, resolve provider, delegate authentication, issue token, log audit event
    - Implement ValidateTokenAsync: delegate to TokenFactory
    - Implement RevokeTokenAsync: delegate to TokenFactory
    - Handle ConfigurationException and ProviderNotFoundException
    - _Requirements: 1.1, 6.7, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3, 10.4, 10.5_

  - [ ] 5.6 Write property test for AuthenticationService audit logging
    - **Property 8: Audit event always written**
    - **Validates: Requirements 6.7**
    - For all authentication attempts, exactly one AuditEvent is written regardless of outcome

  - [ ] 5.7 Create DI registration extension for Application services
    - Create SdxCore.Identity.Application/Extensions/ServiceCollectionExtensions.cs
    - Implement AddSdxCoreAuthentication extension method
    - Register all services: IAuthenticationService, IProviderRegistry, ITokenFactory, IAuditLogger, IPasswordHasher
    - Read configuration from IConfiguration
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 6. Implement InHouse authentication provider
  - [ ] 6.1 Implement InHouseProvider
    - Create SdxCore.Identity.Application/Providers/InHouseProvider.cs implementing IInHouseProvider
    - Implement AuthenticateAsync: validate inputs, load user, check account status, verify password, handle failed attempts and lockout, reset on success
    - Implement CreateUserAsync: validate uniqueness, hash password, create UserRecord with defaults
    - Implement ChangePasswordAsync: hash new password, update database
    - Implement DeactivateUserAsync: set IsActive to false
    - Use generic error messages to prevent user enumeration
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 16.1, 16.2, 16.3, 17.2, 17.3, 17.4_

  - [ ] 6.2 Write unit tests for InHouseProvider
    - Create tests/Identity.Tests/UnitTests/InHouseProviderTests.cs
    - Test successful authentication flow
    - Test invalid credentials (username not found, wrong password)
    - Test inactive account rejection
    - Test locked account rejection
    - Test failed attempt increment
    - Test account lockout after max attempts
    - Test failed attempt reset on success
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9_

  - [ ] 6.3 Write property test for InHouseProvider password storage
    - Create tests/Identity.Tests/PropertyTests/InHouseProviderPropertyTests.cs
    - **Property 9: Password never stored in plaintext**
    - **Validates: Requirements 5.6**
    - For all CreateUserAsync calls, UserRecord.PasswordHash never equals the plaintext password

  - [ ] 6.4 Write property test for InHouseProvider failed attempts
    - **Property 10: Failed attempts monotonically increase**
    - **Validates: Requirements 2.6**
    - For all failed authentication attempts, FailedAttempts is monotonically non-decreasing until reset

  - [ ] 6.5 Create DI registration extension for InHouseProvider
    - Create SdxCore.Identity.Application/Extensions/ProviderExtensions.cs
    - Implement AddInHouseProvider extension method
    - Register InHouseProvider with IProviderRegistry
    - _Requirements: 12.8_

- [ ] 7. Implement external authentication providers
  - [ ] 7.1 Add required NuGet packages for external providers
    - Add ITfoxtec.Identity.Saml2 to Application project
    - Add Microsoft.AspNetCore.Authentication.OpenIdConnect to Application project
    - Add Novell.Directory.Ldap.NETStandard to Application project
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [ ] 7.2 Implement SamlProvider
    - Create SdxCore.Identity.Application/Providers/SamlProvider.cs implementing IAuthenticationProvider
    - Implement AuthenticateAsync: validate SAML assertion signature, audience, timestamps, extract claims
    - Read configuration from "Saml" section
    - _Requirements: 3.1, 20.1, 20.2, 20.3, 20.4, 20.5_

  - [ ] 7.3 Implement OAuthProvider
    - Create SdxCore.Identity.Application/Providers/OAuthProvider.cs implementing IAuthenticationProvider
    - Implement AuthenticateAsync: exchange authorization code for access token, support PKCE
    - Read configuration from "OAuth" section
    - _Requirements: 3.2, 21.1, 21.2, 21.3, 21.4_

  - [ ] 7.4 Implement OidcProvider
    - Create SdxCore.Identity.Application/Providers/OidcProvider.cs implementing IAuthenticationProvider
    - Implement AuthenticateAsync: validate ID token signature and claims
    - Read configuration from "Oidc" section
    - _Requirements: 3.3_

  - [ ] 7.5 Implement JwtProvider
    - Create SdxCore.Identity.Application/Providers/JwtProvider.cs implementing IAuthenticationProvider
    - Implement AuthenticateAsync: validate bearer token
    - _Requirements: 3.5_

  - [ ] 7.6 Implement LdapProvider
    - Create SdxCore.Identity.Application/Providers/LdapProvider.cs implementing IAuthenticationProvider
    - Implement AuthenticateAsync: perform LDAPS bind operation, use connection pooling
    - Read configuration from "Ldap" section
    - Enforce LDAPS by default, reject plain LDAP unless explicitly enabled
    - _Requirements: 3.4, 13.1, 13.2, 13.3, 13.4_

  - [ ] 7.7 Create DI registration extensions for external providers
    - Update SdxCore.Identity.Application/Extensions/ProviderExtensions.cs
    - Implement AddSamlProvider, AddOAuthProvider, AddOidcProvider, AddJwtProvider, AddLdapProvider extension methods
    - Each method reads configuration from IConfiguration and registers with IProviderRegistry
    - _Requirements: 12.8, 12.9_

  - [ ] 7.8 Write unit tests for external providers
    - Create tests/Identity.Tests/UnitTests/ExternalProvidersTests.cs
    - Test SAML assertion validation (valid, invalid signature, expired)
    - Test OAuth code exchange flow
    - Test OIDC token validation
    - Test JWT bearer token validation
    - Test LDAP bind success and failure
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Implement API layer
  - [ ] 9.1 Add required NuGet packages to API project
    - Add Microsoft.AspNetCore.Authentication.JwtBearer to src/Services/Identity/SdxCore.Identity.API
    - Add project references to Application and Domain
    - _Requirements: 24.6_

  - [ ] 9.2 Create AuthController
    - Create src/Services/Identity/SdxCore.Identity.API/Controllers/AuthController.cs
    - Create POST /api/auth/login endpoint
    - Inject IAuthenticationService
    - Map LoginRequest to AuthenticationRequest
    - Handle ConfigurationException and ProviderNotFoundException with HTTP 500
    - Return HTTP 200 with token on success, HTTP 401 on failure
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 9.1, 9.2, 9.4_

  - [ ] 9.3 Create TokenValidationMiddleware
    - Create src/Services/Identity/SdxCore.Identity.API/Middleware/TokenValidationMiddleware.cs
    - Extract bearer token from Authorization header
    - Call IAuthenticationService.ValidateTokenAsync
    - Return HTTP 401 for invalid/expired/revoked tokens
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [ ] 9.4 Configure API startup and DI
    - Create src/Services/Identity/SdxCore.Identity.API/Program.cs
    - Register controllers
    - Call AddSdxCoreAuthentication extension method
    - Call AddSdxCorePersistence extension method
    - Register provider based on "Authentication:Protocol" configuration value using switch statement
    - Throw exception if protocol is invalid or missing
    - Register TokenValidationMiddleware
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 12.1, 12.2, 12.3, 12.4, 12.5, 12.10_

  - [ ] 9.5 Create appsettings.json configuration files
    - Create src/Services/Identity/SdxCore.Identity.API/appsettings.json with sections: ConnectionStrings, Authentication, Saml, OAuth, Oidc, Ldap
    - Create src/Services/Identity/SdxCore.Identity.API/appsettings.Development.json with development overrides
    - Create src/Services/Identity/SdxCore.Identity.API/appsettings.Production.json with production overrides
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9, 11.10, 11.11, 11.12, 11.14_

  - [ ]* 9.6 Write integration tests for API endpoints
    - Create tests/Identity.Tests/IntegrationTests/AuthControllerIntegrationTests.cs
    - Test POST /api/auth/login with valid credentials returns token
    - Test POST /api/auth/login with invalid credentials returns 401
    - Test middleware rejects expired tokens
    - Test middleware rejects revoked tokens
    - Test account lockout after max failed attempts
    - Use WebApplicationFactory and Testcontainers.MsSql
    - _Requirements: 2.9, 10.1, 10.2, 10.3, 10.4_

- [ ] 10. Implement Gateway with YARP
  - [ ] 10.1 Create Gateway project and configure YARP
    - Verify src/Gateway/SdxCore.Gateway.API project exists with Yarp.ReverseProxy package
    - Create src/Gateway/SdxCore.Gateway.API/Program.cs
    - Add YARP services: builder.Services.AddReverseProxy().LoadFromConfig(...)
    - Map reverse proxy: app.MapReverseProxy()
    - _Requirements: 23.1_

  - [ ] 10.2 Configure Gateway routing
    - Create src/Gateway/SdxCore.Gateway.API/appsettings.json
    - Add ReverseProxy section with routes and clusters
    - Define route for "/api/auth/**" to identity-cluster
    - Define identity-cluster with identity-api destination pointing to Identity API
    - _Requirements: 23.2, 23.3, 23.4_

  - [ ] 10.3 Create environment-specific Gateway configurations
    - Create src/Gateway/SdxCore.Gateway.API/appsettings.Development.json with HTTP localhost destination (http://localhost:5001)
    - Create src/Gateway/SdxCore.Gateway.API/appsettings.Production.json with HTTPS production destination
    - _Requirements: 23.5, 23.6, 23.7, 23.8_

- [ ] 11. Final integration and wiring
  - [ ] 11.1 Create solution-level documentation
    - Create README.md in root directory
    - Document solution structure and microservices architecture
    - Document configuration requirements for each service
    - Document how to run Gateway and Identity API locally
    - Document how to switch authentication protocols via appsettings.json
    - Document docker-compose usage

  - [ ] 11.2 Create docker-compose configuration
    - Create docker/docker-compose.yml with services: gateway, identity-api, sql-server
    - Create docker/.env.example for environment variables
    - Create Dockerfiles for Gateway and Identity API
    - _Requirements: 23.1_

  - [ ] 11.3 Verify end-to-end flow
    - Start SQL Server (via docker or local instance)
    - Run database migrations: dotnet ef database update --project src/Services/Identity/SdxCore.Identity.Persistence --startup-project src/Services/Identity/SdxCore.Identity.API
    - Start Identity API: dotnet run --project src/Services/Identity/SdxCore.Identity.API
    - Start Gateway: dotnet run --project src/Gateway/SdxCore.Gateway.API
    - Send authentication request through Gateway (POST http://localhost:5000/api/auth/login)
    - Verify token issuance and validation
    - Verify audit logging in database
    - Test with multiple protocols (InHouse, SAML, OAuth) by changing appsettings.json

  - [ ]* 11.4 Write end-to-end integration tests
    - Create tests/Identity.Tests/IntegrationTests/EndToEndTests.cs
    - Test full flow: Client → Gateway → Identity API → Database
    - Test protocol switching via configuration
    - Test configuration error handling (missing protocol, invalid protocol, unregistered provider)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 23.3_

- [ ] 12. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end flows with real database and HTTP requests
- The implementation follows Clean Architecture: Domain → Persistence → Application → API → Gateway
- Configuration is mandatory and read from appsettings.json with no fallback behavior
- All providers are registered explicitly based on the configured protocol

## Solution Structure

The solution follows a microservices architecture with proper folder organization:

```
SdxCore.sln
├── src/
│   ├── Gateway/
│   │   └── SdxCore.Gateway.API (YARP reverse proxy)
│   ├── Services/
│   │   └── Identity/
│   │       ├── SdxCore.Identity.API
│   │       ├── SdxCore.Identity.Application
│   │       ├── SdxCore.Identity.Domain
│   │       └── SdxCore.Identity.Persistence
│   └── BuildingBlocks/ (shared code)
│       ├── SdxCore.SharedKernel
│       ├── SdxCore.Common
│       └── SdxCore.Contracts
├── tests/
│   └── Identity.Tests/
└── docker/
    └── docker-compose.yml
```
