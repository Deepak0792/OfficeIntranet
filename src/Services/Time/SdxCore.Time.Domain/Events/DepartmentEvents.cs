namespace SdxCore.Time.Domain.Events;

public class DepartmentCreatedEvent
{
    public short DepartmentId { get; set; }
    public string DepartmentCode { get; set; } = string.Empty;
}

public class DepartmentUpdatedEvent
{
    public short DepartmentId { get; set; }
}

public class DepartmentDeletedEvent
{
    public short DepartmentId { get; set; }
}
