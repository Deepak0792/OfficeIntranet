namespace SdxCore.Workflow.Application.Services;

public record EmployeeOrgInfo(
    int EmployeeId,
    string DisplayName,
    string? DesignationName,
    string? DepartmentName);
