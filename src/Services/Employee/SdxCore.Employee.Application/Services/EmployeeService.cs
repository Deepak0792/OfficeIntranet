using SdxCore.Caching;
using SdxCore.Common.Enums.Workflow;
using SdxCore.Common.Helpers;
using SdxCore.Common.Models;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.Employee.Request;
using SdxCore.Employee.Application.DTOs.Employee.Response;
using SdxCore.Employee.Domain.Abstractions;
using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;
using System.Linq.Expressions;

namespace SdxCore.Employee.Application.Services;

public class EmployeeService(
    IEmployeeRepository repository,
    IEmployeeViewRepository viewRepository,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder,
    IEmployeeUnitOfWork unitOfWork) : IEmployeeService
{
    private readonly IEmployeeRepository _repository = repository;
    private readonly IEmployeeViewRepository _viewRepository = viewRepository;
    private readonly ICacheService _cacheService = cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder = cacheKeyBuilder;
    private readonly IEmployeeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<PagedResponse<IEnumerable<EmployeeSummaryResponse>>> GetAllAsync(PaginationFilter filter,
        Guid? departmentId, Guid? locationId, Guid? legalEntityId, string? employmentType, bool? isActive,
        CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(EmployeeSummary), $"all_{filter.PageNumber}_{filter.PageSize}_{departmentId}_{locationId}_{legalEntityId}_{employmentType}_{isActive}");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var (items, count) = await _viewRepository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, ct);

            var responses = PropertyMapper.MapList<EmployeeSummary, EmployeeSummaryResponse>(items);

            return new PagedResponse<IEnumerable<EmployeeSummaryResponse>>(responses, filter.PageNumber, filter.PageSize, count);
        }, CacheOptions.Default, cancellationToken)
            ?? new PagedResponse<IEnumerable<EmployeeSummaryResponse>>(
                [], filter.PageNumber, filter.PageSize, 0);
    }

    public async Task<EmployeeSummaryResponse?> GetFullProfileAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(EmployeeSummary), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var profile = await _viewRepository.GetByIdAsync(id, ct);
            if (profile is null) return null;

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
            if (e is null) return null;

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
            if (e is null) return null;

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

    public async Task<EmployeeSummaryResponse?> GetSummaryAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(EmployeeSummary), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var profile = await _viewRepository.GetByIdAsync(id, cancellationToken);
            if (profile is null) return null;

            return PropertyMapper.Map<EmployeeSummary, EmployeeSummaryResponse>(profile);
        }, CacheOptions.Default, cancellationToken);
    }

    public async Task<EmployeeResponse> CreateAsync(CreateEmployeeRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateEmployeeRequest, Domain.Entities.Employee>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;
        entity.DisplayName = request.DisplayName ?? $"{entity.FirstName} {entity.LastName}";

        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Domain.Entities.Employee, EmployeeResponse>(entity);
    }

    public async Task<bool> UpdateAsync(Guid id, UpdateEmployeeRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;

        PropertyMapper.Patch(request, entity);

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;
    }

    public async Task<bool> ToggleStatusAsync(Guid id, UpdateEmployeeStatusRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;

        entity.IsActive = request.IsActive;

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);


        return true;
    }

    public async Task<bool> UpdatePhotoAsync(Guid id, UpdateEmployeePhotoRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;

        PropertyMapper.Patch(request, entity);

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);


        return true;
    }

    public async Task<bool> UpdateAboutAsync(Guid id, UpdateEmployeeAboutRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;

        PropertyMapper.Patch(request, entity);

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);


        return true;
    }

    public async Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
    List<Guid> designationIds,
    string? scopeCode,
    Guid? scopeReferenceId,
    CancellationToken cancellationToken = default)
    {
        if (designationIds is null || designationIds.Count == 0)
            return [];

        // Build scope filter against vwEmployeeSummary columns
        Expression<Func<EmployeeSummary, bool>> scopePredicate = scopeCode switch
        {
            ScopeTypeCodes.Department when scopeReferenceId.HasValue =>   // DEPARTMENT
                e => e.PrimaryDepartmentId == scopeReferenceId.Value,

            ScopeTypeCodes.Office when scopeReferenceId.HasValue =>   // OFFICE
                e => e.PrimaryLocationId == scopeReferenceId.Value,

            ScopeTypeCodes.LegalEntity when scopeReferenceId.HasValue =>   // LEGAL_ENTITY
                e => e.PrimaryLegalEntityId == scopeReferenceId.Value,

            ScopeTypeCodes.Team when scopeReferenceId.HasValue =>   // TEAM
                e => e.PrimaryTeamId == scopeReferenceId.Value,

            ScopeTypeCodes.Employee when scopeReferenceId.HasValue =>   // EMPLOYEE (single)
                e => e.EmployeeId == scopeReferenceId.Value,

            _ => e => true  // GLOBAL or no scope � no restriction
        };

        var employees = await _viewRepository.FindAsync(
            e => e.DesignationId.HasValue
                && designationIds.Contains(e.DesignationId.Value)
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

    public async Task<IReadOnlyList<EmployeeSummaryResponse>> GetAllEmployeesAsync(bool isActive = true, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(EmployeeSummary), "active");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var profiles = await _viewRepository.FindAsync(e => e.IsActive == isActive, cancellationToken);
            return profiles.Select(p => PropertyMapper.Map<EmployeeSummary, EmployeeSummaryResponse>(p)).ToList();
        }, CacheOptions.Default, cancellationToken) ?? [];
    }
}
