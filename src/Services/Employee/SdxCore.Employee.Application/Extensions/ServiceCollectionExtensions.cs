using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Employee.Application.Interfaces.Services;
using SdxCore.Employee.Application.Services;
using SdxCore.Employee.Application.Validators;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddEmployeeApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IEmployeeService, EmployeeService>();
        services.AddScoped<ISkillService, SkillService>();
        services.AddScoped<ITeamService, TeamService>();
        services.AddScoped<IEmployeeSkillService, EmployeeSkillService>();
        services.AddScoped<IEmployeeTeamService, EmployeeTeamService>();
        services.AddScoped<IBiometricMappingService, BiometricMappingService>();

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
        services.AddScoped<IValidator<AddEmployeeSkillRequest>, AddEmployeeSkillRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeSkillRequest>, UpdateEmployeeSkillRequestValidator>();
        
        services.AddScoped<IValidator<CreateTeamRequest>, CreateTeamRequestValidator>();
        services.AddScoped<IValidator<UpdateTeamRequest>, UpdateTeamRequestValidator>();
        services.AddScoped<IValidator<AddEmployeeTeamRequest>, AddEmployeeTeamRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeTeamRequest>, UpdateEmployeeTeamRequestValidator>();
        
        services.AddScoped<IValidator<AddBiometricMappingRequest>, AddBiometricMappingRequestValidator>();
        services.AddScoped<IValidator<UpdateBiometricMappingRequest>, UpdateBiometricMappingRequestValidator>();

        // Phase 3 Validators
        services.AddScoped<IValidator<AddEmployeeLegalEntityRequest>, AddEmployeeLegalEntityRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeLegalEntityRequest>, UpdateEmployeeLegalEntityRequestValidator>();
        
        services.AddScoped<IValidator<AddEmployeeDepartmentRequest>, AddEmployeeDepartmentRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeDepartmentRequest>, UpdateEmployeeDepartmentRequestValidator>();
        
        services.AddScoped<IValidator<AddEmployeeLocationRequest>, AddEmployeeLocationRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeLocationRequest>, UpdateEmployeeLocationRequestValidator>();
        
        services.AddScoped<IValidator<AddEmployeeRelationshipRequest>, AddEmployeeRelationshipRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeRelationshipRequest>, UpdateEmployeeRelationshipRequestValidator>();
        
        services.AddScoped<IValidator<AddEmployeeContactRequest>, AddEmployeeContactRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeContactRequest>, UpdateEmployeeContactRequestValidator>();
        
        services.AddScoped<IValidator<AddEmployeeDocumentRequest>, AddEmployeeDocumentRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeDocumentRequest>, UpdateEmployeeDocumentRequestValidator>();
        
        services.AddScoped<IValidator<AddEmployeeAddressRequest>, AddEmployeeAddressRequestValidator>();
        services.AddScoped<IValidator<UpdateEmployeeAddressRequest>, UpdateEmployeeAddressRequestValidator>();

        return services;
    }
}
