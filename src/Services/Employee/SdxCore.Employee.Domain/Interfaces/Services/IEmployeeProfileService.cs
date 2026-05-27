using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Domain.DTOs.Request;

namespace SdxCore.Employee.Domain.Interfaces.Services;

public interface IEmployeeProfileService
{
    Task<bool> AddAddressAsync(int employeeId, AddEmployeeAddressRequest request, CancellationToken cancellationToken = default);
    Task<bool> AddDocumentAsync(int employeeId, AddEmployeeDocumentRequest request, CancellationToken cancellationToken = default);
}
