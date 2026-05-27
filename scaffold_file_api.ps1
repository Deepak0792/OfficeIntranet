$apiDir = "d:\Office\SdxCore\src\Services\File\SdxCore.File.API"
New-Item -ItemType Directory -Force -Path "$apiDir\Controllers" | Out-Null

$csprojPath = "$apiDir\SdxCore.File.API.csproj"
$csprojContent = @"
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="9.0.1" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="7.0.0" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\..\BuildingBlocks\SdxCore.Common\SdxCore.Common.csproj" />
  </ItemGroup>
</Project>
"@
Set-Content -Path $csprojPath -Value $csprojContent

$controllerCode = @"
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
"@
Set-Content -Path "$apiDir\Controllers\UploadController.cs" -Value $controllerCode

$programCode = @"
using SdxCore.Common.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Common Layer
builder.Services.AddSdxCoreCommon(builder.Configuration);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
"@
Set-Content -Path "$apiDir\Program.cs" -Value $programCode

Write-Output "Successfully generated File API."
