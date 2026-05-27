using Microsoft.Extensions.DependencyInjection;
using SdxCore.Notification.Application.Providers;
using SdxCore.Notification.Application.Services;

namespace SdxCore.Notification.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddNotificationServicesApplication(this IServiceCollection services)
    {
        services.AddScoped<IEmailProvider, DummyEmailProvider>();
        services.AddScoped<ISmsProvider, DummySmsProvider>();
        services.AddScoped<INotificationService, NotificationService>();
        return services;
    }
}
