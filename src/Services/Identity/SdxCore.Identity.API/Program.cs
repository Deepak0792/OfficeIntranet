using Microsoft.EntityFrameworkCore;
using SdxCore.Identity.API.Middleware;
using SdxCore.Identity.Application.Extensions;
using SdxCore.Identity.Persistence.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Add controllers
builder.Services.AddControllers();

// HttpContext Access (Required for RequestContext)
builder.Services.AddHttpContextAccessor();
// Add health checks
builder.Services.AddHealthChecks();

// Add OpenAPI/Swagger for development
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register the common layer
builder.Services.AddSdxCoreCommon(builder.Configuration);

// Register the persistence layer (EF Core + SQL Server)
// Connection string comes from appsettings.json
builder.Services.AddSdxCorePersistence(builder.Configuration);

// Register the authentication module via DI extension
// All configuration values come from appsettings.json
builder.Services.AddSdxCoreAuthentication(builder.Configuration);

// Register providers based on what you need
// IMPORTANT: You must register the provider that matches your appsettings.json "Authentication:Protocol" value
var protocol = builder.Configuration["Authentication:Protocol"];

if (string.IsNullOrWhiteSpace(protocol))
{
    throw new InvalidOperationException(
        "Authentication protocol is not configured. Please set 'Authentication:Protocol' in appsettings.json to one of: InHouse, Saml, OAuth, Oidc, Jwt, Ldap");
}

switch (protocol.ToLowerInvariant())
{
    case "inhouse":
        builder.Services.AddInHouseProvider();
        break;
    case "saml":
        builder.Services.AddSamlProvider();
        break;
    case "oauth":
        builder.Services.AddOAuthProvider();
        break;
    case "oidc":
        builder.Services.AddOidcProvider();
        break;
    case "jwt":
        builder.Services.AddJwtProvider();
        break;
    case "ldap":
        // LDAP provider is temporarily disabled due to API compatibility issues
        throw new InvalidOperationException(
            "LDAP provider is temporarily disabled. Please use one of: InHouse, Saml, OAuth, Oidc, Jwt");
    default:
        throw new InvalidOperationException(
            $"Invalid authentication protocol: '{protocol}'. Valid values are: InHouse, Saml, OAuth, Oidc, Jwt, Ldap");
}

var app = builder.Build();

// Apply database migrations automatically on startup
//using (var scope = app.Services.CreateScope())
//{
//    var context = scope.ServiceProvider.GetRequiredService<SdxCore.Identity.Persistence.Data.IdentityDbContext>();
//    context.Database.Migrate();
//}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Register TokenValidationMiddleware
app.UseTokenValidation();

app.UseAuthorization();

// Map health check endpoint
app.MapHealthChecks("/health");

app.MapControllers();

app.Run();

// Make Program class accessible for integration tests
public partial class Program { }
