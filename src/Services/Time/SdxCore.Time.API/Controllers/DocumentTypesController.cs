using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Application.Contracts.Services;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/document-types")]
[GatewayOnly]
public class DocumentTypesController : ControllerBase
{
    private readonly IDocumentTypeService _service;
    private readonly ILogger<DocumentTypesController> _logger;

    public DocumentTypesController(IDocumentTypeService service, ILogger<DocumentTypesController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _service.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<DocumentTypeResponse>>(result, "Successfully fetched DocumentTypes."));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(short id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "DocumentType not found." });

        return Ok(new ApiResponse<DocumentTypeResponse>(result, "Successfully fetched DocumentType."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateDocumentTypeRequest dto, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var result = await _service.CreateAsync(dto, cancellationToken);
        var response = new ApiResponse<DocumentTypeResponse>(result, "DocumentType created successfully.");

        return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(short id, [FromBody] UpdateDocumentTypeRequest dto, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "DocumentType not found." });

        return Ok(new ApiResponse<bool>(true, "DocumentType updated successfully."));
    }

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> ToggleStatus(short id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {

        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "DocumentType not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"DocumentType {statusStr} successfully."));
    }
}