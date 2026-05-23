# SdxCore — File Storage Architecture & Document Upload Module

---

## Overview

The SdxCore File Storage system provides a **centralized, provider-agnostic abstraction layer** for all file upload and retrieval operations across microservices. It resides in `BuildingBlocks` and is consumed by any service that needs to manage binary files — employee profile photos, employee documents, and future module attachments.

The **default provider is `SharedFileSystem`** (local/Docker volume-mounted filesystem), switchable to `MinIO`, `AWS S3`, or `Azure Blob` via `appsettings.json` configuration with no code changes.

---

## Goals

| Goal | Detail |
|------|--------|
| **Provider-agnostic** | Storage backend is injected at runtime via configuration. No vendor lock-in. |
| **Cross-service shared** | All microservices reference the same `SdxCore.FileStorage.Abstractions` — consistent interface everywhere. |
| **Local-dev friendly** | `SharedFileSystem` provider works with Docker volume mounts. No cloud credentials required during development. |
| **Structured paths** | All files stored under a deterministic, hierarchical folder structure for auditability and future Elasticsearch indexing. |
| **Metadata separation** | File metadata (URL, size, mime type) is stored in the owning service's database (e.g., `employee.EmployeeDocument`). The storage layer only manages the physical file. |
| **Kubernetes/cloud-native** | Path structure and provider interface are designed to work identically on local Docker, Kubernetes persistent volumes, and cloud object storage. |

---

## Solution Structure

```
src/
└── BuildingBlocks/
    └── SdxCore.FileStorage/
        ├── SdxCore.FileStorage.Abstractions/        # IFileStorageService, IFileStorageOptions, UploadResult, DownloadResult
        ├── SdxCore.FileStorage.Models/              # FileUploadRequest, FileUploadResult, FileDeleteRequest
        ├── SdxCore.FileStorage.Options/             # FileStorageOptions, ProviderType enum
        ├── SdxCore.FileStorage.Extensions/          # IServiceCollection extension — AddFileStorage(config)
        ├── SdxCore.FileStorage.DependencyInjection/ # Provider resolution logic based on ProviderType
        └── Providers/
            ├── SdxCore.FileStorage.SharedFileSystem/ # Default — local/NFS/Docker volume provider
            ├── SdxCore.FileStorage.MinIO/            # MinIO S3-compatible provider
            ├── SdxCore.FileStorage.AwsS3/            # AWS S3 provider
            └── SdxCore.FileStorage.AzureBlob/        # Azure Blob Storage provider
```

---

## Provider Architecture

```
Microservices (Employee.API, HR.API, Payroll.API, ...)
        |
        | injects
        v
  IFileStorageService          ← single interface all services depend on
        |
        | resolved at startup from FileStorageOptions.ProviderType
        |
  ┌─────────────────────┬─────────────┬─────────────┬────────────────┐
  │  SharedFileSystem   │  MinIO      │  AwsS3      │  AzureBlob     │
  └─────────────────────┴─────────────┴─────────────┴────────────────┘
```

All providers implement `IFileStorageService`. The DI registration resolves the correct provider at startup based on `appsettings.json` — no `if/switch` in business code.

---

## `IFileStorageService` Contract

```
UploadAsync(FileUploadRequest request)   → FileUploadResult
    - Accepts: stream, file name, content type, target path segments
    - Returns: stored relative path (FileUrl), file size, content type, stored file name

DownloadAsync(string filePath)           → FileDownloadResult
    - Accepts: stored relative path
    - Returns: stream, content type, original file name

DeleteAsync(string filePath)             → bool
    - Accepts: stored relative path
    - Returns: true if deleted, false if not found

ExistsAsync(string filePath)             → bool
    - Accepts: stored relative path
    - Returns: true if file exists at path
```

---

## File Path Convention

All files are stored using the following deterministic hierarchical structure:

```
/{environment}/{tenant}/{microservice}/{year}/{month}/{fileType}/{guid}_{originalFileName}
```

### Path Segment Definitions

| Segment | Description | Example |
|---------|-------------|---------|
| `{environment}` | Runtime environment | `development`, `staging`, `production` |
| `{tenant}` | Tenant/organisation identifier | `sdxcore`, `acme-corp` |
| `{microservice}` | Owning service name | `employee`, `hr`, `payroll` |
| `{year}/{month}` | Upload date (UTC) | `2025/11` |
| `{fileType}` | Broad file category | `avatar`, `documents`, `exports` |
| `{guid}_{originalFileName}` | Collision-safe file name | `3f2a1b9e-..._passport.pdf` |

### Path Examples

**Employee Profile Photo:**
```
/development/sdxcore/employee/2025/11/avatar/3f2a1b9e_avatar.jpg
```

**Employee Document (Passport):**
```
/development/sdxcore/employee/2025/11/documents/7c4d8e2a_passport.pdf
```

**Future — HR Contract:**
```
/development/sdxcore/hr/2025/11/documents/9a1b3c5d_employment-contract.pdf
```

**Future — Payroll Payslip:**
```
/development/sdxcore/payroll/2025/11/exports/2e6f8a0b_nov-2025-payslip.pdf
```

