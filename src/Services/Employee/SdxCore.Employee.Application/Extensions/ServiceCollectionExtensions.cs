using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.Services;
using SdxCore.Employee.Application.Validators;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.BackgroundServices;

namespace SdxCore.Employee.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreEmployeeApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IEmployeeService, EmployeeService>();
        services.AddScoped<ISkillService, SkillService>();
        services.AddScoped<ITeamService, TeamService>();
        services.AddScoped<IEmployeeSkillService, EmployeeSkillService>();
        services.AddScoped<IEmployeeTeamService, EmployeeTeamService>();
        services.AddScoped<IEmployeeBiometricMappingService, EmployeeBiometricMappingService>();

        // Phase 3 Services
        services.AddScoped<IEmployeeLegalEntityService, EmployeeLegalEntityService>();
        services.AddScoped<IEmployeeDepartmentService, EmployeeDepartmentService>();
        services.AddScoped<IEmployeeLocationService, EmployeeLocationService>();
        services.AddScoped<IEmployeeRelationshipService, EmployeeRelationshipService>();
        services.AddScoped<IEmployeeContactService, EmployeeContactService>();
        services.AddScoped<IEmployeeDocumentService, EmployeeDocumentService>();
        services.AddScoped<IEmployeeAddressService, EmployeeAddressService>();

        // Register Validators Explicitly
        services.AddScoped<IValidator<CreateEmployeeRequest>, CreateEmployeeRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeRequest>, UpdateEmployeeRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeStatusRequest>, UpdateEmployeeStatusRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeePhotoRequest>, UpdateEmployeePhotoRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeAboutRequest>, UpdateEmployeeAboutRequestValidator>();

        // Phase 2 Validators
        services.AddScoped<IValidator<CreateSkillRequest>, CreateSkillRequestValidator>();
        services.AddScoped<IValidator<UpdateSkillRequest>, UpdateSkillRequestValidator>();
        services.AddScoped<IValidator<CreateEmployeeSkillRequest>, CreateEmployeeSkillRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeSkillRequest>, UpdateEmployeeSkillRequestValidator>();
        
        services.AddScoped<IValidator<CreateTeamRequest>, CreateTeamRequestValidator>();
        services.AddScoped<IValidator<UpdateTeamRequest>, UpdateTeamRequestValidator>();
        services.AddScoped<IValidator<CreateEmployeeTeamRequest>, CreateEmployeeTeamRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeTeamRequest>, UpdateEmployeeTeamRequestValidator>();
        
        services.AddScoped<IValidator<CreateEmployeeBiometricMappingRequest>, CreateEmployeeBiometricMappingRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeBiometricMappingRequest>, UpdateEmployeeBiometricMappingRequestValidator>();

        // Phase 3 Validators
        services.AddScoped<IValidator<CreateEmployeeLegalEntityRequest>, CreateEmployeeLegalEntityRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeLegalEntityRequest>, UpdateEmployeeLegalEntityRequestValidator>();
        
        services.AddScoped<IValidator<CreateEmployeeDepartmentRequest>, CreateEmployeeDepartmentRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeDepartmentRequest>, UpdateEmployeeDepartmentRequestValidator>();
        
        services.AddScoped<IValidator<CreateEmployeeLocationRequest>, CreateEmployeeLocationRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeLocationRequest>, UpdateEmployeeLocationRequestValidator>();
        
        services.AddScoped<IValidator<CreateEmployeeRelationshipRequest>, CreateEmployeeRelationshipRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeRelationshipRequest>, UpdateEmployeeRelationshipRequestValidator>();
        
        services.AddScoped<IValidator<CreateEmployeeContactRequest>, CreateEmployeeContactRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeContactRequest>, UpdateEmployeeContactRequestValidator>();
        
        services.AddScoped<IValidator<CreateEmployeeDocumentRequest>, CreateEmployeeDocumentRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeDocumentRequest>, UpdateEmployeeDocumentRequestValidator>();
        
        services.AddScoped<IValidator<CreateEmployeeAddressRequest>, CreateEmployeeAddressRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeAddressRequest>, UpdateEmployeeAddressRequestValidator>();

        // Register Background Services
        services.AddHostedService<OutboxProcessorBackgroundService>();
        //builder.Services.AddHostedService<CacheInvalidationBackgroundService>();
        return services;
    }
}
