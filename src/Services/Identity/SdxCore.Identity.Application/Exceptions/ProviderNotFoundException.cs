namespace SdxCore.Identity.Application.Exceptions;

/// <summary>
/// Exception thrown when a configured authentication provider is not registered.
/// </summary>
public sealed class ProviderNotFoundException : Exception
{
    public ProviderNotFoundException()
    {
    }

    public ProviderNotFoundException(string message) : base(message)
    {
    }

    public ProviderNotFoundException(string message, Exception innerException) : base(message, innerException)
    {
    }
}
