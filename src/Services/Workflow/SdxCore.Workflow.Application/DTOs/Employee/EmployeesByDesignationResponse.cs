namespace SdxCore.Workflow.Application.DTOs.Response;
/// <summary>
/// Lightweight projection returned for approver resolution.
/// Matches the ResolvedApprover record fields in the Workflow engine.
/// </summary>
public class EmployeesByDesignationResponse
{
    public Guid EmployeeId { get; set; }
    public string DisplayName { get; set; } = null!;
    public Guid? DesignationId { get; set; }
    public Guid? PrimaryDepartmentId { get; set; }
}