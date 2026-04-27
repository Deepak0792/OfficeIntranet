# Requirements Document

## Introduction

This document specifies the requirements for an independent, pluggable authentication module for C# .NET Core applications backed by SQL Server. The module provides user verification through multiple authentication protocols while maintaining protocol independence through a provider abstraction pattern. It supports SAML 2.0, OAuth 2.0, OpenID Connect, JWT, LDAP, and a built-in in-house credential store.

The solution includes **SdxCore.Gateway**, a YARP-based reverse proxy that serves as the entry point for all client requests. The authentication module follows **SOLID principles** and **Clean Architecture** patterns across five distinct projects.

**Configuration is mandatory**: The authentication protocol MUST be explicitly configured in appsettings.json. The system will throw exceptions for missing or invalid configurations rather than falling back to defaults, ensuring explicit intent and preventing unintended authentication behavior.

## Glossary

- **Gateway**: SdxCore.Gateway - YARP reverse proxy serving as the entry point for all client requests
- **Authentication_Module**: The complete authentication library providing user verification services (SdxCore.Identity projects)
- **Authentication_Service**: Central orchestrator component that coordinates authentication operations
- **Provider_Registry**: Component that maintains and resolves authentication provider implementations
- **Authentication_Provider**: Protocol-specific implementation of the IAuthenticationProvider interface
- **InHouse_Provider**: Built-in authentication provider backed by SQL Server credential storage
- **Token_Factory**: Component responsible for issuing and validating JWT tokens
- **Audit_Logger**: Component that records authentication events to SQL Server
- **User_Record**: SQL Server entity representing a user account with credentials
- **Auth_Token**: JWT token issued upon successful authentication
- **Provider_Result**: Result object returned by authentication providers containing claims or failure information
- **Authentication_Request**: Input object containing credentials and protocol-specific parameters
- **Authentication_Result**: Output object containing success status, token, and claims
- **Audit_Event**: Record of an authentication attempt stored for compliance
- **External_IdP**: External identity provider (SAML, OAuth, OIDC, or LDAP server)
- **Configuration_Exception**: Exception thrown when authentication configuration is missing or invalid
- **Provider_Not_Found_Exception**: Exception thrown when a configured provider is not registered

## Requirements

### Requirement 1: Protocol Resolution and Provider Selection

**User Story:** As a system integrator, I want the authentication module to automatically select the correct authentication protocol based on configuration, so that I can switch between authentication methods without code changes.

#### Acceptance Criteria

1. WHEN the Authentication_Service receives an authentication request, THE Provider_Registry SHALL resolve the authentication provider based on the protocol name configured in appsettings.json
2. WHEN the configured protocol name is null or empty, THE Provider_Registry SHALL throw ConfigurationException with message "Authentication protocol is not configured in appsettings.json"
3. WHEN the configured protocol name is invalid or cannot be parsed, THE Provider_Registry SHALL throw ConfigurationException with message "Invalid protocol name '{name}' in configuration"
4. WHEN the configured protocol name is valid but no provider is registered for that protocol, THE Provider_Registry SHALL throw ProviderNotFoundException with message "Provider for protocol '{protocol}' is not registered"
5. THE Provider_Registry SHALL never return null from the ResolveFromConfiguration method
6. THE Provider_Registry SHALL never fall back to a default provider when configuration is missing or invalid

### Requirement 2: In-House Authentication

**User Story:** As a developer, I want a built-in username/password authentication system, so that I can authenticate users without requiring an external identity provider.

#### Acceptance Criteria

1. WHEN a user submits valid credentials to the InHouse_Provider, THE InHouse_Provider SHALL query SQL Server for the user record by username
2. WHEN the username does not exist in SQL Server, THE InHouse_Provider SHALL return a failure result with a generic error message
3. WHEN the user account IsActive field is false, THE InHouse_Provider SHALL return a failure result indicating the account is inactive
4. WHEN the user account LockedUntil field contains a future timestamp, THE InHouse_Provider SHALL return a failure result indicating the account is locked
5. WHEN the submitted password matches the stored Argon2id hash, THE InHouse_Provider SHALL return a success result with user claims
6. WHEN the submitted password does not match the stored Argon2id hash, THE InHouse_Provider SHALL increment the FailedAttempts counter and return a failure result with a generic error message
7. WHEN a successful authentication occurs, THE InHouse_Provider SHALL reset the FailedAttempts counter to zero
8. WHEN a successful authentication occurs, THE InHouse_Provider SHALL update the LastLoginAt timestamp to the current UTC time
9. WHEN the FailedAttempts counter reaches the configured MaxFailedAttempts threshold, THE InHouse_Provider SHALL set the LockedUntil field to the current time plus the configured LockoutDuration

