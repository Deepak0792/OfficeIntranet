using SdxCore.Attendance.API.Middleware;
using SdxCore.Attendance.Application.Extensions;
using SdxCore.Attendance.Persistence.Extensions;
using SdxCore.Caching.Extensions;
using SdxCore.Common.Extensions;
using SdxCore.SharedKernel.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHttpContextAccessor();
builder.Services.AddHealthChecks();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Common infrastructure
builder.Services.AddSdxCoreCommon(builder.Configuration);
builder.Services.AddSdxCoreSharedKernel(builder.Configuration);
builder.Services.AddSdxCoreCaching(builder.Configuration);

// Attendance layers
builder.Services.AddSdxCoreAttendancePersistence(builder.Configuration);
builder.Services.AddSdxCoreAttendanceApplication();
builder.Services.AddSdxCoreAttendanceMessaging(builder.Configuration);
builder.Services.AddSdxCoreAttendanceHttpClients(builder.Configuration);

var app = builder.Build();

app.UseMiddleware<AttendanceExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapHealthChecks("/health");
app.MapControllers();

app.Run();

public partial class Program { }
