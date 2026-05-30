namespace SdxCore.Identity.Application.Exceptions;

/// <summary>
/// Exception thrown when authentication configuration is missing or invalid.
/// </summary>
public sealed class ConfigurationException : Exception
{
    public ConfigurationException()
    {
    }

    public ConfigurationException(string message) : base(message)
    {
    }

    public ConfigurationException(string message, Exception innerException) : base(message, innerException)
    {
    }
}
