namespace SdxCore.Notification.Domain.Entities;

public class NotificationTemplate : BaseEntity
{
    public int Id { get; set; }
    public string EventName { get; set; } = string.Empty;
    public string Channel { get; set; } = "EMAIL"; // EMAIL, SMS, IN_APP
    public string SubjectTemplate { get; set; } = string.Empty;
    public string BodyTemplate { get; set; } = string.Empty;
}
