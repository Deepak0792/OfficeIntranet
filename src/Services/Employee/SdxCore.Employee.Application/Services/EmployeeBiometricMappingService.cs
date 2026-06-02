using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeBiometricMappingService : IEmployeeBiometricMappingService
{
    private readonly IEmployeeBiometricMappingRepository _repository;

    public EmployeeBiometricMappingService(IEmployeeBiometricMappingRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<EmployeeBiometricMappingResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var mappings = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);

        return mappings.Select(e => PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(e)).ToList();
    }

    public async Task<EmployeeBiometricMappingResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var mapping = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (mapping == null) return null;

        return PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(mapping);
    }

    public async Task<IEnumerable<EmployeeBiometricMappingResponse>> GetByDeviceIdAsync(int deviceId, CancellationToken cancellationToken = default)
    {
        var mappings = await _repository.FindAsync(x => x.BiometricDeviceId == deviceId && x.IsActive, cancellationToken);

        return mappings.Select(e => PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(e)).ToList();
    }

    public async Task<EmployeeBiometricMappingResponse> AddAsync(int employeeId, CreateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken = default)
    {
        var mapping = PropertyMapper.Map<CreateEmployeeBiometricMappingRequest, EmployeeBiometricMapping>(request);
        mapping.EmployeeId = employeeId;
        mapping.IsActive = true;

        var created = await _repository.AddAsync(mapping, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(created);
    }

    public async Task<EmployeeBiometricMappingResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken = default)
    {
        var mapping = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (mapping == null) throw new KeyNotFoundException("Mapping not found");

        mapping.DeviceEmployeeCode = request.DeviceEmployeeCode;
        _repository.Update(mapping);

        await _repository.SaveChangesAsync(cancellationToken);
        return PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(mapping);
    }

    public async Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default)
    {
        var mapping = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (mapping == null) return false;

        mapping.IsActive = isActive;
        _repository.Update(mapping);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
