namespace SdxCore.Attendance.Application.DTOs.Employee;

public sealed class EmployeeScopeContext
{
    public Guid EmployeeId { get; init; }

    public Guid? TeamId { get; init; }

    public Guid? DepartmentId { get; init; }

    public Guid? LegalEntityId { get; init; }

    public Guid? OfficeLocationId { get; init; }

    public Guid? CountryId { get; init; }

    public Guid? ManagerId { get; init; }
}