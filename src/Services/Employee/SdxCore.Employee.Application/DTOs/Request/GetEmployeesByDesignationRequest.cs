namespace SdxCore.Employee.Application.DTOs.Request;
public class GetEmployeesByDesignationRequest
{
    /// <summary>
    /// One or more DesignationIds to match against employee.DesignationId.
    /// Passed as repeated query params: ?designationIds=3&designationIds=7
    /// </summary>
    public List<short> DesignationIds { get; set; } = [];

    /// <summary>
    /// FK → time.ScopeType.Id  (5=DEPARTMENT, 4=OFFICE, 3=LEGAL_ENTITY, 6=TEAM, 7=EMPLOYEE, 1=GLOBAL)
    /// NULL = no scope restriction, return company-wide.
    /// </summary>
    public short? ScopeTypeId { get; set; }

    /// <summary>
    /// The reference entity ID within the scope (e.g. DepartmentId=7 when ScopeTypeId=5).
    /// NULL = resolve from initiator's own scope.
    /// </summary>
    public int? ScopeReferenceId { get; set; }
}
