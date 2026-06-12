using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.File.Application.Abstractions.Services;
using SdxCore.FileStorage.Models;

namespace SdxCore.File.API.Controllers;

[ApiController]
[Route("api/v1/files")]
[GatewayOnly]
public class FileController : SdxControllerBase
{
    private readonly IFileService _fileService;
    private readonly ILogger<FileController> _logger;

    public FileController(IFileService fileService, ILogger<FileController> logger)
    {
        _fileService = fileService;
        _logger = logger;
    }

    /// <summary>
    /// Uploads a file. Size limits: avatar ≤ 5 MB, documents ≤ 25 MB, general ≤ 100 MB.
    /// </summary>
    [HttpPost("upload")]
    [RequestSizeLimit(104857600)] // 100 MB absolute max
    public async Task<IActionResult> UploadAsync(
        [FromForm] IFormFile file,
        [FromForm] string microservice,
        [FromForm] string fileType = "general",
        CancellationToken cancellationToken = default)
    {
        // IFormFile guards — must stay here since IFormFile is an HTTP-layer concern
        if (file == null || file.Length == 0)
            return BadRequest(new ErrorResponse { ErrorCode = "NO_FILE", ErrorMessage = "No file uploaded." });

        if (fileType.Equals("avatar", StringComparison.OrdinalIgnoreCase) && file.Length > 5 * 1024 * 1024)
            return BadRequest(new ErrorResponse { ErrorCode = "FILE_TOO_LARGE", ErrorMessage = "Profile photo cannot exceed 5 MB." });

        if (fileType.Equals("documents", StringComparison.OrdinalIgnoreCase) && file.Length > 25 * 1024 * 1024)
            return BadRequest(new ErrorResponse { ErrorCode = "FILE_TOO_LARGE", ErrorMessage = "Document cannot exceed 25 MB." });

        using var stream = file.OpenReadStream();

        var request = new UploadFileRequest
        {
            Stream      = stream,
            FileName    = file.FileName,
            ContentType = file.ContentType,
            Microservice = microservice,
            FileType    = fileType
        };

        // Application-layer validation (filename, content type, microservice, fileType enum)
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _fileService.UploadAsync(request, cancellationToken);
        return Ok(new ApiResponse<object>(result, "File uploaded successfully."));
    }

    /// <summary>Downloads a file by its encrypted path.</summary>
    [HttpGet("download")]
    public async Task<IActionResult> DownloadAsync(
        [FromQuery] string filePath,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(filePath))
            return BadRequest(new ErrorResponse { ErrorCode = "MISSING_PATH", ErrorMessage = "File path is required." });

        var result = await _fileService.DownloadAsync(filePath, cancellationToken);
        return File(result.Stream, result.ContentType, result.OriginalFileName);
    }
}
