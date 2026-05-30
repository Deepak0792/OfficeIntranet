using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Interfaces.Services;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Interfaces.Repositories;

namespace SdxCore.Employee.Application.Services;

public class BiometricMappingService : IBiometricMappingService
{
    private readonly IBiometricMappingRepository _repository;

    public BiometricMappingService(IBiometricMappingRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<BiometricMappingResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var mappings = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);
        
        return mappings.Select(m => new BiometricMappingResponse
        {
            Id = m.Id,
            EmployeeId = m.EmployeeId,
            BiometricDeviceId = m.BiometricDeviceId,
            DeviceEmployeeCode = m.DeviceEmployeeCode,
            IsActive = m.IsActive
        }).ToList();
    }

    public async Task<BiometricMappingResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var mapping = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (mapping == null) return null;

        return new BiometricMappingResponse
        {
            Id = mapping.Id,
            EmployeeId = mapping.EmployeeId,
            BiometricDeviceId = mapping.BiometricDeviceId,
            DeviceEmployeeCode = mapping.DeviceEmployeeCode,
            IsActive = mapping.IsActive
        };
    }

    public async Task<IEnumerable<BiometricMappingResponse>> GetByDeviceIdAsync(int deviceId, CancellationToken cancellationToken = default)
    {
        var mappings = await _repository.FindAsync(x => x.BiometricDeviceId == deviceId && x.IsActive, cancellationToken);
        
        return mappings.Select(m => new BiometricMappingResponse
        {
            Id = m.Id,
            EmployeeId = m.EmployeeId,
            BiometricDeviceId = m.BiometricDeviceId,
            DeviceEmployeeCode = m.DeviceEmployeeCode,
            IsActive = m.IsActive
        }).ToList();
    }

    public async Task<BiometricMappingResponse> AddAsync(int employeeId, AddBiometricMappingRequest request, CancellationToken cancellationToken = default)
    {
        var mapping = new BiometricEmployeeMapping
        {
            EmployeeId = employeeId,
            BiometricDeviceId = request.BiometricDeviceId,
            DeviceEmployeeCode = request.DeviceEmployeeCode,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var created = await _repository.AddAsync(mapping, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return new BiometricMappingResponse
        {
            Id = created.Id,
            EmployeeId = created.EmployeeId,
            BiometricDeviceId = created.BiometricDeviceId,
            DeviceEmployeeCode = created.DeviceEmployeeCode,
            IsActive = created.IsActive
        };
    }

    public async Task<BiometricMappingResponse> UpdateAsync(int employeeId, int id, UpdateBiometricMappingRequest request, CancellationToken cancellationToken = default)
    {
        var mapping = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (mapping == null) throw new KeyNotFoundException("Mapping not found");

        mapping.DeviceEmployeeCode = request.DeviceEmployeeCode;
        _repository.Update(mapping);
        await _repository.SaveChangesAsync(cancellationToken);

        return new BiometricMappingResponse
        {
            Id = mapping.Id,
            EmployeeId = mapping.EmployeeId,
            BiometricDeviceId = mapping.BiometricDeviceId,
            DeviceEmployeeCode = mapping.DeviceEmployeeCode,
            IsActive = mapping.IsActive
        };
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
