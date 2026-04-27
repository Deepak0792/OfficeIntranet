# Quick Start Guide

Get the SdxCore Authentication Module running in 3 simple steps:

## Step 1: Configure Environment

```bash
cd docker
cp .env.example .env
```

Edit `.env` and set a strong SQL Server password:
```
SQL_SA_PASSWORD=YourStrong!Passw0rd123
```

## Step 2: Start Services

```bash
docker-compose up -d
```

Wait for all services to be healthy (~30-60 seconds):
```bash
docker-compose ps
```

## Step 3: Test Authentication

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test.user",
    "password": "TestPassword123!"
  }'
```

## What's Running?

- **Gateway**: http://localhost:5000 (entry point for all requests)
- **Identity API**: http://localhost:5001 (authentication service)
- **SQL Server**: localhost:1433 (database)

## View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f identity-api
```

## Stop Services

```bash
# Stop but keep data
docker-compose stop

# Stop and remove (data persists)
docker-compose down

# Stop and delete all data
docker-compose down -v
```

## Next Steps

- Read [README.md](README.md) for detailed configuration options
- Configure authentication protocols (SAML, OAuth, OIDC, LDAP)
- Set up production deployment with proper secrets management
- Enable HTTPS with SSL certificates

## Troubleshooting

**SQL Server won't start?**
- Check password complexity (8+ chars, uppercase, lowercase, numbers, special chars)
- Ensure Docker has enough memory (4GB minimum)

**Can't connect to services?**
- Wait for health checks to pass: `docker-compose ps`
- Check logs: `docker-compose logs`

**Need to reset everything?**
```bash
docker-compose down -v
docker-compose up -d
```
