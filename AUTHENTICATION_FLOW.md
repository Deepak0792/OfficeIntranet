# SdxCore Authentication Flow Documentation

This document describes the complete authentication flow in the SdxCore microservices architecture, including how the Gateway handles authentication and forwards requests to downstream services.

## Architecture Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client    │───▶│   Gateway   │───▶│ Identity Service│   │ Other Services  │
│             │    │   (YARP)    │    │                 │    │ (Catalog, etc.) │
└─────────────┘    └─────────────┘    └─────────────────┘    └─────────────────┘
                          │                     │                      │
                          │                     │                      │
                          └─────────────────────┼──────────────────────┘
                                                │
                                        Token Validation
```

## Components

### 1. Gateway (SdxCore.Gateway.API)
- **Purpose**: Entry point for all client requests
- **Technology**: ASP.NET Core with YARP (Yet Another Reverse Proxy)
- **Responsibilities**:
  - Route requests to appropriate microservices
  - Validate JWT tokens for protected routes
  - Allow public routes to bypass authentication
  - Load balance requests across service instances

### 2. Identity Service (SdxCore.Identity.API)
- **Purpose**: Authentication and user management
- **Responsibilities**:
  - Issue JWT tokens upon successful authentication
  - Validate JWT tokens
  - Manage user accounts and credentials
  - Support multiple authentication providers (InHouse, SAML, OAuth, etc.)

### 3. Other Microservices
- **Examples**: Catalog, Orders, Users, Public API
- **Authentication**: Rely on the Gateway for authentication
- **Focus**: Business logic without authentication concerns

## Authentication Flow

### 1. User Login Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant G as Gateway
    participant I as Identity Service
    
    C->>G: POST /api/auth/login (credentials)
    G->>I: Forward login request
    I->>I: Validate credentials
    I->>I: Generate JWT token
    I->>G: Return JWT token
    G->>C: Return JWT token
```

**Steps:**
1. Client sends login request to Gateway (`POST /api/auth/login`)
2. Gateway forwards request to Identity Service (public route, no authentication required)
3. Identity Service validates credentials using configured provider
4. Identity Service generates JWT token with user claims
5. Identity Service returns token to Gateway
6. Gateway returns token to client

### 2. Protected Resource Access Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant G as Gateway
    participant I as Identity Service
    participant S as Target Service
    
    C->>G: GET /api/orders (with JWT token)
    G->>G: Check if route is public
    G->>I: Validate token (GET /api/auth/test-protected)
    I->>I: Verify token signature & expiry
    I->>G: Token validation result
    G->>G: Extract user ID from JWT
    G->>S: Forward request with X-User-Id header
    S->>S: Process request using user context
    S->>G: Return response
    G->>C: Return response
```

**Steps:**
1. Client sends request to Gateway with JWT token in Authorization header
2. Gateway checks if the route is in the public routes list
3. If not public, Gateway validates token by calling Identity Service
4. Identity Service verifies token signature, expiry, and revocation status
5. If token is valid, Gateway extracts user ID from JWT token claims
6. Gateway adds `X-User-Id` header with the extracted user ID
7. Gateway forwards request to target service with user context
8. Target service processes request using the user ID from the header
9. Target service returns response to Gateway
10. Gateway returns response to client

### 3. Public Resource Access Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant G as Gateway
    participant S as Target Service
    
    C->>G: GET /api/catalog/products (no token)
    G->>G: Check if route is public
    G->>S: Forward request directly
    S->>G: Return response
    G->>C: Return response
```

**Steps:**
1. Client sends request to Gateway (no authentication required)
2. Gateway checks if route is in public routes list
3. If public, Gateway forwards request directly to target service
4. Target service processes request and returns response
5. Gateway returns response to client

## Configuration

### Gateway Configuration

#### Public Routes
Routes that don't require authentication:

```json
{
  "Authentication": {
    "PublicRoutes": [
      "/health",
      "/api/auth/login",
      "/api/public/*",
      "/api/catalog/products",
      "/swagger/*",
      "/api/docs/*"
    ]
  }
}
```

#### Route Mapping
Maps URL patterns to downstream services:

```json
{
  "ReverseProxy": {
    "Routes": {
      "identity-route": {
        "ClusterId": "identity-cluster",
        "Match": {
          "Path": "/api/auth/{**catch-all}"
        }
      },
      "catalog-public-route": {
        "ClusterId": "catalog-cluster",
        "Match": {
          "Path": "/api/catalog/products"
        }
      },
      "catalog-protected-route": {
        "ClusterId": "catalog-cluster",
        "Match": {
          "Path": "/api/catalog/{**catch-all}"
        }
      }
    }
  }
}
```

### Identity Service Configuration

#### Authentication Provider
Configures which authentication method to use:

```json
{
  "Authentication": {
    "Protocol": "InHouse",
    "Issuer": "SdxCore.Identity",
    "Audience": "SdxCore.API",
    "TokenLifetime": "01:00:00",
    "SigningKeyPath": "keys/signing-key.json"
  }
}
```

## User Context Headers

