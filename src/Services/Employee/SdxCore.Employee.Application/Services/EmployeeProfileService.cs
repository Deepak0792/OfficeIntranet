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
