using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace SdxCore.File.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UploadController : ControllerBase
{
    // In a real implementation, this would inject IFileStorageService
    // private readonly IFileStorageService _fileStorage;
    // 
    // public UploadController(IFileStorageService fileStorage)
    // {
    //     _fileStorage = fileStorage;
    // }

    [HttpPost]
    public async Task<IActionResult> Upload(IFormFile file, CancellationToken cancellationToken)
    {
        if (file == null || file.Length == 0)
            return BadRequest("File is empty or not selected.");

        // Stub logic since IFileStorageService wasn't explicitly scaffolded in the building blocks yet
        var fileName = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
        
        // await _fileStorage.UploadAsync(file.OpenReadStream(), fileName, file.ContentType, cancellationToken);

        var fileUrl = $"https://cdn.sdxcore.local/files/{fileName}";
        
        return Ok(new { Url = fileUrl, FileName = fileName, OriginalName = file.FileName });
    }
}
