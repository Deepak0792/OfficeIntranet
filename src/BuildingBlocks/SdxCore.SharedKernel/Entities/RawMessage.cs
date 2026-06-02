namespace SdxCore.SharedKernel.Entities;

public sealed class RawMessage
{
    public string MessageType { get; init; } = string.Empty;
    public string Payload { get; init; } = string.Empty;
}
