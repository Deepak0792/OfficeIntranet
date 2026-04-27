# Docker Compose Setup for SdxCore Authentication Module

This directory contains Docker Compose configuration for running the SdxCore authentication module with all required services.

## Services

The Docker Compose setup includes three services:

1. **sql-server**: Microsoft SQL Server 2022 for storing user credentials and audit logs
2. **identity-api**: SdxCore Identity API service handling authentication operations
3. **gateway**: YARP reverse proxy serving as the entry point for all requests

## Prerequisites

- Docker Engine 20.10 or later
- Docker Compose 2.0 or later
- At least 4GB of available RAM

## Quick Start

1. **Copy the environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file** and set your desired configuration values, especially:
   - `SQL_SA_PASSWORD`: Strong password for SQL Server SA account (minimum 8 characters, must include uppercase, lowercase, numbers, and special characters)
   - `AUTH_PROTOCOL`: Authentication protocol to use (InHouse, Saml, OAuth, Oidc, Jwt, Ldap)

3. **Start all services:**
   ```bash
   docker-compose up -d
   ```

4. **Check service health:**
   ```bash
   docker-compose ps
   ```

5. **View logs:**
   ```bash
   # All services
   docker-compose logs -f

   # Specific service
   docker-compose logs -f identity-api
   ```

## Service Endpoints

Once running, the services are available at:

- **Gateway**: http://localhost:5000
- **Identity API** (direct access): http://localhost:5001
- **SQL Server**: localhost:1433

## Authentication Endpoint

To authenticate a user through the gateway:

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john.doe",
    "password": "SecurePassword123!"
  }'
```

## Database Migrations

The Identity API will automatically apply database migrations on startup. If you need to run migrations manually:

```bash
# Access the identity-api container
docker-compose exec identity-api bash

# Run migrations (if EF Core tools are installed)
dotnet ef database update
```

## Configuration

### Environment Variables

All configuration is managed through environment variables in the `.env` file:

- **SQL Server**: `SQL_SA_PASSWORD`
- **ASP.NET Core**: `ASPNETCORE_ENVIRONMENT`
- **Authentication**: `AUTH_PROTOCOL`, `AUTH_ISSUER`, `AUTH_AUDIENCE`, etc.
- **Protocol-specific**: SAML, OAuth, OIDC, LDAP settings (uncomment as needed)

### Switching Authentication Protocols

To switch between authentication protocols:

1. Edit `.env` and change `AUTH_PROTOCOL` to one of: `InHouse`, `Saml`, `OAuth`, `Oidc`, `Jwt`, `Ldap`
2. Uncomment and configure the relevant protocol-specific environment variables
3. Restart the services:
   ```bash
   docker-compose restart identity-api gateway
   ```

## Stopping Services

```bash
# Stop services but keep data
docker-compose stop

# Stop and remove containers (data persists in volumes)
docker-compose down

# Stop, remove containers, and delete all data
docker-compose down -v
```

## Troubleshooting

### SQL Server won't start

- Ensure your `SQL_SA_PASSWORD` meets complexity requirements
- Check available disk space and memory
- View logs: `docker-compose logs sql-server`

### Identity API can't connect to SQL Server

- Wait for SQL Server to be fully healthy (check with `docker-compose ps`)
- Verify the connection string in the logs
- Ensure the SA password matches in both services

### Gateway can't reach Identity API

- Verify Identity API is healthy: `docker-compose ps`
- Check network connectivity: `docker-compose exec gateway ping identity-api`
- Review gateway logs: `docker-compose logs gateway`

## Production Considerations

This Docker Compose setup is designed for **local development and testing**. For production deployments:

1. Use orchestration platforms (Kubernetes, Docker Swarm, etc.)
2. Store secrets in a secure vault (Azure Key Vault, AWS Secrets Manager, HashiCorp Vault)
3. Use managed database services instead of containerized SQL Server
4. Enable HTTPS with proper certificates
5. Configure proper resource limits and health checks
6. Implement proper logging and monitoring
7. Use production-grade authentication protocols (SAML, OIDC) instead of InHouse

## Data Persistence

SQL Server data is persisted in a Docker volume named `sql-server-data`. This ensures your data survives container restarts. To completely reset the database:

```bash
docker-compose down -v
docker-compose up -d
```

## Network Architecture

All services communicate through a dedicated Docker network (`sdxcore-network`):

```
Client → Gateway (port 5000) → Identity API (internal) → SQL Server (internal)
```

Only the Gateway is exposed to external clients. The Identity API and SQL Server are only accessible within the Docker network.
