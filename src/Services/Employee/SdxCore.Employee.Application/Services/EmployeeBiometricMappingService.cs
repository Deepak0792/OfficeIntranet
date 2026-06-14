using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.EmployeeBiometricMapping.Request;
using SdxCore.Employee.Application.DTOs.EmployeeBiometricMapping.Response;
using SdxCore.Employee.Domain.Abstractions;
using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Application.Services;

public class EmployeeBiometricMappingService(
    IEmployeeBiometricMappingRepository repository,
    IEmployeeUnitOfWork unitOfWork) : IEmployeeBiometricMappingService
{
    private readonly IEmployeeBiometricMappingRepository _repository = repository;
    private readonly IEmployeeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<EmployeeBiometricMappingResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);

        return PropertyMapper.MapList<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(entity);
    }

    public async Task<EmployeeBiometricMappingResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity is null) return null;

        return PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(entity);
    }

    public async Task<IEnumerable<EmployeeBiometricMappingResponse>> GetByDeviceIdAsync(Guid deviceId, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.FindAsync(x => x.BiometricDeviceId == deviceId && x.IsActive, cancellationToken);
        return PropertyMapper.MapList<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(entity);
    }

    public async Task<EmployeeBiometricMappingResponse> CreateAsync(Guid employeeId, CreateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateEmployeeBiometricMappingRequest, EmployeeBiometricMapping>(request);
        entity.Id = Guid.NewGuid();
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(created);
    }

    public async Task<EmployeeBiometricMappingResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository
            .FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken))
            .FirstOrDefault() ?? throw new KeyNotFoundException("Mapping not found");

        entity.DeviceEmployeeCode = request.DeviceEmployeeCode;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<EmployeeBiometricMapping, EmployeeBiometricMappingResponse>(entity);
    }

    public async Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return false;

        entity.IsActive = isActive;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
