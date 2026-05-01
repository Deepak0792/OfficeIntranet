# SdxCore Gateway API

The SdxCore Gateway API serves as the entry point for all client requests in the microservices architecture. It provides centralized authentication, routing, and load balancing using YARP (Yet Another Reverse Proxy).

## Features

- **Centralized Authentication**: Validates JWT tokens before forwarding requests to downstream services
- **Selective Authentication**: Supports public routes that bypass authentication
- **Load Balancing**: Distributes requests across multiple service instances
- **Health Checks**: Provides health monitoring endpoints
- **Environment-Specific Configuration**: Supports different configurations for development, staging, and production

## Architecture

```
Client Request → Gateway → Authentication Middleware → YARP Proxy → Downstream Service
```

### Authentication Flow

1. **Public Routes**: Requests to configured public routes bypass authentication and go directly to downstream services
2. **Protected Routes**: All other requests must include a valid JWT token in the Authorization header
3. **Token Validation**: The Gateway validates tokens by calling the Identity service's validation endpoint
4. **User Context**: For valid tokens, the Gateway extracts the user ID from the JWT and adds it as an `X-User-Id` header
5. **Request Forwarding**: Valid requests are forwarded to the appropriate downstream service with user context

## Configuration

### Authentication Settings

```json
{
  "Authentication": {
    "IdentityServiceUrl": "https://localhost:5001",
    "PublicRoutes": [
      "/health",
      "/api/auth/login",
      "/api/public/*",
      "/api/catalog/products"
    ]
  }
}
```

- **IdentityServiceUrl**: Base URL of the Identity service for token validation
- **PublicRoutes**: Array of routes that don't require authentication (supports wildcards with `/*`)

### Reverse Proxy Configuration

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
    },
    "Clusters": {
      "identity-cluster": {
        "Destinations": {
          "identity-api": {
            "Address": "https://localhost:5001"
          }
        }
      },
      "catalog-cluster": {
        "LoadBalancingPolicy": "RoundRobin",
        "Destinations": {
          "catalog-api-1": {
            "Address": "https://localhost:5002"
          },
          "catalog-api-2": {
            "Address": "https://localhost:5003"
          }
        }
      }
    }
  }
}
```

## User Context Headers

When a request is authenticated, the Gateway automatically adds the following headers to requests forwarded to downstream services:

- **X-User-Id**: The unique identifier of the authenticated user extracted from the JWT token

This allows downstream services to:
- Know which user is making the request without decoding the JWT
- Implement user-specific business logic
- Perform user-based authorization
- Log user activities

### Example

**Client Request:**
```bash
curl -X GET https://localhost:5000/api/orders \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Forwarded Request to Orders Service:**
```
GET /api/orders HTTP/1.1
Host: orders-service:5004
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-User-Id: 12345678-1234-1234-1234-123456789012
```

## Supported Microservices

The Gateway is configured to route requests to the following services:

| Service | Route Pattern | Authentication Required | Description |
|---------|---------------|------------------------|-------------|
| Identity | `/api/auth/**` | No | Authentication and user management |
| Catalog (Public) | `/api/catalog/products` | No | Public product listing |
| Catalog (Protected) | `/api/catalog/**` | Yes | Product management operations |
| Orders | `/api/orders/**` | Yes | Order management |
| Users | `/api/users/**` | Yes | User profile management |
| Public API | `/api/public/**` | No | Public endpoints |

## Public Routes

The following routes are configured as public and don't require authentication:

- `/health` - Health check endpoint
- `/api/auth/login` - Authentication endpoint
- `/api/public/*` - All public API endpoints
- `/api/catalog/products` - Public product listing
- `/swagger/*` - Swagger documentation (development only)
- `/api/docs/*` - API documentation
- `/api/dev/*` - Development endpoints (development only)

## Environment-Specific Configuration

### Development
- Uses HTTP for local development
- Includes additional public routes for development tools
- Enhanced logging for debugging

### Production
- Uses HTTPS for all communications
- Minimal public routes for security
- Load balancing across multiple service instances
- Reduced logging for performance

## Usage

### Starting the Gateway

```bash
dotnet run --project src/Gateway/SdxCore.Gateway.API
```

The Gateway will start on:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`

### Making Authenticated Requests

1. **Login to get a token**:
```bash
curl -X POST https://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "user@example.com", "password": "password"}'
```

2. **Use the token for protected endpoints**:
```bash
curl -X GET https://localhost:5000/api/orders \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Making Public Requests

Public endpoints don't require authentication:

```bash
curl -X GET https://localhost:5000/api/catalog/products
curl -X GET https://localhost:5000/api/public/status
```

## Error Responses

The Gateway returns standardized error responses for authentication failures:

```json
{
  "errorCode": "INVALID_TOKEN",
  "errorMessage": "Token is invalid, expired, or revoked",
  "timestamp": "2026-05-01T10:30:00Z"
}
```

Common error codes:
- `MISSING_TOKEN`: No Authorization header provided
- `INVALID_TOKEN_FORMAT`: Authorization header doesn't use Bearer scheme
- `EMPTY_TOKEN`: Bearer token is empty
- `INVALID_TOKEN`: Token validation failed
- `TOKEN_VALIDATION_ERROR`: Error occurred during token validation

## Health Monitoring

The Gateway provides health check endpoints:

- `/health` - Overall gateway health
- Individual service health is monitored through their respective health endpoints

## Security Considerations

1. **Token Validation**: All tokens are validated with the Identity service before forwarding requests
2. **HTTPS**: Production configuration enforces HTTPS for all communications
3. **Public Route Security**: Carefully configure public routes to avoid exposing sensitive endpoints
4. **Timeout Configuration**: HTTP client timeouts prevent hanging requests
5. **Error Handling**: Generic error messages prevent information leakage

## Troubleshooting

### Common Issues

1. **Token Validation Fails**:
   - Verify the Identity service is running and accessible
   - Check the `IdentityServiceUrl` configuration
   - Ensure the token is valid and not expired

2. **Route Not Found**:
   - Verify the route configuration in `appsettings.json`
   - Check that the destination service is running
   - Ensure the route pattern matches the request path

3. **Service Unavailable**:
   - Check that downstream services are running
   - Verify the cluster destination addresses
   - Review load balancing configuration

### Logging

Enable debug logging to troubleshoot issues:

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

This will provide detailed information about:
- Authentication decisions
- Route matching
- Token validation
- Request forwarding