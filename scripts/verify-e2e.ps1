# End-to-End Verification Script for SdxCore Authentication Module
# This script verifies the complete authentication flow

param(
    [string]$Protocol = "InHouse",
    [string]$GatewayUrl = "http://localhost:5000",
    [string]$IdentityUrl = "http://localhost:5001"
)

Write-Host "=== SdxCore Authentication Module E2E Verification ===" -ForegroundColor Green
Write-Host "Protocol: $Protocol" -ForegroundColor Yellow
Write-Host "Gateway URL: $GatewayUrl" -ForegroundColor Yellow
Write-Host "Identity URL: $IdentityUrl" -ForegroundColor Yellow
Write-Host ""

# Function to check if service is running
function Test-ServiceHealth {
    param([string]$Url, [string]$ServiceName)
    
    try {
        $response = Invoke-WebRequest -Uri "$Url/health" -Method GET -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ $ServiceName is healthy" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "✗ $ServiceName is not responding" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to test authentication
function Test-Authentication {
    param([string]$Url, [string]$Username, [string]$Password)
    
    $body = @{
        username = $Username
        password = $Password
    } | ConvertTo-Json
    
    try {
        $response = Invoke-WebRequest -Uri "$Url/api/auth/login" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            $result = $response.Content | ConvertFrom-Json
            Write-Host "✓ Authentication successful" -ForegroundColor Green
            Write-Host "  Token: $($result.token.accessToken.Substring(0, 50))..." -ForegroundColor Gray
            return $result.token.accessToken
        }
    }
    catch {
        Write-Host "✗ Authentication failed" -ForegroundColor Red
        Write-Host "  Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Function to test token validation
function Test-TokenValidation {
    param([string]$Url, [string]$Token)
    
    $headers = @{
        "Authorization" = "Bearer $Token"
    }
    
    try {
        $response = Invoke-WebRequest -Uri "$Url/api/auth/validate" -Method GET -Headers $headers -TimeoutSec 5
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ Token validation successful" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "✗ Token validation failed" -ForegroundColor Red
        Write-Host "  Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        return $false
    }
}

# Step 1: Check service health
Write-Host "Step 1: Checking service health..." -ForegroundColor Cyan

$identityHealthy = Test-ServiceHealth -Url $IdentityUrl -ServiceName "Identity API"
$gatewayHealthy = Test-ServiceHealth -Url $GatewayUrl -ServiceName "Gateway"

if (-not $identityHealthy -or -not $gatewayHealthy) {
    Write-Host ""
    Write-Host "Services are not healthy. Please ensure:" -ForegroundColor Red
    Write-Host "1. SQL Server is running" -ForegroundColor Yellow
    Write-Host "2. Database migrations have been applied" -ForegroundColor Yellow
    Write-Host "3. Identity API is running on $IdentityUrl" -ForegroundColor Yellow
    Write-Host "4. Gateway is running on $GatewayUrl" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To start services:" -ForegroundColor Yellow
    Write-Host "  dotnet run --project src/Services/Identity/SdxCore.Identity.API" -ForegroundColor Gray
    Write-Host "  dotnet run --project src/Gateway/SdxCore.Gateway.API" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# Step 2: Test direct Identity API authentication
Write-Host "Step 2: Testing direct Identity API authentication..." -ForegroundColor Cyan

$testUser = "testuser"
$testPassword = "TestPassword123!"

$directToken = Test-Authentication -Url $IdentityUrl -Username $testUser -Password $testPassword

if (-not $directToken) {
    Write-Host ""
    Write-Host "Direct authentication failed. This might be expected if no test user exists." -ForegroundColor Yellow
    Write-Host "For InHouse protocol, you need to create a test user first." -ForegroundColor Yellow
}

Write-Host ""

# Step 3: Test Gateway authentication
Write-Host "Step 3: Testing Gateway authentication..." -ForegroundColor Cyan

$gatewayToken = Test-Authentication -Url $GatewayUrl -Username $testUser -Password $testPassword

if (-not $gatewayToken) {
    Write-Host ""
    Write-Host "Gateway authentication failed. This might be expected if no test user exists." -ForegroundColor Yellow
}

Write-Host ""

# Step 4: Test token validation (if we have a token)
if ($gatewayToken) {
    Write-Host "Step 4: Testing token validation..." -ForegroundColor Cyan
    
    $validationSuccess = Test-TokenValidation -Url $GatewayUrl -Token $gatewayToken
    
    if ($validationSuccess) {
        Write-Host "✓ End-to-end flow verification successful!" -ForegroundColor Green
    }
} else {
    Write-Host "Step 4: Skipping token validation (no token available)" -ForegroundColor Yellow
}

Write-Host ""

# Step 5: Protocol switching test
Write-Host "Step 5: Protocol configuration verification..." -ForegroundColor Cyan

$configPath = "src/Services/Identity/SdxCore.Identity.API/appsettings.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    $currentProtocol = $config.Authentication.Protocol
    
    Write-Host "✓ Current protocol: $currentProtocol" -ForegroundColor Green
    Write-Host "  To switch protocols, update Authentication:Protocol in appsettings.json" -ForegroundColor Gray
    Write-Host "  Available protocols: InHouse, Saml, OAuth, Oidc, Jwt, Ldap" -ForegroundColor Gray
} else {
    Write-Host "✗ Configuration file not found: $configPath" -ForegroundColor Red
}

Write-Host ""

# Summary
Write-Host "=== Verification Summary ===" -ForegroundColor Green
Write-Host "Identity API Health: $(if($identityHealthy){'✓ Healthy'}else{'✗ Unhealthy'})" -ForegroundColor $(if($identityHealthy){'Green'}else{'Red'})
Write-Host "Gateway Health: $(if($gatewayHealthy){'✓ Healthy'}else{'✗ Unhealthy'})" -ForegroundColor $(if($gatewayHealthy){'Green'}else{'Red'})
Write-Host "Direct Auth: $(if($directToken){'✓ Success'}else{'✗ Failed'})" -ForegroundColor $(if($directToken){'Green'}else{'Red'})
Write-Host "Gateway Auth: $(if($gatewayToken){'✓ Success'}else{'✗ Failed'})" -ForegroundColor $(if($gatewayToken){'Green'}else{'Red'})

if ($identityHealthy -and $gatewayHealthy) {
    Write-Host ""
    Write-Host "✓ Core services are operational!" -ForegroundColor Green
    Write-Host "For full testing with user creation, see the integration tests." -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "✗ Some services need attention. Check the logs above." -ForegroundColor Red
}