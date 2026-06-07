namespace SdxCore.Workflow.Application.DTOs.Response;
/// <summary>
/// Lightweight projection returned for approver resolution.
/// Matches the ResolvedApprover record fields in the Workflow engine.
/// </summary>
public class EmployeesByDesignationResponse
{
    public int EmployeeId { get; set; }
    public string DisplayName { get; set; } = null!;
    public short? DesignationId { get; set; }
    public short? PrimaryDepartmentId { get; set; }
}