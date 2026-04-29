# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution file
COPY SdxCore.sln ./

# Copy project files
COPY src/Gateway/SdxCore.Gateway.API/SdxCore.Gateway.API.csproj src/Gateway/SdxCore.Gateway.API/

# Restore dependencies
RUN dotnet restore src/Gateway/SdxCore.Gateway.API/SdxCore.Gateway.API.csproj

# Copy source code
COPY src/Gateway/SdxCore.Gateway.API/ src/Gateway/SdxCore.Gateway.API/

# Build the application
WORKDIR /src/src/Gateway/SdxCore.Gateway.API
RUN dotnet build -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy published application
COPY --from=publish /app/publish .

# Set ownership
RUN chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD curl --fail http://localhost:80/health || exit 1

# Expose port
EXPOSE 80

# Set entry point
ENTRYPOINT ["dotnet", "SdxCore.Gateway.API.dll"]