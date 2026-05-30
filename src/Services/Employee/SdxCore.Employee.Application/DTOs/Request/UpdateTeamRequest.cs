namespace SdxCore.Employee.Application.DTOs.Request;

public class UpdateTeamRequest
{
    public required string TeamName { get; set; }
    public string? TeamType { get; set; }
    public string? Description { get; set; }
}