### Requirement 3: External Provider Authentication

**User Story:** As a system integrator, I want to authenticate users through external identity providers, so that I can leverage existing enterprise authentication infrastructure.

#### Acceptance Criteria

1. WHERE a SAML provider is registered, WHEN a SAML assertion is provided in the authentication request, THE SAML_Provider SHALL validate the assertion signature, audience, and expiry before extracting claims
2. WHERE an OAuth provider is registered, WHEN an OAuth authorization code is provided, THE OAuth_Provider SHALL exchange the code for an access token with the external IdP
3. WHERE an OIDC provider is registered, WHEN an ID token is provided, THE OIDC_Provider SHALL validate the token signature and claims against the configured authority
4. WHERE an LDAP provider is registered, WHEN username and password are provided, THE LDAP_Provider SHALL perform a bind operation against the configured LDAP server
5. WHERE a JWT provider is registered, WHEN a bearer token is provided, THE JWT_Provider SHALL validate the token signature, expiry, and issuer claims

### Requirement 4: Token Issuance and Management

**User Story:** As a developer, I want stateless session management through JWT tokens, so that I can scale the application horizontally without shared session state.

#### Acceptance Criteria

1. WHEN an authentication provider returns a success result, THE Token_Factory SHALL issue a JWT containing all claims from the provider result
2. THE Token_Factory SHALL include standard JWT claims (sub, iat, exp, jti) in every issued token
3. THE Token_Factory SHALL set the exp claim to the current time plus the configured TokenLifetime
4. THE Token_Factory SHALL generate a unique GUID for the jti claim for every issued token
5. THE Token_Factory SHALL sign all tokens using the configured signing credentials (RS256 or HS256)
6. WHEN validating a token, THE Token_Factory SHALL verify the cryptographic signature matches the signing key
7. WHEN validating a token, THE Token_Factory SHALL verify the exp claim is in the future
8. WHEN validating a token, THE Token_Factory SHALL verify the jti claim is not in the revocation list
9. WHEN a token is revoked, THE Token_Factory SHALL add the jti claim to the revocation list
10. WHEN a revoked token is validated, THE Token_Factory SHALL return false

### Requirement 5: User Account Management

**User Story:** As an administrator, I want to create and manage user accounts in the in-house provider, so that I can control access to the application.

#### Acceptance Criteria

1. WHEN creating a new user, THE InHouse_Provider SHALL verify the username is unique in SQL Server
2. WHEN creating a new user, THE InHouse_Provider SHALL hash the password using Argon2id before storing
3. WHEN creating a new user, THE InHouse_Provider SHALL set IsActive to true and FailedAttempts to zero
4. WHEN creating a new user, THE InHouse_Provider SHALL assign a new GUID as the user Id
5. WHEN creating a new user, THE InHouse_Provider SHALL set CreatedAt to the current UTC time
6. THE InHouse_Provider SHALL never store plaintext passwords in SQL Server
7. WHEN changing a password, THE InHouse_Provider SHALL hash the new password using Argon2id before updating the database
8. WHEN deactivating a user, THE InHouse_Provider SHALL set the IsActive field to false

### Requirement 6: Audit Logging

**User Story:** As a compliance officer, I want all authentication attempts logged to SQL Server, so that I can audit access patterns and investigate security incidents.

#### Acceptance Criteria

