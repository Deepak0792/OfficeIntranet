using Microsoft.EntityFrameworkCore;
using SdxCore.Time.Persistence.Data;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Repositories;
using SdxCore.Time.Application.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=localhost;Database=SdxCore;Trusted_Connection=True;TrustServerCertificate=True;";

builder.Services.AddDbContext<TimeDbContext>(options =>
    options.UseSqlServer(connectionString));

// Register Repositories and Services
builder.Services.AddScoped<IBiometricDeviceRepository, BiometricDeviceRepository>();
builder.Services.AddScoped<IBiometricDeviceService, BiometricDeviceService>();
builder.Services.AddScoped<IGeoFenceRepository, GeoFenceRepository>();
builder.Services.AddScoped<IGeoFenceService, GeoFenceService>();
builder.Services.AddScoped<IDocumentTypeRepository, DocumentTypeRepository>();
builder.Services.AddScoped<IDocumentTypeService, DocumentTypeService>();
builder.Services.AddScoped<IDesignationRepository, DesignationRepository>();
builder.Services.AddScoped<IDesignationService, DesignationService>();
builder.Services.AddScoped<IScopeTypeRepository, ScopeTypeRepository>();
builder.Services.AddScoped<IScopeTypeService, ScopeTypeService>();
builder.Services.AddScoped<IOfficeLocationRepository, OfficeLocationRepository>();
builder.Services.AddScoped<IOfficeLocationService, OfficeLocationService>();
builder.Services.AddScoped<ILegalEntityRepository, LegalEntityRepository>();
builder.Services.AddScoped<ILegalEntityService, LegalEntityService>();
builder.Services.AddScoped<IRegionRepository, RegionRepository>();
builder.Services.AddScoped<IRegionService, RegionService>();
builder.Services.AddScoped<ICountryRepository, CountryRepository>();
builder.Services.AddScoped<ICountryService, CountryService>();
builder.Services.AddScoped<ITimeZoneMasterRepository, TimeZoneMasterRepository>();
builder.Services.AddScoped<ITimeZoneMasterService, TimeZoneMasterService>();
builder.Services.AddScoped<IDepartmentRepository, DepartmentRepository>();
builder.Services.AddScoped<IDepartmentService, DepartmentService>();

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










