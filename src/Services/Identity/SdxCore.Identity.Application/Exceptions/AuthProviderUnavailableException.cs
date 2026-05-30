namespace SdxCore.Identity.Application.Exceptions;

/// <summary>
/// Exception thrown when an external identity provider is unreachable or unavailable.
/// </summary>
public sealed class AuthProviderUnavailableException : Exception
{
    public AuthProviderUnavailableException()
    {
    }

    public AuthProviderUnavailableException(string message) : base(message)
    {
    }

    public AuthProviderUnavailableException(string message, Exception innerException) : base(message, innerException)
    {
    }
}