1. WHEN an authentication attempt succeeds, THE Audit_Logger SHALL write an AuditEvent with EventType "LOGIN_SUCCESS" to SQL Server
2. WHEN an authentication attempt fails, THE Audit_Logger SHALL write an AuditEvent with EventType "LOGIN_FAILURE" and the FailureReason to SQL Server
3. THE Audit_Logger SHALL include the authentication protocol used in every AuditEvent
4. THE Audit_Logger SHALL include the username (if provided) in every AuditEvent
5. THE Audit_Logger SHALL include the IP address of the request in every AuditEvent
6. THE Audit_Logger SHALL set the OccurredAt timestamp to the current UTC time for every AuditEvent
7. THE Authentication_Service SHALL ensure exactly one AuditEvent is written for every authentication attempt regardless of outcome

### Requirement 7: Request Validation

**User Story:** As a developer, I want authentication requests validated before processing, so that invalid requests are rejected early with clear error messages.

#### Acceptance Criteria

1. WHERE the InHouse protocol is configured, WHEN Username is null or empty, THE Authentication_Service SHALL return a failure result indicating required fields are missing
2. WHERE the InHouse protocol is configured, WHEN Password is null or empty, THE Authentication_Service SHALL return a failure result indicating required fields are missing
3. WHERE the SAML protocol is configured, WHEN SamlAssertion is null, THE Authentication_Service SHALL return a failure result indicating the SAML assertion is required
4. WHERE the OAuth protocol is configured, WHEN OAuthCode is null, THE Authentication_Service SHALL return a failure result indicating the OAuth code is required
5. WHERE the OIDC protocol is configured, WHEN IdToken is null, THE Authentication_Service SHALL return a failure result indicating the ID token is required
6. WHERE the JWT protocol is configured, WHEN BearerToken is null, THE Authentication_Service SHALL return a failure result indicating the bearer token is required

### Requirement 8: Password Security

**User Story:** As a security engineer, I want passwords protected with industry-standard hashing, so that credential theft does not compromise user accounts.

#### Acceptance Criteria

1. THE InHouse_Provider SHALL use Argon2id for all password hashing operations
2. WHEN hashing a password, THE InHouse_Provider SHALL generate a unique random salt for each password
3. WHEN verifying a password, THE InHouse_Provider SHALL use constant-time comparison to prevent timing attacks
4. THE InHouse_Provider SHALL configure Argon2id with memory and iteration parameters that result in 200-300ms hashing time
5. WHEN the same password is hashed twice, THE InHouse_Provider SHALL produce different hash outputs due to salt randomization

### Requirement 9: Error Handling and Recovery

**User Story:** As a developer, I want graceful error handling for external provider failures, so that temporary outages do not crash the application.

#### Acceptance Criteria

1. WHEN an external IdP is unreachable due to network timeout, THE Authentication_Provider SHALL return a failure result with ErrorCode "PROVIDER_UNAVAILABLE"
2. WHEN an external IdP returns an HTTP error status, THE Authentication_Provider SHALL return a failure result with ErrorCode "PROVIDER_UNAVAILABLE"
3. WHEN a provider throws an exception during authentication, THE Authentication_Service SHALL catch the exception and return a failure result
4. WHEN an authentication failure occurs, THE Authentication_Service SHALL include an ErrorCode and ErrorMessage in the result
5. THE Authentication_Service SHALL never expose internal exception details or stack traces in error messages returned to clients

### Requirement 10: Token Validation Middleware Integration

**User Story:** As a developer, I want to validate JWT tokens in HTTP requests, so that I can protect API endpoints from unauthorized access.

#### Acceptance Criteria

1. WHEN the Authentication_Service validates a token, THE Authentication_Service SHALL return true if the token is cryptographically valid, not expired, and not revoked
2. WHEN the Authentication_Service validates a token, THE Authentication_Service SHALL return false if the token signature is invalid
3. WHEN the Authentication_Service validates a token, THE Authentication_Service SHALL return false if the token is expired
4. WHEN the Authentication_Service validates a token, THE Authentication_Service SHALL return false if the token is revoked
5. THE Authentication_Service SHALL perform token validation without modifying the token or revocation list

### Requirement 11: Configuration Management

**User Story:** As a system administrator, I want authentication behavior controlled through configuration files, so that I can adjust settings without recompiling the application.

#### Acceptance Criteria

