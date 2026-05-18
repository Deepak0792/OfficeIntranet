# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution file
COPY SdxCore.sln ./

# Copy project files for restore
COPY src/Services/Time/SdxCore.Time.API/SdxCore.Time.API.csproj src/Services/Time/SdxCore.Time.API/
COPY src/Services/Time/SdxCore.Time.Application/SdxCore.Time.Application.csproj src/Services/Time/SdxCore.Time.Application/
COPY src/Services/Time/SdxCore.Time.Domain/SdxCore.Time.Domain.csproj src/Services/Time/SdxCore.Time.Domain/
COPY src/Services/Time/SdxCore.Time.Persistence/SdxCore.Time.Persistence.csproj src/Services/Time/SdxCore.Time.Persistence/
COPY src/BuildingBlocks/SdxCore.Common/SdxCore.Common.csproj src/BuildingBlocks/SdxCore.Common/
COPY src/BuildingBlocks/SdxCore.SharedKernel/SdxCore.SharedKernel.csproj src/BuildingBlocks/SdxCore.SharedKernel/

# Restore dependencies
RUN dotnet restore src/Services/Time/SdxCore.Time.API/SdxCore.Time.API.csproj

# Copy source code
COPY src/Services/Time/ src/Services/Time/
COPY src/BuildingBlocks/SdxCore.Common/ src/BuildingBlocks/SdxCore.Common/
COPY src/BuildingBlocks/SdxCore.SharedKernel/ src/BuildingBlocks/SdxCore.SharedKernel/

# Build the application
WORKDIR /src
RUN dotnet build src/Services/Time/SdxCore.Time.API/SdxCore.Time.API.csproj -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish src/Services/Time/SdxCore.Time.API/SdxCore.Time.API.csproj -c Release -o /app/publish /p:UseAppHost=false

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
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl --fail http://localhost:80/health || exit 1

# Expose port
EXPOSE 80

# Set entry point
ENTRYPOINT ["dotnet", "SdxCore.Time.API.dll"]
