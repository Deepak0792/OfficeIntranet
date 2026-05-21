namespace SdxCore.Time.Domain.DTOs;

public class DesignationDto
{
    public short Id { get; set; }
    public required string DesignationCode { get; set; }
    public required string DesignationName { get; set; }
    public string? Grade { get; set; }
    public bool IsActive { get; set; }
}

public class CreateDesignationDto
{
    public required string DesignationCode { get; set; }
    public required string DesignationName { get; set; }
    public string? Grade { get; set; }
}

public class UpdateDesignationDto : CreateDesignationDto { }