---

## `appsettings.json` Configuration

```json
{
  "FileStorage": {
    "ProviderType": "SharedFileSystem",
    "SharedFileSystem": {
      "RootPath": "/mnt/sdxcore-files",
      "Environment": "development",
      "Tenant": "sdxcore"
    },
    "MinIO": {
      "Endpoint": "http://minio:9000",
      "AccessKey": "",
      "SecretKey": "",
      "BucketName": "sdxcore-files",
      "UseSSL": false
    },
    "AwsS3": {
      "Region": "ap-south-1",
      "BucketName": "sdxcore-files",
      "AccessKey": "",
      "SecretKey": ""
    },
    "AzureBlob": {
      "ConnectionString": "",
      "ContainerName": "sdxcore-files"
    }
  }
}
```

**Switching providers:**
Change `"ProviderType"` to `"MinIO"`, `"AwsS3"`, or `"AzureBlob"`. No code changes required.

---

## Docker Compose — Shared Volume Configuration

The `SharedFileSystem` provider requires a named volume mounted at the same path across all microservices so every service reads and writes to a single shared location.

### Volume Declaration

```yaml
# docker-compose.yml

volumes:
  sdxcore-files:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./volumes/sdxcore-files    # Host path — relative to docker-compose.yml
```

> On Linux/macOS, `./volumes/sdxcore-files` is a bind-mount to the host. On Windows with Docker Desktop, use an absolute path or WSL2 path.

### Service Mount Configuration

Every microservice that participates in file operations must mount the named volume at `/mnt/sdxcore-files`:

```yaml
services:

  sdxcore.gateway.api:
    image: sdxcore-gateway
    volumes:
      - sdxcore-files:/mnt/sdxcore-files
    environment:
      - FileStorage__ProviderType=SharedFileSystem
      - FileStorage__SharedFileSystem__RootPath=/mnt/sdxcore-files

  sdxcore.identity.api:
    image: sdxcore-identity
    volumes:
      - sdxcore-files:/mnt/sdxcore-files
    environment:
      - FileStorage__ProviderType=SharedFileSystem
      - FileStorage__SharedFileSystem__RootPath=/mnt/sdxcore-files

  sdxcore.employee.api:
    image: sdxcore-employee
    volumes:
      - sdxcore-files:/mnt/sdxcore-files
    environment:
      - FileStorage__ProviderType=SharedFileSystem
      - FileStorage__SharedFileSystem__RootPath=/mnt/sdxcore-files

  sdxcore.time.api:
    image: sdxcore-time
    volumes:
      - sdxcore-files:/mnt/sdxcore-files
    environment:
      - FileStorage__ProviderType=SharedFileSystem
      - FileStorage__SharedFileSystem__RootPath=/mnt/sdxcore-files

  # Add the same volume + environment block to every future microservice

volumes:
  sdxcore-files:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./volumes/sdxcore-files
```

### Host Directory Setup

Before running `docker-compose up`, create the host bind-mount directory:

```bash
mkdir -p ./volumes/sdxcore-files
```

On Linux/macOS, ensure Docker has read/write access:

```bash
chmod 777 ./volumes/sdxcore-files
```

---

## Kubernetes — Persistent Volume (Future Reference)

When deploying to Kubernetes, replace the Docker named volume with a `PersistentVolumeClaim`:

```yaml
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sdxcore-files-pvc
spec:
  accessModes:
    - ReadWriteMany          # Required — multiple pods must read/write
  resources:
    requests:
      storage: 50Gi
  storageClassName: nfs      # Must support ReadWriteMany (NFS, EFS, Azure Files, etc.)
```

Mount in each Deployment:

```yaml
volumeMounts:
  - name: sdxcore-files
    mountPath: /mnt/sdxcore-files
volumes:
  - name: sdxcore-files
    persistentVolumeClaim:
      claimName: sdxcore-files-pvc
```

> For production cloud deployments, switch `ProviderType` to `AwsS3`, `MinIO`, or `AzureBlob` to eliminate the shared PVC dependency entirely.

---

## Upload Flow — Step by Step

> **Important:** File uploads are handled exclusively by the dedicated **`SdxCore.File.API`** microservice — a separate service in `src/Services/File/`. Consuming microservices (Employee, HR, Payroll, etc.) never accept raw file binaries directly. They only receive and store the `FileUrl` path returned by `SdxCore.File.API` after a successful upload.

### Employee Profile Photo Upload

```
1. Client  →  POST <File.API endpoint>
              Headers: Authorization: Bearer <token>
              Body: multipart/form-data
                    file         = <binary>
                    microservice = "employee"

2. Gateway →  Validates JWT, injects X-User-Id, X-Roles, X-Internal-ApiKey
              Routes to SdxCore.File.API

3. File.API → IFileStorageService.UploadAsync(request)
              Builds path: /development/sdxcore/employee/2025/11/avatar/{guid}_avatar.jpg
              Writes file to /mnt/sdxcore-files/{path}
              Returns FileUploadResult { FileUrl, FileName, FileSizeInBytes, ContentType }

4. Client  →  PATCH /api/v1/employees/1042/photo     (via Gateway → Employee.API)
              Body: { "profilePhotoUrl": "/development/sdxcore/employee/2025/11/avatar/{guid}_avatar.jpg" }

5. Employee.API → Updates employee.Employee.ProfilePhotoUrl column with the returned path
```

