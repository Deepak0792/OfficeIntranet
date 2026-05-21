using System;
using System.IO;
using System.Linq;

var controllersPath = @"d:\Office\SdxCore\src\Services\Time\SdxCore.Time.API\Controllers";
var files = Directory.GetFiles(controllersPath, "*.cs");

foreach (var file in files)
{
    var fileName = Path.GetFileNameWithoutExtension(file);
    if (!fileName.EndsWith("Controller")) continue;
    
    // Convert "BiometricDevicesController" to "BiometricDevice"
    var entityNamePlural = fileName.Substring(0, fileName.Length - "Controller".Length);
    var entityName = entityNamePlural;
    
    if (entityName.EndsWith("ies")) {
        entityName = entityName.Substring(0, entityName.Length - 3) + "y";
    } else if (entityName.EndsWith("s")) {
        entityName = entityName.Substring(0, entityName.Length - 1);
    }
    
    var content = File.ReadAllText(file);
    
    // Fix GetById missing message
    var getByIdTarget = $"return Ok(new ApiResponse<{entityName}Response>(result));";
    var getByIdReplacement = $"return Ok(new ApiResponse<{entityName}Response>(result, \"Successfully fetched {entityName}.\"));";
    content = content.Replace(getByIdTarget, getByIdReplacement);
    
    // Fix Tree/Children/Ancestors/ByCountry missing message
    var getListTarget = $"return Ok(new ApiResponse<IEnumerable<{entityName}Response>>(result));";
    var getListReplacement = $"return Ok(new ApiResponse<IEnumerable<{entityName}Response>>(result, \"Successfully fetched {entityName} list.\"));";
    content = content.Replace(getListTarget, getListReplacement);
    
    // Fix BiometricDevice Pagination missing message
    if (fileName == "BiometricDevicesController")
    {
        var pagedTarget = @"var response = await _service.GetAllAsync(filter, cancellationToken);
            return Ok(response);";
        var pagedReplacement = @"var response = await _service.GetAllAsync(filter, cancellationToken);
            response.Message = ""Successfully fetched BiometricDevices."";
            return Ok(response);";
        content = content.Replace(pagedTarget, pagedReplacement);
    }
    
    File.WriteAllText(file, content);
    Console.WriteLine($"Updated {fileName}");
}
