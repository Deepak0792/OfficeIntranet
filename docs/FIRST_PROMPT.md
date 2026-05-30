
```
Before making any modifications, thoroughly analyze the existing project structure, codebase, and service interactions to develop a clear understanding of the application's architecture and implementation patterns.

Strictly adhere to the current architecture and microservices design. Maintain full consistency with the project's established naming conventions, folder structure, coding standards, design patterns, dependency organization, and implementation practices.

Use the existing codebase as the primary reference for all future changes. Preserve architectural integrity and align new implementations with existing patterns to ensure seamless integration and maintainability.

Continuously retain and apply knowledge gained from the codebase analysis throughout future implementations, treating existing project conventions and architectural decisions as the default source of truth unless explicitly instructed otherwise.
```



```
Generate implementation plan for all endpoints defined in `EMPLOYEE_API_ENDPOINTS.md` using the corresponding database schema from `04-employee.sql`, ensuring each endpoint correctly aligns with the underlying schema, business rules, and functional requirements.

All implementation plans must strictly follow the architecture, project structure, coding standards, naming conventions, design patterns, validation strategy, error-handling approach, logging conventions, and overall implementation patterns established in the Time Microservices project.

Handle all below status codes:

* [ProducesResponseType(typeof(ApiResponse<IEnumerable<DepartmentResponse>>), StatusCodes.Status200OK)]
* [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
* [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]

Maintain consistency across all application layers, including:

* Controllers
* Services
* Repositories
* Entities
* DTOs
* Request/Response Models
* Object Mappings
* Configuration Management
* Background Processing Components (Event for RabbitMQ)

Define all classes in their respective folders and projects by taking Time microservice as reference.

Where applicable, implement caching using the same conventions and patterns used in Time Microservices, including:

* Cache abstractions
* Cache key naming conventions
* Expiration policies
* Cache invalidation mechanisms

This ensures consistency, maintainability, and performance across services.

All database schemas are available under:

* `src/Database/Base/Schema`

Additionally, generate a comprehensive implementation plan detailing all required components and endpoint implementations.


Phase 1: 
The first task must be:
* Task 1 – Base Route: `/api/v1/employees` (this base route contains 11 endpoints)

Generate all code required to implement every endpoint under `/api/v1/employees` as defined in `EMPLOYEE_API_ENDPOINTS.md`, following all existing project conventions and architectural patterns.

Phase 2: include all other base route and their endpoint in defined `EMPLOYEE_API_ENDPOINTS.md`

Also include plan for updating:

* Docker configuration
* Gateway appsettings
* Employee Microservice appsettings
```