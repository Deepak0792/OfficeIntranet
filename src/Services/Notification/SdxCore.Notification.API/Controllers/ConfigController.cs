using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace SdxCore.Notification.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ConfigController : ControllerBase
{
    [HttpGet("templates")]
    public IActionResult GetTemplates()
    {
        return Ok(new { message = "Templates OK" });
    }
}
