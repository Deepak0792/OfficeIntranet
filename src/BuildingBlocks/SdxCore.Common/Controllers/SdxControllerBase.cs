using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using FluentValidation;
using FluentValidation.Results;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Common.Models;

namespace SdxCore.Common.Controllers;

[ApiController]
public abstract class SdxControllerBase : ControllerBase
{
    protected virtual ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Resource not found." };

    protected IActionResult OkOrNotFound<T>(T? result, string message) where T : class =>
        result is null ? NotFound(NotFoundError) : Ok(new ApiResponse<T>(result, message));

    protected IActionResult OkOrNotFound(bool result, string message) =>
        result ? Ok(new ApiResponse<bool>(true, message)) : NotFound(NotFoundError);

    protected IActionResult ValidationError(ValidationResult validation) =>
        BadRequest(new ErrorResponse
        {
            ErrorCode = "VALIDATION_ERROR",
            ErrorMessage = string.Join("; ", validation.Errors.Select(e => e.ErrorMessage))
        });

    /// <summary>
    /// Resolves IValidator&lt;T&gt; from DI and returns a BadRequest result if invalid, or null if valid.
    /// No validator registered = treated as valid (passes through).
    /// </summary>
    protected async Task<IActionResult?> ValidateAsync<T>(T request, CancellationToken cancellationToken)
    {
        var validator = HttpContext.RequestServices.GetService<IValidator<T>>();
        if (validator is null) return null;

        var result = await validator.ValidateAsync(request, cancellationToken);
        return result.IsValid ? null : ValidationError(result);
    }
}