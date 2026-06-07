using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Common.Models;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;
using System.Linq.Expressions;

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
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(EmployeeSummary), $"all_{filter.PageNumber}_{filter.PageSize}_{departmentId}_{locationId}_{legalEntityId}_{employmentType}_{isActive}");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var (items, count) = await _viewRepository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, ct);

            var responses = items.Select(e => PropertyMapper.Map<EmployeeSummary, EmployeeSummaryResponse>(e)).ToList();

            return new PagedResponse<IEnumerable<EmployeeSummaryResponse>>(responses, filter.PageNumber, filter.PageSize, count);
        }, CacheOptions.Default, cancellationToken)
            ?? new PagedResponse<IEnumerable<EmployeeSummaryResponse>>(
                new List<EmployeeSummaryResponse>(), filter.PageNumber, filter.PageSize, 0);
    }

    public async Task<EmployeeSummaryResponse?> GetFullProfileAsync(int id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(EmployeeSummary), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var profile = await _viewRepository.GetByIdAsync(id, ct);
            if (profile == null) return null;

            return PropertyMapper.Map<EmployeeSummary, EmployeeSummaryResponse>(profile);
        }, CacheOptions.Default, cancellationToken);
    }

    public async Task<EmployeeResponse?> GetByCodeAsync(string employeeCode, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(Employee), employeeCode);
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.FindAsync(e => e.EmployeeCode == employeeCode, cancellationToken);
            var e = entities.FirstOrDefault();
            if (e == null) return null;

            return PropertyMapper.Map<Domain.Entities.Employee, EmployeeResponse>(e);
        }, CacheOptions.Default, cancellationToken);
    }

    public async Task<EmployeeResponse?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(Employee), email);
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.FindAsync(e => e.Email == email, cancellationToken);
            var e = entities.FirstOrDefault();
            if (e == null) return null;

            return PropertyMapper.Map<Domain.Entities.Employee, EmployeeResponse>(e);
        }, CacheOptions.Default, cancellationToken);

    }

    public async Task<PagedResponse<IEnumerable<EmployeeSummaryResponse>>> SearchAsync(string query, PaginationFilter filter, CancellationToken cancellationToken = default)
    {
        var (items, count) = await _viewRepository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, cancellationToken);

        var filteredItems = string.IsNullOrWhiteSpace(query)
            ? items
            : items.Where(x => (x.FirstName != null && x.FirstName.Contains(query, StringComparison.OrdinalIgnoreCase)) ||
                               (x.LastName != null && x.LastName.Contains(query, StringComparison.OrdinalIgnoreCase)) ||
                               (x.Email != null && x.Email.Contains(query, StringComparison.OrdinalIgnoreCase)));

        var responses = filteredItems.Select(e => PropertyMapper.Map<EmployeeSummary, EmployeeSummaryResponse>(e)).ToList();

        return new PagedResponse<IEnumerable<EmployeeSummaryResponse>>(responses, filter.PageNumber, filter.PageSize, filteredItems.Count());
    }

    public async Task<EmployeeSummaryResponse?> GetSummaryAsync(int id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(EmployeeSummary), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var profile = await _viewRepository.GetByIdAsync(id, cancellationToken);
            if (profile == null) return null;

            return PropertyMapper.Map<EmployeeSummary, EmployeeSummaryResponse>(profile);
        }, CacheOptions.Default, cancellationToken);
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

    public async Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
    List<short> designationIds,
    short? scopeTypeId,
    int? scopeReferenceId,
    CancellationToken cancellationToken = default)
    {
        if (designationIds is null || designationIds.Count == 0)
            return [];

        // Build scope filter against vwEmployeeSummary columns
        Expression<Func<EmployeeSummary, bool>> scopePredicate = scopeTypeId switch
        {
            5 when scopeReferenceId.HasValue =>   // DEPARTMENT
                e => e.PrimaryDepartmentId == (short)scopeReferenceId.Value,

            4 when scopeReferenceId.HasValue =>   // OFFICE
                e => e.PrimaryLocationId == (short)scopeReferenceId.Value,

            3 when scopeReferenceId.HasValue =>   // LEGAL_ENTITY
                e => e.PrimaryLegalEntityId == (short)scopeReferenceId.Value,

            6 when scopeReferenceId.HasValue =>   // TEAM
                e => e.PrimaryTeamId == (short)scopeReferenceId.Value,

            7 when scopeReferenceId.HasValue =>   // EMPLOYEE (single)
                e => e.EmployeeId == scopeReferenceId.Value,

            _ => e => true  // GLOBAL or no scope — no restriction
        };

        var employees = await _viewRepository.FindAsync(
            e => designationIds.Contains((short)e.DesignationId!)
              && e.IsActive,
            cancellationToken);

        // Apply scope filter in-memory after fetch
        // (FindAsync already pulls from the view which has all scope columns)
        var scoped = employees
            .Where(scopePredicate.Compile())
            .OrderBy(e => e.DisplayName)
            .ToList();

        return scoped.Select(e => new EmployeesByDesignationResponse
        {
            EmployeeId = e.EmployeeId,
            DisplayName = e.DisplayName ?? string.Empty,
            DesignationId = e.DesignationId,
            PrimaryDepartmentId = e.PrimaryDepartmentId
        });
    }
}
