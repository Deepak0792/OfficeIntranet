using FluentValidation.Resources;

namespace SdxCore.Common.Validators;

/// <summary>
/// Centralized FluentValidation language manager.
/// Defines consistent, human-readable error messages for all standard validators
/// across every SdxCore microservice.
///
/// Registration:
///   Called once by <see cref="SdxCore.Common.Extensions.ServiceCollectionExtensions.AddSdxCoreCommon"/>
///   via <c>ValidatorOptions.Global.LanguageManager = new ValidationLanguageManager()</c>.
///   No per-service configuration needed.
/// </summary>
public sealed class ValidationLanguageManager : LanguageManager
{
    public ValidationLanguageManager()
    {
        AddTranslation("en", "NotEmptyValidator",
            "{PropertyName} is required.");

        AddTranslation("en", "NotNullValidator",
            "{PropertyName} is required.");

        AddTranslation("en", "MaximumLengthValidator",
            "{PropertyName} cannot exceed {MaxLength} characters.");

        AddTranslation("en", "MinimumLengthValidator",
            "{PropertyName} must be at least {MinLength} characters.");

        AddTranslation("en", "LengthValidator",
            "{PropertyName} must be between {MinLength} and {MaxLength} characters.");

        AddTranslation("en", "EmailValidator",
            "{PropertyName} is not a valid email address.");

        AddTranslation("en", "GreaterThanValidator",
            "{PropertyName} must be greater than {ComparisonValue}.");

        AddTranslation("en", "GreaterThanOrEqualValidator",
            "{PropertyName} must be greater than or equal to {ComparisonValue}.");

        AddTranslation("en", "LessThanValidator",
            "{PropertyName} must be less than {ComparisonValue}.");

        AddTranslation("en", "LessThanOrEqualValidator",
            "{PropertyName} must be less than or equal to {ComparisonValue}.");

        AddTranslation("en", "InclusiveBetweenValidator",
            "{PropertyName} must be between {From} and {To}.");

        AddTranslation("en", "ExclusiveBetweenValidator",
            "{PropertyName} must be between {From} and {To}.");

        AddTranslation("en", "RegularExpressionValidator",
            "{PropertyName} format is invalid.");
    }
}
