using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Time.Application.Abstractions.Services;
using SdxCore.Time.Application.DTOs.DocumentType.Request;
using SdxCore.Time.Application.DTOs.DocumentType.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Domain.Abstractions;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Application.Services;

public class DocumentTypeService : IDocumentTypeService
{
    private readonly IDocumentTypeRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    private readonly ITimeUnitOfWork _unitOfWork;

    public DocumentTypeService(
        IDocumentTypeRepository repository, 
        ICacheService cacheService, 
        ICacheKeyBuilder cacheKeyBuilder,
        ITimeUnitOfWork unitOfWork)
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<DocumentTypeResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(DocumentType), "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(e => PropertyMapper.Map<DocumentType, DocumentTypeResponse>(e));
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<DocumentTypeResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(DocumentType), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity == null) return null;
            return PropertyMapper.Map<DocumentType, DocumentTypeResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<DocumentTypeResponse> CreateAsync(CreateDocumentTypeRequest dto, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateDocumentTypeRequest, DocumentType>(dto);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<bool> UpdateAsync(Guid id, UpdateDocumentTypeRequest dto, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        PropertyMapper.MapProperties(dto, entity);

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.IsActive = request.IsActive;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}