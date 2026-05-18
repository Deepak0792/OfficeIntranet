# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution file
COPY SdxCore.sln ./

# Copy project files for restore
COPY src/Services/Shared/SdxCore.Shared.API/SdxCore.Shared.API.csproj src/Services/Shared/SdxCore.Shared.API/
COPY src/Services/Shared/SdxCore.Shared.Application/SdxCore.Shared.Application.csproj src/Services/Shared/SdxCore.Shared.Application/
COPY src/Services/Shared/SdxCore.Shared.Domain/SdxCore.Shared.Domain.csproj src/Services/Shared/SdxCore.Shared.Domain/
COPY src/Services/Shared/SdxCore.Shared.Persistence/SdxCore.Shared.Persistence.csproj src/Services/Shared/SdxCore.Shared.Persistence/
COPY src/BuildingBlocks/SdxCore.Common/SdxCore.Common.csproj src/BuildingBlocks/SdxCore.Common/

# Restore dependencies
RUN dotnet restore src/Services/Shared/SdxCore.Shared.API/SdxCore.Shared.API.csproj

# Copy source code
COPY src/Services/Shared/ src/Services/Shared/
COPY src/BuildingBlocks/SdxCore.Common/ src/BuildingBlocks/SdxCore.Common/

# Build the application
WORKDIR /src
RUN dotnet build src/Services/Shared/SdxCore.Shared.API/SdxCore.Shared.API.csproj -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish src/Services/Shared/SdxCore.Shared.API/SdxCore.Shared.API.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy published application
COPY --from=publish /app/publish .

# Set permissions
RUN chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD curl --fail http://localhost:80/health || exit 1

# Expose port
EXPOSE 80

# Set entry point
ENTRYPOINT ["dotnet", "SdxCore.Shared.API.dll"]
