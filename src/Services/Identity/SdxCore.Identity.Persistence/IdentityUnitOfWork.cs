using SdxCore.Identity.Domain;
using SdxCore.Identity.Persistence.Data;
using SdxCore.SharedKernel.Persistence;

namespace SdxCore.Identity.Persistence;


public sealed class IdentityUnitOfWork : UnitOfWork<IdentityDbContext>, IIdentityUnitOfWork
{
    public IdentityUnitOfWork(IdentityDbContext dbContext) : base(dbContext) { }
}