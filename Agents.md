# SdxCore Mental Model

## 1. Architecture Summary
The project is built on **.NET Core 9.0** following a **Microservices and Clean Architecture** pattern.
*   **Gateway Layer (`SdxCore.Gateway.API`)**: Acts as the entry point, utilizing YARP (Yet Another Reverse Proxy). It intercepts incoming requests, validates authentication tokens, enriches headers, and forwards requests to the appropriate downstream microservices.
*   **Services Layer (`SdxCore.Services`)**: Contains the microservices. Currently, there is an **Identity** service (`SdxCore.Identity.API`) which handles all authentication and authorization logic.
*   **Clean Architecture (Identity Service)**: The Identity service is split into four distinct layers:
    *   `API`: Presentation layer with Controllers and Middleware.
    *   `Application`: Contains business logic, DTOs, and specific authentication providers (InHouse, SAML, OAuth, OIDC, JWT, LDAP).
    *   `Domain`: Core business entities, interfaces, and exceptions.
    *   `Persistence`: Data access layer using Entity Framework Core with a SQL Server backend.
*   **Database Management (`SdxCore.Database`)**: An SSDT (SQL Server Data Tools) database project that uses PowerShell scripts (`Build-All.ps1`, `Generate-FullScript.ps1`, `Generate-DeltaScript.ps1`) to generate deployment scripts (Full and Delta) based on sprint-based migrations.
*   **Building Blocks (`SdxCore.BuildingBlocks`)**: Contains shared libraries (`Common`, `Contracts`, `SharedKernel`) that can be reused across multiple microservices.

## 2. Dependency Map
```mermaid
graph TD
    Client[Client] --> Gateway[SdxCore.Gateway.API (YARP)]
    
    Gateway -- Proxies Requests --> IdentityAPI[SdxCore.Identity.API]
    Gateway -- Internal Token Validation --> IdentityAPI
    
    subgraph Identity Service [SdxCore.Identity Service]
        IdentityAPI --> IdentityApp[SdxCore.Identity.Application]
        IdentityApp --> IdentityDomain[SdxCore.Identity.Domain]
        IdentityPersistence[SdxCore.Identity.Persistence] --> IdentityDomain
        IdentityAPI --> IdentityPersistence
    end
    
    IdentityPersistence -- Entity Framework --> SQLServer[(SQL Server)]
    
    DatabaseProj[SdxCore.Database (.sqlproj/PS Scripts)] -. Manages Schema .-> SQLServer
    
    IdentityApp -. Uses .-> CommonLibs[SdxCore.BuildingBlocks]
    Gateway -. Uses .-> CommonLibs
```

## 3. Execution Flow (Authentication Example)
1.  **Request Arrival**: A client sends a request to an endpoint on the Gateway (e.g., `https://localhost:5000/api/some-secure-route`).
2.  **Gateway Interception**: The `GatewayAuthenticationMiddleware` intercepts the request.
3.  **Public Route Check**: It checks if the route is public via `PublicRouteValidator`. If public, it skips validation.
4.  **Token Validation Delegation**: If secure, the Gateway sends an internal HTTP POST request to the Identity service's `/api/auth/validate-token` endpoint, passing the original `Authorization` header and appending an `X-Internal-API-Key` for service-to-service auth.
5.  **Identity Service Processing**:
    *   The `AuthController` in the Identity service receives the validation request.
    *   It delegates logic to the active authentication provider (configured via `appsettings.json`, e.g., `InHouse`, `Saml`, etc.) located in the `Application` layer.
    *   The provider validates the token (signature, expiration, issuer, database revocation status via the `Persistence` layer).
6.  **Response Handling**:
    *   If invalid, the Gateway intercepts the 401 response and halts execution, returning Unauthorized to the client.
    *   If valid, the Identity service returns a `TokenValidationResponse` (UserId, Username, Roles, etc.).
7.  **Header Enrichment**: The Gateway extracts this payload and injects standard `X-` headers (e.g., `X-User-Id`, `X-User-Roles`, `X-Trace-Id`) into the context.
8.  **Reverse Proxy**: Finally, YARP routes the enriched request to the target downstream microservice.

## 4. Important Business Logic
*   **Pluggable Auth Providers**: The `SdxCore.Identity.Application/Providers` directory contains implementations for various auth protocols (`InHouseProvider`, `SamlProvider`, `OAuthProvider`, etc.). The active provider is dynamically injected at startup based on the `"Authentication:Protocol"` config value.
*   **Delegated Authentication**: The Gateway explicitly does *not* validate JWT signatures itself. It treats token validation as a domain concern of the Identity service. This ensures the Identity service retains absolute authority over token revocation, lockout states, and complex claims generation.
*   **Database Delta Scripts**: The database schema isn't managed solely by EF Migrations. The `SdxCore.Database` project generates strict `Full.sql` and incremental `Delta.sql` deployment scripts using a bespoke sprint folder structure (`Sprint01`, `Sprint02`).
*   **Header-Based Context Propagation**: Downstream services are completely oblivious to JWTs. They rely entirely on trusting the Gateway to provide `X-User-Id` and `X-User-Roles` headers.

## 5. Safest Implementation Approach
When making changes to this repository, follow these guidelines to ensure safety and consistency:
1.  **Respect the Boundaries**: Never add database access directly to the `API` layer. Never add business logic to the `Gateway` layer.
2.  **Feature Flags / Providers**: If adding a new authentication mechanism, implement it as a new class in `SdxCore.Identity.Application/Providers` implementing the appropriate interface, and wire it up in the API's `Program.cs` switch statement. Do not hardcode new logic into existing providers.
3.  **Database Changes**: If modifying database schema, you must account for *both* EF Core (for local dev/code alignment) and the `.sqlproj`/PowerShell script system in `src/Database`. Changes should likely go into a new sprint folder (e.g., `Sprint03`) so the `Generate-DeltaScript.ps1` can pick them up.
4.  **Gateway Changes**: Treat the Gateway as dumb routing infrastructure. If you need to add complex validation or business rules, push them down into the Identity service and expose an endpoint for the Gateway to call.
