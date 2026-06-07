namespace SdxCore.Workflow.Domain.Exceptions;

public class EmployeeScopeResolutionException(int employeeId)
    : Exception($"Unable to determine scope for employee {employeeId}")
{
}
