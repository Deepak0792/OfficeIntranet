using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Attendance.Application.Services;

namespace SdxCore.Attendance.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LeaveController : ControllerBase
{
    private readonly ILeaveRequestService _leaveService;

    public LeaveController(ILeaveRequestService leaveService)
    {
        _leaveService = leaveService;
    }

    [HttpPost]
    public async Task<IActionResult> SubmitLeaveRequest([FromBody] LeaveRequestDto request, CancellationToken cancellationToken)
    {
        var result = await _leaveService.SubmitLeaveRequestAsync(
            request.EmployeeId, 
            request.LeaveTypeId, 
            request.FromDate, 
            request.ToDate, 
            request.Reason, 
            cancellationToken);
            
        return Ok(result);
    }
}

public class LeaveRequestDto
{
    public int EmployeeId { get; set; }
    public short LeaveTypeId { get; set; }
    public System.DateTime FromDate { get; set; }
    public System.DateTime ToDate { get; set; }
    public string Reason { get; set; } = string.Empty;
}
