using Microsoft.AspNetCore.Mvc;
using SdxCore.FileStorage.Abstractions;
using SdxCore.FileStorage.Models;
using System.IO;

namespace SdxCore.File.API.Controllers;

[ApiController]
[Route("api/v1/files")]
public class FileController : ControllerBase
{
    private readonly IFileStorageService _fileStorageService;
    private readonly ILogger<FileController> _logger;

    public FileController(IFileStorageService fileStorageService, ILogger<FileController> logger)
    {
        _fileStorageService = fileStorageService;
        _logger = logger;
    }

    [HttpPost("upload")]
    [RequestSizeLimit(104857600)] // 100 MB max for bulk exports
    public async Task<IActionResult> UploadAsync(
        [FromForm] IFormFile file, 
        [FromForm] string microservice, 
        [FromForm] string fileType = "general", 
        CancellationToken cancellationToken = default)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest("No file uploaded.");
        }

        if (string.IsNullOrWhiteSpace(microservice))
        {
            return BadRequest("Microservice name is required.");
        }

        // Basic Size Validation based on type
        if (fileType.Equals("avatar", StringComparison.OrdinalIgnoreCase) && file.Length > 5 * 1024 * 1024)
            return BadRequest("Profile photo cannot exceed 5 MB.");
        
        if (fileType.Equals("documents", StringComparison.OrdinalIgnoreCase) && file.Length > 25 * 1024 * 1024)
            return BadRequest("General document cannot exceed 25 MB.");

        using var stream = file.OpenReadStream();
        var request = new FileUploadRequest
        {
            Stream = stream,
            FileName = file.FileName,
            ContentType = file.ContentType,
            Microservice = microservice,
            FileType = fileType
        };

        var result = await _fileStorageService.UploadAsync(request, cancellationToken);
        return Ok(result);
    }

    [HttpGet("download")]
    public async Task<IActionResult> DownloadAsync([FromQuery] string filePath, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(filePath))
        {
            return BadRequest("File path is required.");
        }

        try
        {
            var result = await _fileStorageService.DownloadAsync(filePath, cancellationToken);
            return File(result.Stream, result.ContentType, result.OriginalFileName);
        }
        catch (FileNotFoundException)
        {
            return NotFound("File not found.");
        }
    }
}