1. THE Authentication_Module SHALL read the protocol name from the "Authentication:Protocol" configuration key
2. THE Authentication_Module SHALL read the token issuer from the "Authentication:Issuer" configuration key
3. THE Authentication_Module SHALL read the token audience from the "Authentication:Audience" configuration key
4. THE Authentication_Module SHALL read the token lifetime from the "Authentication:TokenLifetime" configuration key
5. THE Authentication_Module SHALL read the maximum failed attempts from the "Authentication:MaxFailedAttempts" configuration key
6. THE Authentication_Module SHALL read the lockout duration from the "Authentication:LockoutDuration" configuration key
7. THE Authentication_Module SHALL read the signing key path from the "Authentication:SigningKeyPath" configuration key
8. THE Authentication_Module SHALL read the database connection string from the "ConnectionStrings:DefaultConnection" configuration key
9. THE SAML_Provider SHALL read all SAML-specific settings from the "Saml" configuration section
10. THE OAuth_Provider SHALL read all OAuth-specific settings from the "OAuth" configuration section
11. THE OIDC_Provider SHALL read all OIDC-specific settings from the "Oidc" configuration section
12. THE LDAP_Provider SHALL read all LDAP-specific settings from the "Ldap" configuration section
13. THE Gateway SHALL read reverse proxy routes and clusters from the "ReverseProxy" configuration section
14. ALL configuration values SHALL support environment-specific overrides via appsettings.{Environment}.json files

### Requirement 12: Dependency Injection Integration

**User Story:** As a developer, I want the authentication module registered through dependency injection, so that I can use standard .NET Core patterns for service resolution.

#### Acceptance Criteria

1. THE Authentication_Module SHALL provide an AddSdxCoreAuthentication extension method for IServiceCollection that accepts IConfiguration
2. WHEN AddSdxCoreAuthentication is called, THE Authentication_Module SHALL register IAuthenticationService as a scoped service
3. WHEN AddSdxCoreAuthentication is called, THE Authentication_Module SHALL register IProviderRegistry as a singleton
4. WHEN AddSdxCoreAuthentication is called, THE Authentication_Module SHALL register ITokenFactory as a singleton
5. WHEN AddSdxCoreAuthentication is called, THE Authentication_Module SHALL register IAuditLogger as a scoped service
6. THE Persistence_Module SHALL provide an AddSdxCorePersistence extension method that accepts IConfiguration
7. WHEN AddSdxCorePersistence is called, THE Persistence_Module SHALL register the DbContext and all repository implementations
8. THE Authentication_Module SHALL provide extension methods for registering providers that accept IConfiguration: AddInHouseProvider, AddSamlProvider, AddOAuthProvider, AddOidcProvider, AddJwtProvider, AddLdapProvider
9. ALL provider registration methods SHALL read their configuration from IConfiguration, not from lambda parameters
10. THE application startup SHALL validate that the configured protocol has a registered provider and throw an exception if not

### Requirement 13: LDAP Connection Security

**User Story:** As a security engineer, I want LDAP connections encrypted by default, so that credentials are not transmitted in plaintext over the network.

#### Acceptance Criteria

1. THE LDAP_Provider SHALL use LDAPS (LDAP over TLS) by default for all directory connections
2. THE LDAP_Provider SHALL reject plain LDAP connections unless explicitly enabled in configuration
3. WHEN connecting to an LDAP server, THE LDAP_Provider SHALL verify the server certificate is valid and trusted
4. WHEN an LDAP operation completes, THE LDAP_Provider SHALL close and dispose the connection

### Requirement 14: SQL Injection Prevention

**User Story:** As a security engineer, I want all database queries parameterized, so that SQL injection attacks are prevented.

#### Acceptance Criteria

1. THE InHouse_Provider SHALL use Entity Framework Core for all SQL Server operations
2. THE InHouse_Provider SHALL use parameterized queries for all user input
3. THE InHouse_Provider SHALL never construct SQL queries through string concatenation
4. THE Audit_Logger SHALL use parameterized queries for all audit log writes

### Requirement 15: Audit Log Integrity

**User Story:** As a compliance officer, I want audit logs protected from modification, so that authentication history cannot be tampered with.

