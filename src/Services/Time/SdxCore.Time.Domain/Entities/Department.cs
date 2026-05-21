namespace SdxCore.Time.Domain.Entities;
public class Department : BaseEntity {
    public short Id { get; set; }
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public short? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
    public Department? ParentDepartment { get; set; }
}
