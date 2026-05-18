using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class DocumentTypeRepository : BaseRepository<DocumentType>, IDocumentTypeRepository
{
    public DocumentTypeRepository(TimeDbContext dbContext) : base(dbContext) { }
}
