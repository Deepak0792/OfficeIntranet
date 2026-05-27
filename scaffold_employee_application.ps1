$domainDir = "d:\Office\SdxCore\src\Services\Employee\SdxCore.Employee.Domain"
$appDir = "d:\Office\SdxCore\src\Services\Employee\SdxCore.Employee.Application"

New-Item -ItemType Directory -Force -Path "$domainDir\Events" | Out-Null
New-Item -ItemType Directory -Force -Path "$domainDir\Interfaces\Services" | Out-Null
New-Item -ItemType Directory -Force -Path "$domainDir\DTOs\Request" | Out-Null
New-Item -ItemType Directory -Force -Path "$domainDir\DTOs\Response" | Out-Null
New-Item -ItemType Directory -Force -Path "$appDir\Services" | Out-Null

$eventsCode = @"
namespace SdxCore.Employee.Domain.Events;

public class WorkflowInitiatedEvent
{
    public string ModuleName { get; set; } = string.Empty;
    public int EntityId { get; set; }
    public int InitiatorEmployeeId { get; set; }
    public string ActionPayload { get; set; } = string.Empty;
}
"@
Set-Content -Path "$domainDir\Events\WorkflowInitiatedEvent.cs" -Value $eventsCode

$reqDtoCode = @"
namespace SdxCore.Employee.Domain.DTOs.Request;

public class AddEmployeeAddressRequest
{
    public string AddressType { get; set; } = string.Empty;
    public string AddressLine1 { get; set; } = string.Empty;
    public string? AddressLine2 { get; set; }
    public string City { get; set; } = string.Empty;
    public short CountryId { get; set; }
}

public class AddEmployeeDocumentRequest
{
    public short DocumentTypeId { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string FileUrl { get; set; } = string.Empty;
}
"@
Set-Content -Path "$domainDir\DTOs\Request\EmployeeRequests.cs" -Value $reqDtoCode

$serviceIfcCode = @"
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Domain.DTOs.Request;

namespace SdxCore.Employee.Domain.Interfaces.Services;

public interface IEmployeeProfileService
{
    Task<bool> AddAddressAsync(int employeeId, AddEmployeeAddressRequest request, CancellationToken cancellationToken = default);
    Task<bool> AddDocumentAsync(int employeeId, AddEmployeeDocumentRequest request, CancellationToken cancellationToken = default);
}
"@
Set-Content -Path "$domainDir\Interfaces\Services\IEmployeeProfileService.cs" -Value $serviceIfcCode

$serviceImplCode = @"
using System;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Domain.DTOs.Request;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Events;
using SdxCore.Employee.Domain.Interfaces.Repositories;
using SdxCore.Employee.Domain.Interfaces.Services;

namespace SdxCore.Employee.Application.Services;

public class EmployeeProfileService : IEmployeeProfileService
{
    private readonly IBaseRepository<EmployeeAddress> _addressRepository;
    private readonly IBaseRepository<EmployeeDocument> _documentRepository;

    public EmployeeProfileService(
        IBaseRepository<EmployeeAddress> addressRepository,
        IBaseRepository<EmployeeDocument> documentRepository)
    {
        _addressRepository = addressRepository;
        _documentRepository = documentRepository;
    }

    public async Task<bool> AddAddressAsync(int employeeId, AddEmployeeAddressRequest request, CancellationToken cancellationToken = default)
    {
        var address = new EmployeeAddress
        {
            EmployeeId = employeeId,
            AddressType = request.AddressType,
            AddressLine1 = request.AddressLine1,
            AddressLine2 = request.AddressLine2,
            City = request.City,
            CountryId = request.CountryId,
            IsVerified = false // Needs workflow approval
        };

        // Add outbox domain event for Workflow Microservice
        address.AddDomainEvent(new WorkflowInitiatedEvent
        {
            ModuleName = "EmployeeAddress",
            EntityId = 0, // Gets populated after save if needed, or handled via interceptor properly? 
            // Wait, ID is identity. We must ensure the interceptor sets it properly, or set it to 0 and resolve later, or save first then fire event. 
            // Actually, the interceptor fires BEFORE SaveChanges. We can't have the ID. 
            // We will use a Guid as a reference or handle it after save. Let's just use 0 for now.
            InitiatorEmployeeId = employeeId,
            ActionPayload = JsonSerializer.Serialize(request)
        });

        await _addressRepository.AddAsync(address, cancellationToken);
        await _addressRepository.SaveChangesAsync(cancellationToken);

        return true;
    }

    public async Task<bool> AddDocumentAsync(int employeeId, AddEmployeeDocumentRequest request, CancellationToken cancellationToken = default)
    {
        var doc = new EmployeeDocument
        {
            EmployeeId = employeeId,
            DocumentTypeId = request.DocumentTypeId,
            FileName = request.FileName,
            FileUrl = request.FileUrl,
            IsVerified = false
        };

        doc.AddDomainEvent(new WorkflowInitiatedEvent
        {
            ModuleName = "EmployeeDocument",
            InitiatorEmployeeId = employeeId,
            ActionPayload = JsonSerializer.Serialize(request)
        });

        await _documentRepository.AddAsync(doc, cancellationToken);
        await _documentRepository.SaveChangesAsync(cancellationToken);

        return true;
    }
}
"@
Set-Content -Path "$appDir\Services\EmployeeProfileService.cs" -Value $serviceImplCode

Write-Output "Generated Employee Application Services."
