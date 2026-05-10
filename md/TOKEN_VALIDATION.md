# Token Validation Implementation - Single Responsibility Architecture

This document describes the refactored implementation of token validation with a clear separation of concerns between the AuthController and Gateway middleware.

## Architecture Overview

The token validation system now follows a **single responsibility principle**:

- **AuthController** (`/api/auth/validate-token`): Handles ALL token validation logic, error handling, and claims extraction
- **Gateway Middleware**: Simply delegates to AuthController and forwards the response with user context headers

## Single Responsibility Design

### ✅ AuthController Responsibilities
- Extract and validate Authorization header format
- Validate JWT tokens using `IAuthenticationService`
- Extract user claims from validated tokens
- Handle all error scenarios with appropriate HTTP status codes
- Return structured validation response with user information
- Comprehensive logging for all validation scenarios

### ✅ Gateway Middleware Responsibilities  
- Check if route requires authentication (public routes)
- Forward Authorization header to AuthController
- Parse successful validation response
- Add user context headers for downstream services
- Forward error responses from AuthController
- Minimal logging for request flow

## Benefits of This Architecture

### 🎯 **Single Source of Truth**
- All token validation logic centralized in AuthController
- No duplicate error handling or claims extraction
- Consistent validation behavior across all entry points

### 🔧 **Maintainability**
- Changes to validation logic only need to be made in one place
- Easier to test and debug validation issues
- Clear separation of concerns

### 📊 **Better Observability**
- Centralized logging for all validation events
- Consistent error codes and messages
- Easier to monitor and troubleshoot authentication issues

### 🚀 **Performance**
- Gateway middleware is lightweight and focused
- Rich validation response eliminates need for duplicate token parsing
- Efficient user context propagation to downstream services

## Implementation Details

### AuthController: `/api/auth/validate-token`

**Handles ALL validation logic**:
```csharp
// 1. Authorization header validation
// 2. Bearer token format validation  
// 3. Token validation via IAuthenticationService
// 4. Claims extraction from validated token
// 5. Structured response with user information
// 6. Comprehensive error handling
```

**Response Format**:
```json
{
  "isValid": true,
  "userId": "user123",
  "username": "john.doe",
  "email": "john.doe@example.com",
  "roles": ["User", "Admin"],
  "provider": "InHouse",
  "expiresAt": "2026-05-01T12:00:00Z",
  "validatedAt": "2026-05-01T10:30:00Z"
}
```

### Gateway Middleware: Simplified Delegation

**Focused responsibilities**:
```csharp
// 1. Check public routes
// 2. Forward Authorization header to AuthController
// 3. Parse validation response
// 4. Add user context headers
// 5. Continue request pipeline
```

**User Context Headers Added**:
- `X-User-Id`: User identifier
- `X-Username`: Username
- `X-User-Email`: Email address  
- `X-User-Roles`: Comma-separated roles
- `X-Auth-Provider`: Authentication provider

## Multi-Provider Support

The centralized validation in AuthController supports all authentication providers:

- **InHouse**: Username/password authentication
- **SAML**: SAML assertion-based authentication
- **OAuth**: OAuth 2.0 authorization code flow
- **OIDC**: OpenID Connect ID token validation
- **JWT**: Direct JWT bearer token validation

All provider-specific logic is handled by the underlying `IAuthenticationService.ValidateTokenAsync()` method.

## Error Handling - Single Point of Control

### AuthController Error Responses

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | `MISSING_AUTHORIZATION_HEADER` | No Authorization header |
| 400 | `INVALID_AUTHORIZATION_FORMAT` | Not Bearer format |
| 400 | `EMPTY_TOKEN` | Empty Bearer token |
| 401 | `INVALID_TOKEN` | Invalid/expired/revoked token |
| 500 | `VALIDATION_ERROR` | Server error during validation |

### Gateway Middleware Error Handling

The Gateway middleware only handles:
- Missing Authorization header (before calling AuthController)
- HTTP communication errors with AuthController
- JSON parsing errors from AuthController response

All other errors are handled by AuthController and forwarded by the Gateway.

## Request Flow

```
1. Client Request → Gateway Middleware
2. Gateway checks public routes
3. Gateway forwards Authorization header → AuthController
4. AuthController validates token + extracts claims
5. AuthController returns validation response
6. Gateway adds user context headers
7. Gateway forwards request to downstream service
```

## Testing Strategy

### AuthController Tests
- Comprehensive unit tests for all validation scenarios
- Error handling for all edge cases
- Claims extraction verification
- Multi-provider token validation

### Gateway Middleware Tests
- Public route handling
- Authorization header forwarding
- User context header addition
- Error response forwarding

## Migration Benefits

### Before (Duplicate Logic)
- ❌ Token parsing in both Gateway and AuthController
- ❌ Error handling duplicated
- ❌ Claims extraction in multiple places
- ❌ Inconsistent error messages
- ❌ Difficult to maintain and test

### After (Single Responsibility)
- ✅ All validation logic in AuthController
- ✅ Gateway focused on request routing
- ✅ Single source of truth for errors
- ✅ Consistent user context propagation
- ✅ Easy to maintain and extend

## Usage Examples

### Direct AuthController Call
```bash
curl -X POST https://localhost:5001/api/auth/validate-token \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Gateway Flow (Automatic)
```
1. Client → Gateway: GET /api/orders (with Bearer token)
2. Gateway → AuthController: POST /api/auth/validate-token
3. AuthController → Gateway: Validation response with user info
4. Gateway → Orders Service: GET /api/orders (with user context headers)
```

This architecture ensures maintainable, testable, and consistent token validation across the entire system.