# Implementation Plan: Authentication Module

## Overview

This implementation plan breaks down the authentication module into discrete coding tasks following Clean Architecture principles. The solution consists of five projects: SdxCore.Gateway (YARP reverse proxy), SdxCore.Identity.API (Web API), SdxCore.Identity.Application (business logic), SdxCore.Identity.Domain (entities and interfaces), and SdxCore.Identity.Persistence (EF Core data access).

The implementation follows a bottom-up approach: Domain → Persistence → Application → API → Gateway, ensuring each layer is functional before building the next. Configuration is mandatory and read from appsettings.json with no fallback behavior.

## Tasks

- [ ] 1. Set up solution structure and domain layer
  - Create solution file with five projects: Gateway, API, Application, Domain, Persistence
  - Define domain entities: UserRecord, AuditEvent
  - Define domain enums: AuthProtocol
  - Define domain interfaces: IAuthenticationService, IAuthenticationProvider, ITokenFactory, IAuditLogger, IUserRepository, IAuditRepository, IPasswordHasher
  - Define DTOs: AuthenticationRequest, AuthenticationResult, AuthToken, ProviderResult
  - Define custom exceptions: ConfigurationException, ProviderNotFoundException, AuthProviderUnavailableException
  - _Requirements: 24.1, 24.2_

- [ ] 2. Implement persistence layer with EF Core
  - [ ] 2.1 Create DbContext and entity configurations
    - Create IdentityDbContext with DbSet for UserRecord and AuditEvent
    - Implement Fluent API configurations: UserRecordConfiguration, AuditEventConfiguration
    - Configure indexes, constraints, and column types
    - _Requirements: 25.1, 25.2, 25.3_

  - [ ] 2.2 Implement repository interfaces
    - Implement UserRepository with methods: FindByUsernameAsync, CreateAsync, IncrementFailedAttemptsAsync, ResetFailedAttemptsAsync, UpdateLastLoginAsync, DeactivateAsync
    - Implement AuditRepository with method: InsertAsync
    - _Requirements: 25.4, 25.5, 25.8_

  - [ ] 2.3 Create database migrations
    - Generate initial migration for UserRecord and AuditEvent tables
    - _Requirements: 25.9_

  - [ ] 2.4 Create DI registration extension
    - Implement AddSdxCorePersistence extension method
    - Register DbContext with SQL Server provider using connection string from IConfiguration
    - Register repository implementations
    - _Requirements: 12.6, 12.7, 25.6, 25.7_

- [ ] 3. Implement application layer core services
  - [ ] 3.1 Implement PasswordHasher with Argon2id
    - Create PasswordHasher class implementing IPasswordHasher
    - Implement Hash method with random salt generation
    - Implement Verify method with constant-time comparison
    - Configure Argon2id parameters for 200-300ms hashing time
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ]* 3.2 Write property test for PasswordHasher
    - **Property 1: Hash verification consistency**
    - **Validates: Requirements 8.1, 8.2, 8.3**
    - For all passwords, Verify(password, Hash(password)) returns true

  - [ ]* 3.3 Write property test for PasswordHasher salt randomization
    - **Property 2: Salt randomization**
    - **Validates: Requirements 8.5**
    - For all passwords, Hash(password) called twice produces different outputs

  - [ ] 3.4 Implement TokenFactory
    - Create TokenFactory class implementing ITokenFactory
    - Implement IssueToken: create JWT with RS256/HS256 signing, embed claims (sub, iat, exp, jti)
    - Implement ValidateToken: verify signature, expiry, and revocation list
    - Implement RevokeToken: add jti to in-memory revocation list
    - Load signing credentials from configuration
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10_

  - [ ]* 3.5 Write property test for TokenFactory issuance and validation
    - **Property 3: Token issuance and immediate validation**
    - **Validates: Requirements 4.1, 4.6, 4.7**
    - For all claim sets, IssueToken followed by ValidateToken returns non-null ClaimsPrincipal

  - [ ]* 3.6 Write property test for TokenFactory revocation
    - **Property 4: Token revocation**
    - **Validates: Requirements 4.9, 4.10**
    - For all tokens, RevokeToken followed by ValidateToken returns false

  - [ ] 3.7 Implement AuditLogger
    - Create AuditLogger class implementing IAuditLogger
    - Implement LogAsync: write AuditEvent to database via IAuditRepository
    - Use fire-and-forget pattern with bounded channel for performance
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

