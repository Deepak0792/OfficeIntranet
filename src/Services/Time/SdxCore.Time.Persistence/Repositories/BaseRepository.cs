using SdxCore.Common.Interfaces.Contexts;
using Microsoft.EntityFrameworkCore;
using SdxCore.Common.Interfaces.Data;
using SdxCore.Time.Persistence.Data;
using System.Linq.Expressions;
using System.Diagnostics;

namespace SdxCore.Time.Persistence.Repositories;

public abstract class BaseRepository<TEntity, TKey> : IRepository<TEntity, TKey> 
    where TEntity : class 
    where TKey : struct
{
    protected readonly TimeDbContext _dbContext;
    protected readonly DbSet<TEntity> _dbSet;
    protected readonly IRequestContext _requestContext;

    protected BaseRepository(TimeDbContext dbContext, IRequestContext requestContext)
    {
        _dbContext = dbContext;
        _dbSet = dbContext.Set<TEntity>();
        _requestContext = requestContext;
    }

    protected virtual void ApplyAuditFields(TEntity entity, bool isUpdate = false)
    {
        int? userId = _requestContext?.UserId;

        var now = DateTime.UtcNow;
        var type = entity.GetType();

        if (!isUpdate)
        {
            var createdAtProp = type.GetProperty("CreatedAt");
            if (createdAtProp != null && createdAtProp.CanWrite)
                createdAtProp.SetValue(entity, now);

            var createdByProp = type.GetProperty("CreatedBy");
            if (createdByProp != null && createdByProp.CanWrite)
            {
                var currentValue = createdByProp.GetValue(entity);

                if (currentValue == null)
                {
                    createdByProp.SetValue(entity, userId);
                }
            }
        }

        var lastUpdatedProp = type.GetProperty("LastUpdatedAt");
        if (lastUpdatedProp != null && lastUpdatedProp.CanWrite)
            lastUpdatedProp.SetValue(entity, now);

        var lastUpdatedByProp = type.GetProperty("LastUpdatedBy");
        if (lastUpdatedByProp != null && lastUpdatedByProp.CanWrite)
        {
            var currentValue = lastUpdatedByProp.GetValue(entity);

            if (currentValue == null)
            {
                lastUpdatedByProp.SetValue(entity, userId);
            }
        }
    }

    public virtual async Task<TEntity?> GetByIdAsync(TKey id, CancellationToken cancellationToken = default)
    {
        return await _dbSet.FindAsync(new object[] { id }, cancellationToken);
    }

        public virtual async Task<(IEnumerable<TEntity> Items, int TotalCount)> GetAllPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var count = await _dbSet.CountAsync(cancellationToken);
        var items = await _dbSet.AsNoTracking()
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);
        return (items, count);
    }

    public virtual async Task<IEnumerable<TEntity>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet.AsNoTracking().ToListAsync(cancellationToken);
    }

    public virtual async Task<IEnumerable<TEntity>> FindAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default)
    {
        return await _dbSet.Where(predicate).ToListAsync(cancellationToken);
    }

    public virtual async Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken = default)
    {
        ApplyAuditFields(entity, isUpdate: false);
        await _dbSet.AddAsync(entity, cancellationToken);
        return entity;
    }

    public virtual async Task AddRangeAsync(IEnumerable<TEntity> entities, CancellationToken cancellationToken = default)
    {
        foreach (var entity in entities)
        {
            ApplyAuditFields(entity, isUpdate: false);
        }
        await _dbSet.AddRangeAsync(entities, cancellationToken);
    }

    public virtual void Update(TEntity entity)
    {
        ApplyAuditFields(entity, isUpdate: true);
        _dbSet.Update(entity);
    }

    public virtual void Remove(TEntity entity)
    {
        _dbSet.Remove(entity);
    }

    public virtual void RemoveRange(IEnumerable<TEntity> entities)
    {
        _dbSet.RemoveRange(entities);
    }

    public virtual async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _dbContext.SaveChangesAsync(cancellationToken);
    }
}