The Gateway automatically adds user context headers to authenticated requests:

### X-User-Id Header

When a request is successfully authenticated, the Gateway:

1. **Extracts User ID**: Reads the user ID from the JWT token claims
2. **Adds Header**: Includes `X-User-Id` header in the forwarded request
3. **Forwards Request**: Sends the request to the downstream service with user context

**Supported JWT Claims for User ID:**
- `sub` (Subject - standard JWT claim)
- `NameIdentifier` (ASP.NET Core standard)
- `user_id` (Custom claim)
- `userId` (Custom claim)

**Example:**

**Original Client Request:**
```http
GET /api/orders HTTP/1.1
Host: gateway.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Forwarded Request to Orders Service:**
```http
GET /api/orders HTTP/1.1
Host: orders-service.internal
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-User-Id: 12345678-1234-1234-1234-123456789012
```

## Security Features

### 1. JWT Token Security
- **Cryptographic Signing**: Tokens are signed using RS256 or HS256
- **Expiration**: Tokens have configurable expiration times
- **Revocation**: Tokens can be revoked before expiration
- **Claims**: Tokens contain user identity and authorization claims

### 2. Authentication Middleware Security
- **Token Validation**: Validates signature, expiry, and revocation status
- **Error Handling**: Generic error messages prevent information leakage
- **Timeout Protection**: HTTP client timeouts prevent hanging requests
- **HTTPS Enforcement**: Production configurations enforce HTTPS

### 3. Route Security
- **Explicit Configuration**: Public routes must be explicitly configured
- **Wildcard Support**: Supports wildcard patterns for route matching
- **Environment-Specific**: Different security levels for different environments

## Error Handling

### Authentication Errors

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `MISSING_TOKEN` | 401 | No Authorization header provided |
| `INVALID_TOKEN_FORMAT` | 401 | Authorization header doesn't use Bearer scheme |
| `EMPTY_TOKEN` | 401 | Bearer token is empty |
| `INVALID_TOKEN` | 401 | Token validation failed |
| `TOKEN_VALIDATION_ERROR` | 401 | Error occurred during token validation |

### Example Error Response

```json
{
  "errorCode": "INVALID_TOKEN",
  "errorMessage": "Token is invalid, expired, or revoked",
  "timestamp": "2026-05-01T10:30:00Z"
}
```

## Best Practices

### 1. Token Management
- **Short Expiration**: Use short-lived tokens (1 hour recommended)
- **Refresh Tokens**: Implement refresh token mechanism for long-lived sessions
- **Secure Storage**: Store tokens securely on the client side
- **Revocation**: Implement token revocation for security incidents

### 2. Route Configuration
- **Minimal Public Routes**: Only expose necessary public endpoints
- **Environment-Specific**: Use different configurations for different environments
- **Regular Review**: Regularly review and audit public routes

### 3. Monitoring and Logging
- **Authentication Events**: Log all authentication attempts
- **Failed Attempts**: Monitor and alert on failed authentication attempts
- **Performance**: Monitor token validation performance
- **Health Checks**: Implement comprehensive health checks

## Development Workflow

### 1. Adding a New Microservice

1. **Create the service** with business logic
2. **Update Gateway configuration** to add routes
3. **Configure authentication requirements** (public vs protected)
4. **Test the integration** using the provided HTTP files

### 2. Adding a New Public Route

1. **Add route to PublicRoutes array** in Gateway configuration
2. **Test that authentication is bypassed** for the route
3. **Verify security implications** of making the route public

### 3. Testing Authentication

1. **Use the provided HTTP files** for testing
2. **Test both valid and invalid tokens**
3. **Verify error responses** are appropriate
4. **Test public routes** work without authentication

## Troubleshooting

### Common Issues

1. **Token Validation Fails**
   - Check Identity service is running
   - Verify `IdentityServiceUrl` configuration
   - Ensure token is not expired

2. **Route Not Found**
   - Verify route configuration in Gateway
   - Check destination service is running
   - Ensure route pattern matches request

3. **Public Route Requires Authentication**
   - Check route is in `PublicRoutes` array
   - Verify route pattern matching
   - Check for typos in configuration

### Debugging

Enable debug logging in Gateway:

```json
{
  "Logging": {
    "LogLevel": {
      "SdxCore.Gateway.API.Middleware": "Debug"
    }
  }
}
```

This provides detailed logs about:
- Route matching decisions
- Authentication bypass decisions
- Token validation attempts
- Request forwarding

## Future Enhancements

### Planned Features
1. **Rate Limiting**: Implement rate limiting per client/route
2. **Circuit Breaker**: Add circuit breaker pattern for downstream services
3. **Caching**: Implement response caching for public endpoints
4. **Metrics**: Add detailed metrics and monitoring
5. **API Versioning**: Support API versioning through routing

### Security Enhancements
1. **mTLS**: Implement mutual TLS for service-to-service communication
2. **API Keys**: Support API key authentication for external clients
3. **CORS**: Implement CORS policies for web clients
4. **Request Validation**: Add request validation middleware