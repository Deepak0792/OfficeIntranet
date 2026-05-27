using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Workflow.Domain.Interfaces.Services;

public interface IWorkflowResolutionService
{
    Task InitiateWorkflowAsync(string moduleCode, int referenceTransactionId, int initiatorEmployeeId, CancellationToken cancellationToken = default);
    Task AdvanceWorkflowAsync(int instanceId, CancellationToken cancellationToken);
}
