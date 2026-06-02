using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using SdxCore.Shared.Domain.Entities;
using SdxCore.Shared.Domain.Repositories;
using SdxCore.Shared.Persistence.Data;

namespace SdxCore.Shared.Persistence.Repositories;

public class LookupRepository : ILookupRepository
{
    private readonly SharedDbContext _context;

    public LookupRepository(SharedDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<LookupItem>> GetLookupAsync(string code, string? parentId = null, CancellationToken cancellationToken = default)
    {
        var codeParam = new SqlParameter("@LookupCode", code);
        
        var sql = "EXEC shared.GetLookup @LookupCode";
        var parameters = new List<object> { codeParam };

        if (!string.IsNullOrEmpty(parentId))
        {
            var parentIdParam = new SqlParameter("@ParentId", parentId);
            sql = "EXEC shared.GetLookup @LookupCode, @ParentId";
            parameters.Add(parentIdParam);
        }

        var result = await _context.Database.SqlQueryRaw<LookupItem>(sql, parameters.ToArray()).ToListAsync(cancellationToken);
        
        return result;
    }
}

