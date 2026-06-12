using SdxCore.Common.Extensions;
using SdxCore.File.Application.Extensions;
using SdxCore.FileStorage.Extensions;
using SdxCore.SharedKernel.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHttpContextAccessor();
builder.Services.AddHealthChecks();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register common layer
builder.Services.AddSdxCoreCommon(builder.Configuration);

// Register SharedKernel layer
builder.Services.AddSdxCoreSharedKernel(builder.Configuration);

// Register storage infrastructure (IFileStorageService implementation)
builder.Services.AddSdxCoreFileStorage(builder.Configuration);

// Register File Application layer (IFileService + validators)
builder.Services.AddSdxCoreFileApplication();

var app = builder.Build();

app.UseGlobalExceptionHandling();

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