- [ ] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement provider registry and authentication service
  - [ ] 5.1 Implement ProviderRegistry
    - Create ProviderRegistry class implementing IProviderRegistry
    - Use ConcurrentDictionary for provider storage
    - Implement Register method
    - Implement Resolve method
    - Implement ResolveFromConfiguration: read "Authentication:Protocol" from IConfiguration, throw ConfigurationException if null/empty/invalid, throw ProviderNotFoundException if not registered
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 19.1, 19.2, 19.3, 19.4_

  - [ ]* 5.2 Write property test for ProviderRegistry configuration validation
    - **Property 5: Configuration exception when protocol not configured**
    - **Validates: Requirements 1.2**
    - When "Authentication:Protocol" is null or empty, ResolveFromConfiguration throws ConfigurationException

  - [ ]* 5.3 Write property test for ProviderRegistry invalid protocol
    - **Property 6: Configuration exception for invalid protocol**
    - **Validates: Requirements 1.3**
    - When "Authentication:Protocol" is invalid, ResolveFromConfiguration throws ConfigurationException

  - [ ]* 5.4 Write property test for ProviderRegistry unregistered protocol
    - **Property 7: Provider not found exception**
    - **Validates: Requirements 1.4**
    - When configured protocol is not registered, ResolveFromConfiguration throws ProviderNotFoundException

  - [ ] 5.5 Implement AuthenticationService
    - Create AuthenticationService class implementing IAuthenticationService
    - Implement AuthenticateAsync: validate request, resolve provider, delegate authentication, issue token, log audit event
    - Implement ValidateTokenAsync: delegate to TokenFactory
    - Implement RevokeTokenAsync: delegate to TokenFactory
    - Handle ConfigurationException and ProviderNotFoundException
    - _Requirements: 1.1, 6.7, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3, 10.4, 10.5_

  - [ ]* 5.6 Write property test for AuthenticationService audit logging
    - **Property 8: Audit event always written**
    - **Validates: Requirements 6.7**
    - For all authentication attempts, exactly one AuditEvent is written regardless of outcome

- [ ] 6. Implement InHouse authentication provider
  - [ ] 6.1 Implement InHouseProvider
    - Create InHouseProvider class implementing IInHouseProvider
    - Implement AuthenticateAsync: validate inputs, load user, check account status, verify password, handle failed attempts and lockout, reset on success
    - Implement CreateUserAsync: validate uniqueness, hash password, create UserRecord with defaults
    - Implement ChangePasswordAsync: hash new password, update database
    - Implement DeactivateUserAsync: set IsActive to false
    - Use generic error messages to prevent user enumeration
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 16.1, 16.2, 16.3, 17.2, 17.3, 17.4_

  - [ ]* 6.2 Write unit tests for InHouseProvider
    - Test successful authentication flow
    - Test invalid credentials (username not found, wrong password)
    - Test inactive account rejection
    - Test locked account rejection
    - Test failed attempt increment
    - Test account lockout after max attempts
    - Test failed attempt reset on success
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9_

  - [ ]* 6.3 Write property test for InHouseProvider password storage
    - **Property 9: Password never stored in plaintext**
    - **Validates: Requirements 5.6**
    - For all CreateUserAsync calls, UserRecord.PasswordHash never equals the plaintext password

  - [ ]* 6.4 Write property test for InHouseProvider failed attempts
    - **Property 10: Failed attempts monotonically increase**
    - **Validates: Requirements 2.6**
    - For all failed authentication attempts, FailedAttempts is monotonically non-decreasing until reset

  - [ ] 6.5 Create DI registration extension for InHouseProvider
    - Implement AddInHouseProvider extension method
    - Register InHouseProvider with IProviderRegistry
    - _Requirements: 12.8_