#### Acceptance Criteria

1. THE Authentication_Module SHALL configure the SQL Server user with INSERT permission on the AuditLog table
2. THE Authentication_Module SHALL configure the SQL Server user without UPDATE permission on the AuditLog table
3. THE Authentication_Module SHALL configure the SQL Server user without DELETE permission on the AuditLog table
4. THE Audit_Logger SHALL only perform INSERT operations on the AuditLog table

### Requirement 16: User Enumeration Prevention

**User Story:** As a security engineer, I want authentication errors to be generic, so that attackers cannot determine which usernames exist in the system.

#### Acceptance Criteria

1. WHEN a username does not exist, THE InHouse_Provider SHALL return the same error message as when a password is incorrect
2. WHEN a password is incorrect, THE InHouse_Provider SHALL return a generic "Invalid credentials" message
3. THE InHouse_Provider SHALL not indicate whether the username or password was incorrect
4. THE InHouse_Provider SHALL take the same amount of time to respond regardless of whether the username exists

### Requirement 17: Claims Extraction and Mapping

**User Story:** As a developer, I want user claims extracted from authentication providers, so that I can use them for authorization decisions.

#### Acceptance Criteria

1. WHEN an authentication provider succeeds, THE Authentication_Provider SHALL return a ProviderResult containing user claims
2. THE InHouse_Provider SHALL include a "sub" claim containing the user Id in the ProviderResult
3. THE InHouse_Provider SHALL include a "username" claim containing the username in the ProviderResult
4. THE InHouse_Provider SHALL include an "email" claim containing the email address in the ProviderResult
5. WHEN an external provider succeeds, THE Authentication_Provider SHALL extract claims from the external IdP response
6. WHEN the Authentication_Service issues a token, THE Token_Factory SHALL include all claims from the ProviderResult in the JWT

### Requirement 18: Token Revocation

**User Story:** As a developer, I want to revoke JWT tokens before they expire, so that I can immediately terminate user sessions when needed.

#### Acceptance Criteria

1. WHEN a token is revoked, THE Token_Factory SHALL extract the jti claim from the token
2. WHEN a token is revoked, THE Token_Factory SHALL add the jti value to the revocation list
3. WHEN validating a token, THE Token_Factory SHALL check if the jti claim exists in the revocation list
4. WHEN a token's jti is in the revocation list, THE Token_Factory SHALL return false from ValidateTokenAsync
5. THE Token_Factory SHALL maintain the revocation list in memory for single-instance deployments

### Requirement 19: Provider Registration

**User Story:** As a system integrator, I want to register authentication providers explicitly, so that I have full control over which authentication methods are available.

#### Acceptance Criteria

1. THE Provider_Registry SHALL maintain a dictionary mapping AuthProtocol enum values to IAuthenticationProvider instances
2. WHEN a provider is registered, THE Provider_Registry SHALL store it in the dictionary keyed by its Protocol property
3. WHEN resolving a provider by protocol, THE Provider_Registry SHALL return the registered provider for that protocol
4. WHEN resolving a provider for an unregistered protocol, THE Provider_Registry SHALL throw ProviderNotFoundException
5. THE Provider_Registry SHALL allow multiple providers to be registered for different protocols simultaneously
6. THE application startup SHALL explicitly register only the provider(s) that match the configured protocol(s)

### Requirement 20: SAML Assertion Validation

**User Story:** As a security engineer, I want SAML assertions validated before trusting claims, so that forged assertions are rejected.

#### Acceptance Criteria

1. WHEN processing a SAML assertion, THE SAML_Provider SHALL verify the digital signature using the IdP's public key
2. WHEN processing a SAML assertion, THE SAML_Provider SHALL verify the Audience claim matches the configured service provider identifier
3. WHEN processing a SAML assertion, THE SAML_Provider SHALL verify the NotBefore and NotOnOrAfter timestamps are valid
4. WHEN a SAML assertion fails validation, THE SAML_Provider SHALL return a failure result with the validation error
5. WHEN a SAML assertion passes validation, THE SAML_Provider SHALL extract claims from the assertion attributes

### Requirement 21: OAuth PKCE Support

