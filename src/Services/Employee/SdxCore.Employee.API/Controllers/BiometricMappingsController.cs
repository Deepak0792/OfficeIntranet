using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.API.Controllers;

[ApiController]
[GatewayOnly]
[Route("api/v1")]
public class BiometricMappingsController : SdxControllerBase
{
    private readonly IEmployeeBiometricMappingService _service;

    public BiometricMappingsController(IEmployeeBiometricMappingService service)
    {
        _service = service;
    }

    [HttpGet("employees/{employeeId:guid}/biometric-mappings")]
    public async Task<IActionResult> GetByEmployeeId(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByEmployeeIdAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<System.Collections.Generic.IEnumerable<EmployeeBiometricMappingResponse>>(result, "Biometric mappings fetched successfully."));
    }

    [HttpGet("employees/{employeeId:guid}/biometric-mappings/{id:guid}")]
    public async Task<IActionResult> GetById(Guid employeeId, Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Biometric mapping fetched successfully.");
    }

    [HttpGet("biometric-mappings/by-device/{deviceId:guid}")]
    public async Task<IActionResult> GetByDeviceId(Guid deviceId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByDeviceIdAsync(deviceId, cancellationToken);
        return Ok(new ApiResponse<System.Collections.Generic.IEnumerable<EmployeeBiometricMappingResponse>>(result, "Biometric mappings fetched successfully."));
    }

    [HttpPost("employees/{employeeId:guid}/biometric-mappings")]
    public async Task<IActionResult> Add(Guid employeeId, [FromBody] CreateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.AddAsync(employeeId, request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { employeeId, id = result.Id }, new ApiResponse<EmployeeBiometricMappingResponse>(result, "Biometric mapping created successfully."));
    }

    [HttpPut("employees/{employeeId:guid}/biometric-mappings/{id:guid}")]
    public async Task<IActionResult> Update(Guid employeeId, Guid id, [FromBody] UpdateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(employeeId, id, request, cancellationToken);
        return Ok(new ApiResponse<EmployeeBiometricMappingResponse>(result, "Biometric mapping updated successfully."));
    }

    [HttpPatch("employees/{employeeId:guid}/biometric-mappings/{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid employeeId, Guid id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(employeeId, id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Biometric mapping status updated successfully.");
    }
}