- [ ] 7. Implement external authentication providers
  - [ ] 7.1 Implement SamlProvider
    - Create SamlProvider class implementing IAuthenticationProvider
    - Implement AuthenticateAsync: validate SAML assertion signature, audience, timestamps, extract claims
    - Read configuration from "Saml" section
    - _Requirements: 3.1, 20.1, 20.2, 20.3, 20.4, 20.5_

  - [ ] 7.2 Implement OAuthProvider
    - Create OAuthProvider class implementing IAuthenticationProvider
    - Implement AuthenticateAsync: exchange authorization code for access token, support PKCE
    - Read configuration from "OAuth" section
    - _Requirements: 3.2, 21.1, 21.2, 21.3, 21.4_

  - [ ] 7.3 Implement OidcProvider
    - Create OidcProvider class implementing IAuthenticationProvider
    - Implement AuthenticateAsync: validate ID token signature and claims
    - Read configuration from "Oidc" section
    - _Requirements: 3.3_

  - [ ] 7.4 Implement JwtProvider
    - Create JwtProvider class implementing IAuthenticationProvider
    - Implement AuthenticateAsync: validate bearer token
    - _Requirements: 3.5_

  - [ ] 7.5 Implement LdapProvider
    - Create LdapProvider class implementing IAuthenticationProvider
    - Implement AuthenticateAsync: perform LDAPS bind operation, use connection pooling
    - Read configuration from "Ldap" section
    - Enforce LDAPS by default, reject plain LDAP unless explicitly enabled
    - _Requirements: 3.4, 13.1, 13.2, 13.3, 13.4_

  - [ ] 7.6 Create DI registration extensions for external providers
    - Implement AddSamlProvider, AddOAuthProvider, AddOidcProvider, AddJwtProvider, AddLdapProvider extension methods
    - Each method reads configuration from IConfiguration and registers with IProviderRegistry
    - _Requirements: 12.8, 12.9_

  - [ ]* 7.7 Write unit tests for external providers
    - Test SAML assertion validation (valid, invalid signature, expired)
    - Test OAuth code exchange flow
    - Test OIDC token validation
    - Test JWT bearer token validation
    - Test LDAP bind success and failure
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Implement API layer
  - [ ] 9.1 Create AuthController
    - Create AuthController with POST /api/auth/login endpoint
    - Inject IAuthenticationService
    - Map LoginRequest to AuthenticationRequest
    - Handle ConfigurationException and ProviderNotFoundException with HTTP 500
    - Return HTTP 200 with token on success, HTTP 401 on failure
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 9.1, 9.2, 9.4_

  - [ ] 9.2 Create TokenValidationMiddleware
    - Create middleware to validate JWT tokens from Authorization header
    - Extract bearer token, call IAuthenticationService.ValidateTokenAsync
    - Return HTTP 401 for invalid/expired/revoked tokens
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [ ] 9.3 Configure API startup and DI
    - Create Program.cs with controller registration
    - Call AddSdxCoreAuthentication extension method
    - Call AddSdxCorePersistence extension method
    - Register provider based on "Authentication:Protocol" configuration value
    - Throw exception if protocol is invalid or missing
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 12.1, 12.2, 12.3, 12.4, 12.5, 12.10_

  - [ ] 9.4 Create appsettings.json configuration files
    - Create appsettings.json with all configuration sections: ConnectionStrings, Authentication, Saml, OAuth, Oidc, Ldap
    - Create appsettings.Development.json with development overrides
    - Create appsettings.Production.json with production overrides
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9, 11.10, 11.11, 11.12, 11.14_

  - [ ]* 9.5 Write integration tests for API endpoints
    - Test POST /api/auth/login with valid credentials returns token
    - Test POST /api/auth/login with invalid credentials returns 401
    - Test middleware rejects expired tokens
    - Test middleware rejects revoked tokens
    - Test account lockout after max failed attempts
    - Use WebApplicationFactory and Testcontainers.MsSql
    - _Requirements: 2.9, 10.1, 10.2, 10.3, 10.4_

- [ ] 10. Implement Gateway with YARP
  - [ ] 10.1 Create Gateway project and configure YARP
    - Create SdxCore.Gateway project
    - Add Yarp.ReverseProxy package
    - Create Program.cs with YARP registration and MapReverseProxy
    - _Requirements: 23.1_

  - [ ] 10.2 Configure Gateway routing
    - Create appsettings.json with ReverseProxy section
    - Define route for "/api/auth/**" to identity-cluster
    - Define identity-cluster with identity-api destination
    - _Requirements: 23.2, 23.3, 23.4_

  - [ ] 10.3 Create environment-specific Gateway configurations
    - Create appsettings.Development.json with HTTP localhost destination
    - Create appsettings.Production.json with HTTPS production destination
    - _Requirements: 23.5, 23.6, 23.7, 23.8_

- [ ] 11. Final integration and wiring
  - [ ] 11.1 Create solution-level README
    - Document project structure and architecture
    - Document configuration requirements
    - Document how to run Gateway and Identity API
    - Document how to switch authentication protocols

  - [ ] 11.2 Verify end-to-end flow
    - Start Gateway and Identity API
    - Send authentication request through Gateway
    - Verify token issuance and validation
    - Verify audit logging
    - Test with multiple protocols (InHouse, SAML, OAuth)

  - [ ]* 11.3 Write end-to-end integration tests
    - Test full flow: Client → Gateway → Identity API → Database
    - Test protocol switching via configuration
    - Test configuration error handling
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
