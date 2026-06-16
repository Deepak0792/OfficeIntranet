namespace SdxCore.Attendance.Application.DTOs.Employee;

/// <summary>Thin DTO returned by the Employee service for scope-resolution purposes.</summary>
public record EmployeeSummaryResponse(
    Guid EmployeeId,
    string? DisplayName,
    Guid? TeamId,
    Guid? DepartmentId,
    Guid? OfficeId,
    Guid? LegalEntityId,
    Guid? CountryId,
    Guid? DesignationId,
    Guid? ManagerId,
    bool IsActive);

public record EmployeesByDesignationResponse(
    Guid EmployeeId,
    string DisplayName,
    Guid? DesignationId,
    Guid? PrimaryDepartmentId);
