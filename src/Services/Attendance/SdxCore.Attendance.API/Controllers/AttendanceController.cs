using Microsoft.AspNetCore.Mvc;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Attendance.Request;
using SdxCore.Attendance.Application.DTOs.Attendance.Response;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;

namespace SdxCore.Attendance.API.Controllers;

[ApiController]
[Route("api/v1/attendance")]
[GatewayOnly]
public class AttendanceController(IAttendanceService service) : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Attendance record not found." };

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 20,
        [FromQuery] Guid? employeeId = null, [FromQuery] DateOnly? from = null, [FromQuery] DateOnly? to = null,
        CancellationToken cancellationToken = default)
    {
        var result = await service.GetAllAsync(page, pageSize, employeeId, from, to, cancellationToken);
        result.Message = "Attendance records fetched.";
        return Ok(result);
    }

    [HttpGet("employee/{employeeId:guid}/date/{date}")]
    public async Task<IActionResult> GetByEmployeeDate(Guid employeeId, DateOnly date, CancellationToken cancellationToken)
    {
        var result = await service.GetByEmployeeDateAsync(employeeId, date, cancellationToken);
        return OkOrNotFound(result, "Attendance record fetched.");
    }

    [HttpPost("check-in")]
    public async Task<IActionResult> CheckIn([FromBody] CheckInRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.CheckInAsync(request, cancellationToken);
        return OkOrNotFound(result, "Check-in recorded.");
    }

    [HttpPost("check-out")]
    public async Task<IActionResult> CheckOut([FromBody] CheckOutRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.CheckOutAsync(request, cancellationToken);
        return OkOrNotFound(result, "Check-out recorded.");
    }

    [HttpPost("process-daily")]
    public async Task<IActionResult> ProcessDaily([FromQuery] DateOnly date, CancellationToken cancellationToken)
    {
        await service.ProcessDailyAsync(date, cancellationToken);
        return Ok(new ApiResponse<bool>(true, $"Daily attendance processed for {date:yyyy-MM-dd}."));
    }

    [HttpPatch("{id:guid}/lock")]
    public async Task<IActionResult> Lock(Guid id, CancellationToken cancellationToken)
    {
        var success = await service.LockAsync(id, cancellationToken);
        return success
            ? Ok(new ApiResponse<bool>(success, "Attendance record locked."))
            : NotFound(NotFoundError);
    }
}
