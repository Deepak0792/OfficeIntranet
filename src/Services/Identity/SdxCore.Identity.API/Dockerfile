# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution file
COPY SdxCore.sln .

# Copy project files
COPY src/Services/Identity/SdxCore.Identity.API/SdxCore.Identity.API.csproj src/Services/Identity/SdxCore.Identity.API/
COPY src/Services/Identity/SdxCore.Identity.Application/SdxCore.Identity.Application.csproj src/Services/Identity/SdxCore.Identity.Application/
COPY src/Services/Identity/SdxCore.Identity.Domain/SdxCore.Identity.Domain.csproj src/Services/Identity/SdxCore.Identity.Domain/
COPY src/Services/Identity/SdxCore.Identity.Persistence/SdxCore.Identity.Persistence.csproj src/Services/Identity/SdxCore.Identity.Persistence/

# Restore dependencies
RUN dotnet restore src/Services/Identity/SdxCore.Identity.API/SdxCore.Identity.API.csproj

# Copy source code
COPY src/Services/Identity/SdxCore.Identity.API/ src/Services/Identity/SdxCore.Identity.API/
COPY src/Services/Identity/SdxCore.Identity.Application/ src/Services/Identity/SdxCore.Identity.Application/
COPY src/Services/Identity/SdxCore.Identity.Domain/ src/Services/Identity/SdxCore.Identity.Domain/
COPY src/Services/Identity/SdxCore.Identity.Persistence/ src/Services/Identity/SdxCore.Identity.Persistence/

# Build the application
WORKDIR /src/src/Services/Identity/SdxCore.Identity.API
RUN dotnet build SdxCore.Identity.API.csproj -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish SdxCore.Identity.API.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY --from=publish /app/publish .

EXPOSE 80

ENTRYPOINT ["dotnet", "SdxCore.Identity.API.dll"]
