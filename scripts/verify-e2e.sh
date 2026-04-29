#!/bin/bash

# End-to-End Verification Script for SdxCore Authentication Module
# This script verifies the complete authentication flow

PROTOCOL=${1:-"InHouse"}
GATEWAY_URL=${2:-"http://localhost:5000"}
IDENTITY_URL=${3:-"http://localhost:5001"}

echo "=== SdxCore Authentication Module E2E Verification ==="
echo "Protocol: $PROTOCOL"
echo "Gateway URL: $GATEWAY_URL"
echo "Identity URL: $IDENTITY_URL"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Function to check if service is running
test_service_health() {
    local url=$1
    local service_name=$2
    
    if curl -s -f "$url/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $service_name is healthy${NC}"
        return 0
    else
        echo -e "${RED}✗ $service_name is not responding${NC}"
        return 1
    fi
}

# Function to test authentication
test_authentication() {
    local url=$1
    local username=$2
    local password=$3
    
    local response=$(curl -s -w "%{http_code}" -X POST "$url/api/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$username\",\"password\":\"$password\"}" \
        2>/dev/null)
    
    local http_code="${response: -3}"
    local body="${response%???}"
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Authentication successful${NC}"
        local token=$(echo "$body" | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)
        echo -e "${GRAY}  Token: ${token:0:50}...${NC}"
        echo "$token"
        return 0
    else
        echo -e "${RED}✗ Authentication failed${NC}"
        echo -e "${RED}  Status: $http_code${NC}"
        return 1
    fi
}

# Function to test token validation
test_token_validation() {
    local url=$1
    local token=$2
    
    local http_code=$(curl -s -w "%{http_code}" -o /dev/null -X GET "$url/api/auth/validate" \
        -H "Authorization: Bearer $token" 2>/dev/null)
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Token validation successful${NC}"
        return 0
    else
        echo -e "${RED}✗ Token validation failed${NC}"
        echo -e "${RED}  Status: $http_code${NC}"
        return 1
    fi
}

# Step 1: Check service health
echo -e "${CYAN}Step 1: Checking service health...${NC}"

identity_healthy=false
gateway_healthy=false

if test_service_health "$IDENTITY_URL" "Identity API"; then
    identity_healthy=true
fi

if test_service_health "$GATEWAY_URL" "Gateway"; then
    gateway_healthy=true
fi

if [ "$identity_healthy" = false ] || [ "$gateway_healthy" = false ]; then
    echo ""
    echo -e "${RED}Services are not healthy. Please ensure:${NC}"
    echo -e "${YELLOW}1. SQL Server is running${NC}"
    echo -e "${YELLOW}2. Database migrations have been applied${NC}"
    echo -e "${YELLOW}3. Identity API is running on $IDENTITY_URL${NC}"
    echo -e "${YELLOW}4. Gateway is running on $GATEWAY_URL${NC}"
    echo ""
    echo -e "${YELLOW}To start services:${NC}"
    echo -e "${GRAY}  dotnet run --project src/Services/Identity/SdxCore.Identity.API${NC}"
    echo -e "${GRAY}  dotnet run --project src/Gateway/SdxCore.Gateway.API${NC}"
    exit 1
fi

echo ""

# Step 2: Test direct Identity API authentication
echo -e "${CYAN}Step 2: Testing direct Identity API authentication...${NC}"

test_user="testuser"
test_password="TestPassword123!"

direct_token=$(test_authentication "$IDENTITY_URL" "$test_user" "$test_password")
direct_auth_success=$?

if [ $direct_auth_success -ne 0 ]; then
    echo ""
    echo -e "${YELLOW}Direct authentication failed. This might be expected if no test user exists.${NC}"
    echo -e "${YELLOW}For InHouse protocol, you need to create a test user first.${NC}"
fi

echo ""

# Step 3: Test Gateway authentication
echo -e "${CYAN}Step 3: Testing Gateway authentication...${NC}"

gateway_token=$(test_authentication "$GATEWAY_URL" "$test_user" "$test_password")
gateway_auth_success=$?

if [ $gateway_auth_success -ne 0 ]; then
    echo ""
    echo -e "${YELLOW}Gateway authentication failed. This might be expected if no test user exists.${NC}"
fi

echo ""

# Step 4: Test token validation (if we have a token)
if [ $gateway_auth_success -eq 0 ] && [ -n "$gateway_token" ]; then
    echo -e "${CYAN}Step 4: Testing token validation...${NC}"
    
    if test_token_validation "$GATEWAY_URL" "$gateway_token"; then
        echo -e "${GREEN}✓ End-to-end flow verification successful!${NC}"
    fi
else
    echo -e "${YELLOW}Step 4: Skipping token validation (no token available)${NC}"
fi

echo ""

# Step 5: Protocol switching test
echo -e "${CYAN}Step 5: Protocol configuration verification...${NC}"

config_path="src/Services/Identity/SdxCore.Identity.API/appsettings.json"
if [ -f "$config_path" ]; then
    current_protocol=$(grep -o '"Protocol"[[:space:]]*:[[:space:]]*"[^"]*' "$config_path" | cut -d'"' -f4)
    
    echo -e "${GREEN}✓ Current protocol: $current_protocol${NC}"
    echo -e "${GRAY}  To switch protocols, update Authentication:Protocol in appsettings.json${NC}"
    echo -e "${GRAY}  Available protocols: InHouse, Saml, OAuth, Oidc, Jwt, Ldap${NC}"
else
    echo -e "${RED}✗ Configuration file not found: $config_path${NC}"
fi

echo ""

# Summary
echo -e "${GREEN}=== Verification Summary ===${NC}"
echo -e "Identity API Health: $([ "$identity_healthy" = true ] && echo -e "${GREEN}✓ Healthy${NC}" || echo -e "${RED}✗ Unhealthy${NC}")"
echo -e "Gateway Health: $([ "$gateway_healthy" = true ] && echo -e "${GREEN}✓ Healthy${NC}" || echo -e "${RED}✗ Unhealthy${NC}")"
echo -e "Direct Auth: $([ $direct_auth_success -eq 0 ] && echo -e "${GREEN}✓ Success${NC}" || echo -e "${RED}✗ Failed${NC}")"
echo -e "Gateway Auth: $([ $gateway_auth_success -eq 0 ] && echo -e "${GREEN}✓ Success${NC}" || echo -e "${RED}✗ Failed${NC}")"

if [ "$identity_healthy" = true ] && [ "$gateway_healthy" = true ]; then
    echo ""
    echo -e "${GREEN}✓ Core services are operational!${NC}"
    echo -e "${YELLOW}For full testing with user creation, see the integration tests.${NC}"
else
    echo ""
    echo -e "${RED}✗ Some services need attention. Check the logs above.${NC}"
fi