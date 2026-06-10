namespace SdxCore.Workflow.Domain.Exceptions;

public class EmployeeScopeResolutionException(Guid employeeId)
    : Exception($"Unable to determine scope for employee {employeeId}")
{
}
