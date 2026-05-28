# SdxCore File Storage & File API Implementation Plan

Based on the architecture defined in `docs/FILE_API_ENDPOINTS.md`, here is the structured implementation plan for the centralized file storage system and the dedicated File API microservice.

## Phase 1: `SdxCore.FileStorage` Building Block
Develop the provider-agnostic abstraction layer to manage binary files. This will be consumed by all microservices needing file operations.

### 1.1 Project Scaffolding
- Create a new Class Library in `src/BuildingBlocks/SdxCore.FileStorage`.
- Create the following folder structure:
  - `Abstractions/`
  - `Models/`
  - `Options/`
  - `Extensions/`
  - `Providers/SdxCore.FileStorage.SharedFileSystem/`

### 1.2 Core Abstractions & Models
- **Interfaces**:
  - `IFileStorageService`: Defines `UploadAsync`, `DownloadAsync`, `DeleteAsync`, and `ExistsAsync`.
- **Models**:
  - `FileUploadRequest`: Encapsulates `Stream`, `FileName`, `ContentType`, and `Microservice`.
  - `FileUploadResult`: Returns `FileUrl`, `FileName`, `FileSizeInBytes`, and `ContentType`.
  - `FileDownloadResult`: Returns `Stream`, `ContentType`, and `OriginalFileName`.

### 1.3 Configuration Options
- **Options Models**:
  - `FileStorageOptions` with a `ProviderType` enum (`SharedFileSystem`, `MinIO`, `AwsS3`, `AzureBlob`).
  - Nested configuration classes like `SharedFileSystemOptions` for `RootPath`, `Environment`, and `Tenant`.

### 1.4 Default Provider Implementation
- **`SharedFileSystemProvider`**:
  - Implement `IFileStorageService`.
  - Enforce the deterministic file path convention: `/{environment}/{tenant}/{microservice}/{year}/{month}/{fileType}/{guid}_{originalFileName}`.
  - Implement path traversal protection and secure file writing using `System.IO`.

### 1.5 Dependency Injection Setup
- **`FileStorageServiceCollectionExtensions`**:
  - Create the `AddFileStorage(IConfiguration)` extension method.
  - Resolve the correct `IFileStorageService` implementation at startup based on the configured `ProviderType`.

---

## Phase 2: `SdxCore.File.API` Microservice
Develop the dedicated API responsible for accepting file uploads from clients, validating them, and delegating the actual save operation to the `SdxCore.FileStorage` building block.

### 2.1 Microservice Scaffolding
- Create a new ASP.NET Core Web API project in `src/Services/File/SdxCore.File.API`.
- Configure standard project settings, clean architecture layout (API / Application), and standard middleware.
- Reference the `SdxCore.FileStorage` library.

### 2.2 Application Setup
- **Program.cs / Startup**:
  - Configure `appsettings.json` with the `FileStorage` block specifying `SharedFileSystem`.
  - Call `builder.Services.AddFileStorage(builder.Configuration)`.
  - Implement the Gateway-only security and extraction of `X-User-Id` / `X-Roles` headers to adhere to established architectural patterns.

### 2.3 API Endpoints
- **`FileController`**:
  - `POST /api/v1/files/upload`: Accepts `multipart/form-data`. Invokes `IFileStorageService.UploadAsync` and returns the `FileUploadResult` containing the `FileUrl`.
  - `GET /api/v1/files/download`: Accepts a relative `FileUrl`. Invokes `IFileStorageService.DownloadAsync` and returns a `FileStreamResult`.
- **Validation**:
  - Enforce file size limits (e.g., 5MB for photos, 10MB for documents) and MIME type checks (magic bytes vs `Content-Type`) before passing streams to the storage layer.

---

## Phase 3: Infrastructure and Consumer Integration
Ensure the shared local development environment is configured properly and that the Gateway routes requests appropriately.

### 3.1 Docker Compose Configuration
- Define a new named local volume in `docker-compose.yml`: `sdxcore-files` mapped to `./volumes/sdxcore-files`.
- Mount the `sdxcore-files` volume to `/mnt/sdxcore-files` across all relevant services (`Gateway`, `Identity`, `Employee`, `Time`, and the new `File` API).
- Inject the `FileStorage__ProviderType` and `FileStorage__SharedFileSystem__RootPath` environment variables.

### 3.2 Gateway Configuration
- Update the YARP configuration in `SdxCore.Gateway.API` (`appsettings.json`) to create a route and cluster for the `File.API`.
- Map incoming requests matching `/api/v1/files/**` to the internal `SdxCore.File.API` URL.

### 3.3 Consumer Updates (Future Scope)
- Services like `Employee.API` will update their DTOs and database schema to accept and store the relative `FileUrl` string returned by the file upload endpoint.
