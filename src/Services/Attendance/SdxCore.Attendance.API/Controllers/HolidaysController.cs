using Microsoft.AspNetCore.Mvc;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Holiday.Request;
using SdxCore.Attendance.Application.DTOs.Holiday.Response;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;

namespace SdxCore.Attendance.API.Controllers;

[ApiController]
[Route("api/v1/holidays")]
[GatewayOnly]
public class HolidaysController(IHolidayService service) : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Holiday not found." };

    [HttpGet("calendars")]
    public async Task<IActionResult> GetAllCalendars(CancellationToken cancellationToken)
    {
        var result = await service.GetAllCalendarsAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<HolidayCalendarResponse>>(result, "Holiday calendars fetched."));
    }

    [HttpGet("calendars/{id:guid}")]
    public async Task<IActionResult> GetCalendar(Guid id, CancellationToken cancellationToken)
    {
        var result = await service.GetCalendarByIdAsync(id, cancellationToken);
        return OkOrNotFound(result, "Calendar fetched.");
    }

    [HttpPost("calendars")]
    public async Task<IActionResult> CreateCalendar([FromBody] CreateHolidayCalendarRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.CreateCalendarAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetCalendar), new { id = result.Id },
            new ApiResponse<HolidayCalendarResponse>(result, "Calendar created."));
    }

    [HttpGet("calendars/{calendarId:guid}/holidays")]
    public async Task<IActionResult> GetByCalendar(Guid calendarId, [FromQuery] int year, CancellationToken cancellationToken)
    {
        var result = await service.GetByCalendarAsync(calendarId, year, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<HolidayResponse>>(result, "Holidays fetched."));
    }

    [HttpPost]
    public async Task<IActionResult> CreateHoliday([FromBody] CreateHolidayRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.CreateHolidayAsync(request, cancellationToken);
        return Ok(new ApiResponse<HolidayResponse>(result, "Holiday created."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateHolidayRequest request, CancellationToken cancellationToken)
    {
        var result = await service.UpdateHolidayAsync(id, request, cancellationToken);
        return result is not null
            ? Ok(new ApiResponse<HolidayResponse>(result, "Holiday updated."))
            : NotFound(NotFoundError);
    }

    [HttpPatch("{id:guid}/toggle-status")]
    public async Task<IActionResult> ToggleStatus(Guid id, CancellationToken cancellationToken)
    {
        var result = await service.ToggleHolidayStatusAsync(id, cancellationToken);
        return result is not null
            ? Ok(new ApiResponse<HolidayResponse>(result, "Holiday status toggled."))
            : NotFound(NotFoundError);
    }

    [HttpGet("applicable")]
    public async Task<IActionResult> GetApplicable([FromQuery] Guid employeeId, [FromQuery] DateOnly from, [FromQuery] DateOnly to, CancellationToken cancellationToken)
    {
        var result = await service.GetApplicableAsync(employeeId, from, to, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<HolidayResponse>>(result, "Applicable holidays fetched."));
    }
}
