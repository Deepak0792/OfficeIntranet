using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using System.Linq.Expressions;

namespace SdxCore.SharedKernel.Persistence.Repositories;

public abstract class BaseRepository<TEntity, TKey, TDbContext>
    : IRepository<TEntity, TKey>
    where TEntity : class
    where TKey : struct
    where TDbContext : DbContext
{
    protected readonly TDbContext _dbContext;
    protected readonly DbSet<TEntity> _dbSet;
    protected readonly IUserContext _requestContext;

    protected BaseRepository(
        TDbContext dbContext,
        IUserContext requestContext)
    {
        _dbContext = dbContext;
        _dbSet = dbContext.Set<TEntity>();
        _requestContext = requestContext;
    }

    protected virtual void ApplyAuditFields(TEntity entity, bool isUpdate = false)
    {
        var userId = _requestContext?.UserId;
        var now = DateTime.UtcNow;
        var type = entity.GetType();

        if (!isUpdate)
        {
            SetProperty(entity, type, "CreatedAt", now);
            SetPropertyIfNull(entity, type, "CreatedBy", userId);
        }

        SetProperty(entity, type, "LastUpdatedAt", now);
        SetPropertyIfNull(entity, type, "LastUpdatedBy", userId);
    }

    private static void SetProperty(object entity, Type type, string name, object value)
    {
        var prop = type.GetProperty(name);
        if (prop?.CanWrite == true)
            prop.SetValue(entity, value);
    }

    private static void SetPropertyIfNull(object entity, Type type, string name, object? value)
    {
        var prop = type.GetProperty(name);
        if (prop?.CanWrite == true)
        {
            var current = prop.GetValue(entity);
            if (current == null)
                prop.SetValue(entity, value);
        }
    }

    public virtual async Task<TEntity?> GetByIdAsync(TKey id, CancellationToken cancellationToken = default)
        => await _dbSet.FindAsync(new object[] { id }, cancellationToken);

    public virtual async Task<(IEnumerable<TEntity> Items, int TotalCount)> GetAllPagedAsync(
        int pageNumber,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        var count = await _dbSet.CountAsync(cancellationToken);

        var items = await _dbSet
            .AsNoTracking()
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return (items, count);
    }

    public virtual async Task<IEnumerable<TEntity>> GetAllAsync(CancellationToken cancellationToken = default)
        => await _dbSet.AsNoTracking().ToListAsync(cancellationToken);

    public virtual async Task<IEnumerable<TEntity>> FindAsync(
        Expression<Func<TEntity, bool>> predicate,
        CancellationToken cancellationToken = default)
        => await _dbSet.Where(predicate).ToListAsync(cancellationToken);

    public virtual async Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken = default)
    {
        ApplyAuditFields(entity, false);
        await _dbSet.AddAsync(entity, cancellationToken);
        return entity;
    }

    public virtual async Task AddRangeAsync(IEnumerable<TEntity> entities, CancellationToken cancellationToken = default)
    {
        foreach (var entity in entities)
            ApplyAuditFields(entity, false);

        await _dbSet.AddRangeAsync(entities, cancellationToken);
    }

    public virtual void Update(TEntity entity)
    {
        ApplyAuditFields(entity, true);
        _dbSet.Update(entity);
    }

    public virtual void Remove(TEntity entity)
        => _dbSet.Remove(entity);

    public virtual void RemoveRange(IEnumerable<TEntity> entities)
        => _dbSet.RemoveRange(entities);

    public virtual Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => _dbContext.SaveChangesAsync(cancellationToken);
}