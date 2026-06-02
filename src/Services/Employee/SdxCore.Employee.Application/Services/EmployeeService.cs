using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Common.Models;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeService : IEmployeeService
{
    private readonly IEmployeeRepository _repository;
    private readonly IEmployeeViewRepository _viewRepository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;

    public EmployeeService(
        IEmployeeRepository repository,
        IEmployeeViewRepository viewRepository,
        ICacheService cacheService,
        ICacheKeyBuilder cacheKeyBuilder)
    {
        _repository = repository;
        _viewRepository = viewRepository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
    }

    public async Task<PagedResponse<IEnumerable<EmployeeSummaryResponse>>> GetAllAsync(PaginationFilter filter, int? departmentId, int? locationId, int? legalEntityId, string? employmentType, bool? isActive, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("employee", $"all_{filter.PageNumber}_{filter.PageSize}_{departmentId}_{locationId}_{legalEntityId}_{employmentType}_{isActive}");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var (items, count) = await _viewRepository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, ct);

            var responses = items.Select(e => PropertyMapper.Map<EmployeeFullProfile, EmployeeSummaryResponse>(e)).ToList();

            return new PagedResponse<IEnumerable<EmployeeSummaryResponse>>(responses, filter.PageNumber, filter.PageSize, count);
        }, CacheOptions.Default, cancellationToken)
            ?? new PagedResponse<IEnumerable<EmployeeSummaryResponse>>(
                new List<EmployeeSummaryResponse>(), filter.PageNumber, filter.PageSize, 0);
    }

    public async Task<EmployeeFullProfileResponse?> GetFullProfileAsync(int id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("employee_profile", id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var profile = await _viewRepository.GetByIdAsync(id, ct);
            if (profile == null) return null;

            return PropertyMapper.Map<EmployeeFullProfile, EmployeeFullProfileResponse>(profile);
        }, CacheOptions.Default, cancellationToken);
    }

    public async Task<EmployeeResponse?> GetByCodeAsync(string employeeCode, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(e => e.EmployeeCode == employeeCode, cancellationToken);
        var e = entities.FirstOrDefault();
        if (e == null) return null;

        return PropertyMapper.Map<Domain.Entities.Employee, EmployeeResponse>(e);
    }

    public async Task<EmployeeResponse?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(e => e.Email == email, cancellationToken);
        var e = entities.FirstOrDefault();
        if (e == null) return null;

        return PropertyMapper.Map<Domain.Entities.Employee, EmployeeResponse>(e);
    }

    public async Task<PagedResponse<IEnumerable<EmployeeSummaryResponse>>> SearchAsync(string query, PaginationFilter filter, CancellationToken cancellationToken = default)
    {
        var (items, count) = await _viewRepository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, cancellationToken);

        var filteredItems = string.IsNullOrWhiteSpace(query)
            ? items
            : items.Where(x => (x.FirstName != null && x.FirstName.Contains(query, StringComparison.OrdinalIgnoreCase)) ||
                               (x.LastName != null && x.LastName.Contains(query, StringComparison.OrdinalIgnoreCase)) ||
                               (x.Email != null && x.Email.Contains(query, StringComparison.OrdinalIgnoreCase)));

        var responses = filteredItems.Select(e => PropertyMapper.Map<EmployeeFullProfile, EmployeeSummaryResponse>(e)).ToList();

        return new PagedResponse<IEnumerable<EmployeeSummaryResponse>>(responses, filter.PageNumber, filter.PageSize, filteredItems.Count());
    }

    public async Task<EmployeeSummaryResponse?> GetSummaryAsync(int id, CancellationToken cancellationToken = default)
    {
        var profile = await _viewRepository.GetByIdAsync(id, cancellationToken);
        if (profile == null) return null;

        return PropertyMapper.Map<EmployeeFullProfile, EmployeeSummaryResponse>(profile);
    }

    public async Task<EmployeeResponse> CreateAsync(CreateEmployeeRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateEmployeeRequest, Domain.Entities.Employee>(request);
        entity.IsActive = true;
        entity.DisplayName = request.DisplayName ?? $"{entity.FirstName} {entity.LastName}";

        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Domain.Entities.Employee, EmployeeResponse>(entity);
    }

    public async Task<bool> UpdateAsync(int id, UpdateEmployeeRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.FirstName = request.FirstName;
        entity.LastName = request.LastName;
        entity.DisplayName = request.DisplayName;
        entity.MobileNumber = request.MobileNumber;
        entity.DesignationId = request.DesignationId;
        entity.PreferredLanguage = request.PreferredLanguage;
        entity.PreferredTimeZoneId = request.PreferredTimeZoneId;
        entity.DateOfJoining = request.DateOfJoining;
        entity.EmploymentType = request.EmploymentType;

        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);

        return true;
    }

    public async Task<bool> ToggleStatusAsync(int id, UpdateEmployeeStatusRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.IsActive = request.IsActive;

        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);


        return true;
    }

    public async Task<bool> UpdatePhotoAsync(int id, UpdateEmployeePhotoRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.ProfilePhotoUrl = request.ProfilePhotoUrl;

        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);


        return true;
    }

    public async Task<bool> UpdateAboutAsync(int id, UpdateEmployeeAboutRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.AboutMe = request.AboutMe;

        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);


        return true;
    }
}
