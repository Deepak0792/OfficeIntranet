namespace SdxCore.Attendance.Application.Exceptions;

public static class ResolverException
{
    public static InvalidOperationException NotFound(
        string entityName,
        object id)
    {
        return new InvalidOperationException(
            $"{entityName} '{id}' not found.");
    }

    public static InvalidOperationException Inactive(
        string entityName,
        object id)
    {
        return new InvalidOperationException(
            $"{entityName} '{id}' is inactive.");
    }
}