### Employee Document Upload

```
1. Client  →  POST <File.API endpoint>
              Headers: Authorization: Bearer <token>
              Body: multipart/form-data
                    file         = <binary>
                    microservice = "employee"

2. Gateway →  Validates JWT, routes to SdxCore.File.API

3. File.API → IFileStorageService.UploadAsync(request)
              Builds path: /development/sdxcore/employee/2025/11/documents/{guid}_passport.pdf
              Writes to /mnt/sdxcore-files/{path}
              Returns FileUploadResult { FileUrl, FileName, FileSizeInBytes, ContentType }

4. Client  →  POST /api/v1/employees/1042/documents   (via Gateway → Employee.API)
              Body: {
                "documentTypeId": 3,
                "fileUrl": "/development/.../passport.pdf",
                "fileName": "{guid}_passport.pdf",
                "originalFileName": "passport.pdf",
                "fileExtension": ".pdf",
                "mimeType": "application/pdf",
                "fileSizeInBytes": 204800,
                "documentNumber": "A1234567",
                "expiryDate": "2030-01-15"
              }

4. Employee.API → Inserts row into employee.EmployeeDocument with FileUrl + metadata
```

---

## Centralized Storage Usage by Module

### Current Consumers

| Module | Entity | Column | Storage Path Pattern | File Types |
|--------|--------|--------|---------------------|------------|
| Employee | `employee.Employee` | `ProfilePhotoUrl` | `/{env}/{tenant}/employee/{yyyy}/{mm}/avatar/` | `jpg`, `jpeg`, `png`, `webp` |
| Employee | `employee.EmployeeDocument` | `FileUrl` | `/{env}/{tenant}/employee/{yyyy}/{mm}/documents/` | `pdf`, `jpg`, `png`, `docx` |

### Future Consumers (Extensibility)

| Module | Entity | Storage Path Pattern |
|--------|--------|---------------------|
| HR | Contract | `/{env}/{tenant}/hr/{yyyy}/{mm}/documents/` |
| Payroll | Payslip | `/{env}/{tenant}/payroll/{yyyy}/{mm}/exports/` |
| Attendance | Shift Reports | `/{env}/{tenant}/attendance/{yyyy}/{mm}/exports/` |
| Helpdesk | Ticket Attachment | `/{env}/{tenant}/helpdesk/{yyyy}/{mm}/attachments/` |
| Survey | Response Export | `/{env}/{tenant}/survey/{yyyy}/{mm}/exports/` |

---

## File Size & Type Constraints (Recommended Defaults)

| Category | Max Size | Allowed Extensions |
|----------|----------|-------------------|
| Profile Photo | 5 MB | `.jpg`, `.jpeg`, `.png`, `.webp` |
| Identity Document | 10 MB | `.pdf`, `.jpg`, `.jpeg`, `.png` |
| General Document | 25 MB | `.pdf`, `.docx`, `.xlsx`, `.jpg`, `.png` |
| Bulk Export | 100 MB | `.pdf`, `.xlsx`, `.csv`, `.zip` |

Constraints are enforced in `FileUploadRequest` validation within `SdxCore.FileStorage.Models` — not in individual microservices.

---

## Security Considerations

| Concern | Mitigation |
|---------|-----------|
| **Direct file URL guessing** | GUIDs in file names make paths non-guessable. |
| **Unauthorized download** | File retrieval endpoints go through the Gateway — JWT validated before streaming. |
| **Path traversal** | `SharedFileSystemProvider` must sanitize all path segments and reject `..` sequences. |
| **MIME type spoofing** | Validate actual MIME type via file header inspection (magic bytes), not just the `Content-Type` header. |
| **Volume access** | The Docker volume is mounted inside containers only — not exposed externally. |

---

## NuGet Package Dependencies

### `SdxCore.FileStorage.Abstractions`
- No external dependencies. Pure interfaces and models.

### `SdxCore.FileStorage.SharedFileSystem`
- No additional NuGet packages. Uses `System.IO`.

### `SdxCore.FileStorage.MinIO`
- `Minio` (official MinIO .NET SDK)

### `SdxCore.FileStorage.AwsS3`
- `AWSSDK.S3`

### `SdxCore.FileStorage.AzureBlob`
- `Azure.Storage.Blobs`

---

## Registration in Each Microservice

In `Program.cs` or `ServiceCollectionExtensions.cs` of any consuming service:

```csharp
// Registers the correct IFileStorageService provider based on appsettings
builder.Services.AddFileStorage(builder.Configuration);
```

`AddFileStorage` is the single extension method in `SdxCore.FileStorage.Extensions` that reads `FileStorage:ProviderType` and registers the appropriate provider implementation.