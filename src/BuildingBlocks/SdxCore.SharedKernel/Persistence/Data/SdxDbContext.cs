using Microsoft.EntityFrameworkCore;

namespace SdxCore.SharedKernel.Persistence.Data;

public abstract class SdxDbContext : DbContext
{
    protected SdxDbContext(DbContextOptions options)
        : base(options)
    {
    }
}