using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Persistence.Data;


namespace SdxCore.Time.Persistence.Repositories;

public class DocumentTypeRepository
    : BaseRepository<DocumentType, Guid, TimeDbContext>, IDocumentTypeRepository
{
    public DocumentTypeRepository(TimeDbContext dbContext) 
        : base(dbContext) { }
}