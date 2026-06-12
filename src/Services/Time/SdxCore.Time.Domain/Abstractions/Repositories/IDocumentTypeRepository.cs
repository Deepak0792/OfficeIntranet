using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Domain.Abstractions.Repositories;

public interface IDocumentTypeRepository : IRepository<DocumentType, Guid> { }

