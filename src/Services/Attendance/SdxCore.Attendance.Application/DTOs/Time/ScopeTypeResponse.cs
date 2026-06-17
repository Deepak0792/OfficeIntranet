namespace SdxCore.Attendance.Application.DTOs.Time;

public class ScopeTypeResponse
{
    public Guid Id { get; set; }
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }

    /// <summary>Numeric hierarchy level (1=GLOBAL, 2=COUNTRY, 3=LEGAL_ENTITY, 4=OFFICE, 5=DEPARTMENT, 6=TEAM, 7=EMPLOYEE).</summary>
    public short HierarchyLevel { get; set; }

    public bool IsActive { get; set; }
}
