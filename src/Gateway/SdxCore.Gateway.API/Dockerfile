# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution file
COPY SdxCore.sln .

# Copy project files
COPY src/Gateway/SdxCore.Gateway.API/SdxCore.Gateway.API.csproj src/Gateway/SdxCore.Gateway.API/

# Restore dependencies
RUN dotnet restore src/Gateway/SdxCore.Gateway.API/SdxCore.Gateway.API.csproj

# Copy source code
COPY src/Gateway/SdxCore.Gateway.API/ src/Gateway/SdxCore.Gateway.API/

# Build the application
WORKDIR /src/src/Gateway/SdxCore.Gateway.API
RUN dotnet build SdxCore.Gateway.API.csproj -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish SdxCore.Gateway.API.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY --from=publish /app/publish .

EXPOSE 80

ENTRYPOINT ["dotnet", "SdxCore.Gateway.API.dll"]