**User Story:** As a security engineer, I want OAuth flows to use PKCE, so that authorization code interception attacks are prevented.

#### Acceptance Criteria

1. WHEN initiating an OAuth authorization flow, THE OAuth_Provider SHALL generate a random code_verifier
2. WHEN initiating an OAuth authorization flow, THE OAuth_Provider SHALL compute the code_challenge from the code_verifier using SHA256
3. WHEN exchanging an authorization code for tokens, THE OAuth_Provider SHALL include the code_verifier in the token request
4. THE OAuth_Provider SHALL include a state parameter in authorization requests to prevent CSRF attacks

### Requirement 22: Performance Optimization

**User Story:** As a system architect, I want the authentication module optimized for high concurrency, so that it can handle production load without bottlenecks.

#### Acceptance Criteria

1. THE Provider_Registry SHALL use ConcurrentDictionary for lock-free provider lookups
2. THE LDAP_Provider SHALL use connection pooling to avoid per-request connection overhead
3. THE Audit_Logger SHALL write audit events asynchronously to avoid blocking the authentication critical path
4. THE Token_Factory SHALL cache signing credentials to avoid repeated key loading
5. THE InHouse_Provider SHALL configure Argon2id parameters to target 200-300ms hashing time per operation

---

### Requirement 23: Gateway Routing and Load Balancing

**User Story:** As a system architect, I want all client requests to flow through a reverse proxy gateway, so that I can centralize routing, load balancing, and cross-cutting concerns.

#### Acceptance Criteria

1. THE Gateway SHALL use YARP (Yet Another Reverse Proxy) for request routing
2. THE Gateway SHALL read route and cluster configuration from the "ReverseProxy" configuration section
3. THE Gateway SHALL route requests matching "/api/auth/**" to the Identity API cluster
4. THE Gateway SHALL support multiple destination endpoints per cluster for load balancing
5. THE Gateway SHALL support environment-specific routing configuration via appsettings.{Environment}.json
6. THE Gateway SHALL forward all request headers to downstream services
7. THE Gateway SHALL preserve the original client IP address in forwarded requests
8. THE Gateway SHALL support HTTPS for both client-facing and downstream connections

---

### Requirement 24: Clean Architecture and SOLID Principles

**User Story:** As a developer, I want the codebase to follow Clean Architecture and SOLID principles, so that it is maintainable, testable, and extensible.

#### Acceptance Criteria

1. THE solution SHALL be organized into five distinct projects: Gateway, API, Application, Domain, and Persistence
2. THE Domain layer SHALL have no dependencies on other layers
3. THE Application layer SHALL depend only on the Domain layer
4. THE Persistence layer SHALL depend only on the Domain layer and implement Domain interfaces
5. THE API layer SHALL depend on Application and Domain layers
6. THE Gateway SHALL be independent with no dependencies on Identity projects
7. ALL components SHALL follow the Single Responsibility Principle (one reason to change)
8. THE system SHALL be open for extension but closed for modification (Open/Closed Principle)
9. ALL IAuthenticationProvider implementations SHALL be substitutable for each other (Liskov Substitution Principle)
10. INTERFACES SHALL be focused and minimal (Interface Segregation Principle)
11. HIGH-LEVEL modules SHALL depend on abstractions, not concrete implementations (Dependency Inversion Principle)

---

### Requirement 25: Database Layer Separation

**User Story:** As a developer, I want database concerns separated into a dedicated persistence layer, so that I can change data access strategies without affecting business logic.

#### Acceptance Criteria

1. ALL database entities SHALL be defined in the Domain layer
2. ALL Entity Framework Core configurations SHALL be in the Persistence layer using Fluent API
3. ALL repository implementations SHALL be in the Persistence layer
4. ALL repository interfaces SHALL be defined in the Domain layer
5. THE Persistence layer SHALL use Entity Framework Core for all database operations
6. THE Persistence layer SHALL provide an AddSdxCorePersistence extension method for DI registration
7. THE Persistence layer SHALL read the connection string from IConfiguration
8. THE Application layer SHALL depend only on repository interfaces, never on concrete implementations
9. DATABASE migrations SHALL be managed in the Persistence layer
