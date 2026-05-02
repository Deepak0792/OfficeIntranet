# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution file
COPY SdxCore.sln ./

# Copy project files for restore
COPY src/Services/Identity/SdxCore.Identity.API/SdxCore.Identity.API.csproj src/Services/Identity/SdxCore.Identity.API/
COPY src/Services/Identity/SdxCore.Identity.Application/SdxCore.Identity.Application.csproj src/Services/Identity/SdxCore.Identity.Application/
COPY src/Services/Identity/SdxCore.Identity.Domain/SdxCore.Identity.Domain.csproj src/Services/Identity/SdxCore.Identity.Domain/
COPY src/Services/Identity/SdxCore.Identity.Persistence/SdxCore.Identity.Persistence.csproj src/Services/Identity/SdxCore.Identity.Persistence/
COPY src/BuildingBlocks/SdxCore.Common/SdxCore.Common.csproj src/BuildingBlocks/SdxCore.Common/

# Restore dependencies
RUN dotnet restore src/Services/Identity/SdxCore.Identity.API/SdxCore.Identity.API.csproj

# Copy source code
COPY src/Services/Identity/ src/Services/Identity/
COPY src/BuildingBlocks/SdxCore.Common/ src/BuildingBlocks/SdxCore.Common/

# Build the application
WORKDIR /src
RUN dotnet build src/Services/Identity/SdxCore.Identity.API/SdxCore.Identity.API.csproj -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish src/Services/Identity/SdxCore.Identity.API/SdxCore.Identity.API.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy published application
COPY --from=publish /app/publish .

# Create directories for keys and set permissions
RUN mkdir -p /app/keys && chown -R appuser:appuser /app
USER appuser

# Generate development signing key if not provided
RUN if [ ! -f /app/dev-signing-key.pem ]; then \
    openssl genpkey -algorithm RSA -out /app/dev-signing-key.pem -pkeyopt rsa_keygen_bits:2048; \
    fi

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl --fail http://localhost:80/health || exit 1

# Expose port
EXPOSE 80

# Set entry point
ENTRYPOINT ["dotnet", "SdxCore.Identity.API.dll"]