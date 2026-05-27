# SdxCore.Gateway

The SdxCore Gateway is the single point of entry for all external client requests. Built on top of Microsoft's **YARP (Yet Another Reverse Proxy)**, it handles routing, security interception, and context propagation for the entire microservices ecosystem.

---

## 🏛️ Overall Microservice Architecture and Request Flow

The Gateway sits at the edge of the network. It receives internet traffic and acts as the orchestrator for authorization and routing.

**Request Flow Example (Complete Roundtrip):**
1. **Client** issues `GET https://<gateway-domain>/api/v1/regions` with a Bearer token.
2. **Gateway Interception**: The `GatewayAuthenticationMiddleware` catches the request.
3. **Public Route Check**: It evaluates the route against `PublicRouteValidator`. Since `/api/v1/regions` is not public, it proceeds to secure validation.
4. **Token Delegation**: The Gateway makes an internal `HttpClient` POST request to the Identity service (`https://localhost:5001/api/auth/validate-token`), forwarding the JWT and an `X-Internal-API-Key`.
5. **Context Propagation**: If the Identity service returns a `200 OK` with user claims, the Gateway extracts these claims and injects `X-User-Id` and `X-User-Roles` headers into the original request.
6. **Reverse Proxying**: YARP forwards the newly enriched request to the `Time.API` destination cluster.
7. **Response**: The `Time.API` responds with an `ApiResponse<T>`, which YARP proxies back to the Client.

---

## 🔗 Dependency Relationships

Unlike the standard 4-layer microservices, the Gateway is a lean proxy application.
- It relies on **YARP** (`Yarp.ReverseProxy`) for routing configuration.
- It relies on `HttpClientFactory` for inter-service communication (calling the Identity API).
- It references `SdxCore.Common` to utilize standard configuration keys, constants, and potentially shared security models.

---

## 🤝 Inter-Service Communication Patterns

The Gateway utilizes **Synchronous HTTP Communication** for its internal orchestration.
- **Identity API Check**: It treats the Identity service as the ultimate source of truth for authentication. It does **not** validate JWT signatures locally using standard ASP.NET JwtBearer middleware. This delegated approach ensures the Identity service retains absolute authority over token revocation, lockouts, and complex claims generation.
- **Header Injection**: By injecting headers (`X-User-Id`), the Gateway guarantees that downstream services remain entirely decoupled from OAuth/JWT protocols.

---

## 🔌 How Routing is Mapped and Exposed

Routing is entirely configuration-driven via `appsettings.json`. YARP maps incoming paths to internal destination clusters.

```json
{
  "ReverseProxy": {
    "Routes": {
      "time-route": {
        "ClusterId": "time-cluster",
        "Match": {
          "Path": "/api/v1/{**catch-all}"
        }
      },
      "identity-route": {
        "ClusterId": "identity-cluster",
        "Match": {
          "Path": "/api/auth/{**catch-all}"
        }
      }
    },
    "Clusters": {
      "time-cluster": {
        "Destinations": {
          "time-api": {
            "Address": "https://localhost:5002"
          }
        }
      },
      "identity-cluster": {
        "Destinations": {
          "identity-api": {
            "Address": "https://localhost:5001"
          }
        }
      }
    }
  }
}
```

---

## 🔐 Security Features
- **Centralized Rate Limiting**: (Future) Prevents DDoS attacks before traffic reaches downstream services.
- **API Key Injection**: Injects the `X-Internal-API-Key` to allow downstream services (via `[GatewayOnly]`) to verify the proxy origin.
- **SSL Termination**: Handles HTTPS negotiation at the edge.