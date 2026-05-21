namespace SdxCore.Time.Domain.Entities;
public class Designation : BaseEntity {
    public short Id { get; set; }
    public required string DesignationCode { get; set; }
    public required string DesignationName { get; set; }
    public string? Grade { get; set; }
}
