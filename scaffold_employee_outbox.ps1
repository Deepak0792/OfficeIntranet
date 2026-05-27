$persistenceDir = "d:\Office\SdxCore\src\Services\Employee\SdxCore.Employee.Persistence"
$apiDir = "d:\Office\SdxCore\src\Services\Employee\SdxCore.Employee.API"

$dbContextCode = @"
using Microsoft.EntityFrameworkCore;
using SdxCore.Common.Outbox;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Persistence.Data;

public class EmployeeDbContext : DbContext
{
    public EmployeeDbContext(DbContextOptions<EmployeeDbContext> options) : base(options) { }

    public DbSet<Domain.Entities.Employee> Employees => Set<Domain.Entities.Employee>();
    public DbSet<EmployeeDocument> EmployeeDocuments => Set<EmployeeDocument>();
    public DbSet<EmployeeAddress> EmployeeAddresses => Set<EmployeeAddress>();
    public DbSet<Skill> Skills => Set<Skill>();
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.HasDefaultSchema("employee");
    }
}
"@
Set-Content -Path "$persistenceDir\Data\EmployeeDbContext.cs" -Value $dbContextCode

$extDir = "$persistenceDir\Extensions"
New-Item -ItemType Directory -Force -Path $extDir | Out-Null
$extCode = @"
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Common.Outbox;
using SdxCore.Employee.Persistence.Data;
using System.Text.Json;

namespace SdxCore.Employee.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddEmployeePersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<OutboxSaveChangesInterceptor>();
        
        services.AddDbContext<EmployeeDbContext>((sp, options) =>
        {
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection"));
            options.AddInterceptors(sp.GetRequiredService<OutboxSaveChangesInterceptor>());
        });
        
        services.AddScoped<IOutboxRepository>(sp => 
        {
            var dbContext = sp.GetRequiredService<EmployeeDbContext>();
            return new OutboxRepository(dbContext, JsonSerializerOptions.Default);
        });

        return services;
    }
}
"@
Set-Content -Path "$extDir\ServiceCollectionExtensions.cs" -Value $extCode

$appExtDir = "d:\Office\SdxCore\src\Services\Employee\SdxCore.Employee.Application\Extensions"
New-Item -ItemType Directory -Force -Path $appExtDir | Out-Null
$appExtCode = @"
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Employee.Application.Services;

namespace SdxCore.Employee.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddEmployeeServicesApplication(this IServiceCollection services)
    {
        services.AddScoped<EmployeeProfileService>();
        return services;
    }
}
"@
Set-Content -Path "$appExtDir\ServiceCollectionExtensions.cs" -Value $appExtCode

$programCode = @"
using SdxCore.Common.Extensions;
using SdxCore.Employee.Application.Extensions;
using SdxCore.Employee.Persistence.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Common Layer
builder.Services.AddSdxCoreCommon(builder.Configuration);

// Outbox & Quartz
builder.Services.AddSingleton<SdxCore.Common.Outbox.IEventPublisher, SdxCore.Common.Outbox.RabbitMqEventPublisher>();
builder.Services.AddHostedService<SdxCore.Common.Outbox.OutboxProcessorJob>();
builder.Services.AddSdxCoreQuartz(builder.Configuration);

// Persistence & Application
builder.Services.AddEmployeePersistence(builder.Configuration);
builder.Services.AddEmployeeServicesApplication();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
"@
Set-Content -Path "$apiDir\Program.cs" -Value $programCode

Write-Output "Generated Employee Outbox and API wiring."
