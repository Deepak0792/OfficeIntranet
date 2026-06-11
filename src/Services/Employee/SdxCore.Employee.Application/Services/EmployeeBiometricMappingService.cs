using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Domain;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeBiometricMappingService : IEmployeeBiometricMappingService
{
    private readonly IEmployeeBiometricMappingRepository _repository;
    private readonly IEmployeeUnitOfWork _unitOfWork;

    public EmployeeBiometricMappingService(
        IEmployeeBiometricMappingRepository repository,
        IEmployeeUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<EmployeeBiometricMappingResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var mappings = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);

        return mappings.Select(e => PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(e)).ToList();
    }

    public async Task<EmployeeBiometricMappingResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var mapping = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (mapping == null) return null;

        return PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(mapping);
    }

    public async Task<IEnumerable<EmployeeBiometricMappingResponse>> GetByDeviceIdAsync(Guid deviceId, CancellationToken cancellationToken = default)
    {
        var mappings = await _repository.FindAsync(x => x.BiometricDeviceId == deviceId && x.IsActive, cancellationToken);

        return mappings.Select(e => PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(e)).ToList();
    }

    public async Task<EmployeeBiometricMappingResponse> AddAsync(Guid employeeId, CreateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken = default)
    {
        var mapping = PropertyMapper.Map<CreateEmployeeBiometricMappingRequest, EmployeeBiometricMapping>(request);
        mapping.EmployeeId = employeeId;
        mapping.IsActive = true;

        var created = await _repository.AddAsync(mapping, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(created);
    }

    public async Task<EmployeeBiometricMappingResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken = default)
    {
        var mapping = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (mapping == null) throw new KeyNotFoundException("Mapping not found");

        mapping.DeviceEmployeeCode = request.DeviceEmployeeCode;
        _repository.Update(mapping);

        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(mapping);
    }

    public async Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var mapping = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (mapping == null) return false;

        mapping.IsActive = isActive;
        _repository.Update(mapping);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
