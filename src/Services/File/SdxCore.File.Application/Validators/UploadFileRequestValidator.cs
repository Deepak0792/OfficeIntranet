using FluentValidation;
using SdxCore.FileStorage.Models;

namespace SdxCore.File.Application.Validators;

/// <summary>
/// Validates UploadFileRequest business rules.
/// Note: IFormFile size guards (avatar ≤ 5 MB, documents ≤ 25 MB) are enforced in the controller
/// because IFormFile is an HTTP-layer concern not available to FluentValidation here.
/// </summary>
public sealed class UploadFileRequestValidator : AbstractValidator<UploadFileRequest>
{
    private static readonly HashSet<string> AllowedFileTypes =
        new(StringComparer.OrdinalIgnoreCase) { "avatar", "documents", "general", "exports" };

    public UploadFileRequestValidator()
    {
        RuleFor(x => x.FileName)
            .NotEmpty().WithMessage("File name is required.")
            .MaximumLength(255).WithMessage("File name cannot exceed 255 characters.");

        RuleFor(x => x.ContentType)
            .NotEmpty().WithMessage("Content type is required.");

        RuleFor(x => x.Microservice)
            .NotEmpty().WithMessage("Microservice name is required.")
            .MaximumLength(100).WithMessage("Microservice name cannot exceed 100 characters.");

        RuleFor(x => x.FileType)
            .NotEmpty().WithMessage("File type is required.")
            .Must(ft => AllowedFileTypes.Contains(ft))
            .WithMessage($"File type must be one of: {string.Join(", ", AllowedFileTypes)}.");
    }
}
