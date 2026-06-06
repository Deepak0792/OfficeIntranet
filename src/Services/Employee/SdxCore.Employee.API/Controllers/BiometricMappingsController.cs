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
public class BiometricMappingsController : SdxControllerBase
{
    private readonly IEmployeeBiometricMappingService _service;

    public BiometricMappingsController(IEmployeeBiometricMappingService service)
    {
        _service = service;
    }

    [HttpGet("api/v1/employees/{employeeId}/biometric-mappings")]
    public async Task<IActionResult> GetByEmployeeId(int employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByEmployeeIdAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<System.Collections.Generic.IEnumerable<EmployeeBiometricMappingResponse>>(result, "Biometric mappings fetched successfully."));
    }

    [HttpGet("api/v1/employees/{employeeId}/biometric-mappings/{id}")]
    public async Task<IActionResult> GetById(int employeeId, int id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Biometric mapping fetched successfully.");
    }

    [HttpGet("api/v1/biometric-mappings/by-device/{deviceId}")]
    public async Task<IActionResult> GetByDeviceId(int deviceId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByDeviceIdAsync(deviceId, cancellationToken);
        return Ok(new ApiResponse<System.Collections.Generic.IEnumerable<EmployeeBiometricMappingResponse>>(result, "Biometric mappings fetched successfully."));
    }

    [HttpPost("api/v1/employees/{employeeId}/biometric-mappings")]
    public async Task<IActionResult> Add(int employeeId, [FromBody] CreateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.AddAsync(employeeId, request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { employeeId, id = result.Id }, new ApiResponse<EmployeeBiometricMappingResponse>(result, "Biometric mapping created successfully."));
    }

    [HttpPut("api/v1/employees/{employeeId}/biometric-mappings/{id}")]
    public async Task<IActionResult> Update(int employeeId, int id, [FromBody] UpdateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(employeeId, id, request, cancellationToken);
        return Ok(new ApiResponse<EmployeeBiometricMappingResponse>(result, "Biometric mapping updated successfully."));
    }

    [HttpPatch("api/v1/employees/{employeeId}/biometric-mappings/{id}/status")]
    public async Task<IActionResult> ToggleStatus(int employeeId, int id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(employeeId, id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Biometric mapping status updated successfully.");
    }
}