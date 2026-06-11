using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

namespace SdxCore.SharedKernel.Persistence.Data;

public abstract class SdxDbContext : DbContext
{
    protected SdxDbContext(DbContextOptions options)
        : base(options)
    {
    }
}