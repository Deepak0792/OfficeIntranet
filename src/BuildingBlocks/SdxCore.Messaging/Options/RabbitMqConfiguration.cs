namespace SdxCore.Messaging.Options;

public class RabbitMqConfiguration
{
    public string Host { get; set; } = "localhost";
    public int Port { get; set; } = 5672;
    public string VirtualHost { get; set; } = "sdxcore";
    public string Username { get; set; } = "sdxcore";
    public string Password { get; set; } = "sdxcore_secret";
    public string ExchangeName { get; set; } = "sdxcore.events";
    public string DeadLetterExchange { get; set; } = "sdxcore.events.dlx";
}
