using Microsoft.AspNetCore.Mvc;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.CompOff.Request;
using SdxCore.Attendance.Application.DTOs.CompOff.Response;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;

namespace SdxCore.Attendance.API.Controllers;

[ApiController]
[Route("api/v1/comp-offs")]
[GatewayOnly]
public class CompOffsController(ICompOffService service) : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Comp-off balance not found." };

    [HttpGet("employee/{employeeId:guid}/balance")]
    public async Task<IActionResult> GetBalance(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await service.GetBalanceAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<CompOffBalanceResponse>>(result, "Comp-off balance fetched."));
    }

    [HttpPost("earn")]
    public async Task<IActionResult> Earn([FromBody] EarnCompOffRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.EarnAsync(request, cancellationToken);
        return Ok(new ApiResponse<CompOffBalanceResponse>(result, "Comp-off earned."));
    }

    [HttpPost("redeem")]
    public async Task<IActionResult> Redeem([FromBody] RedeemCompOffRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.RedeemAsync(request, cancellationToken);
        return Ok(new ApiResponse<CompOffBalanceResponse>(result, "Comp-off redeemed."));
    }
}
