# SdxCore.Identity.Tests

This test project contains unit tests, property-based tests, and integration tests for the Identity authentication module.

## Test Structure

- **UnitTests/**: Unit tests for individual components (using xUnit and Moq)
- **PropertyTests/**: Property-based tests for universal correctness properties (using FsCheck.Xunit)
- **IntegrationTests/**: End-to-end integration tests (using Testcontainers.MsSql)

## Test Frameworks and Libraries

- **xUnit**: Test framework
- **FsCheck.Xunit**: Property-based testing
- **Moq**: Mocking framework
- **FluentAssertions**: Fluent assertion library
- **Testcontainers.MsSql**: SQL Server container for integration tests

## Running Tests

```bash
# Run all tests
dotnet test

# Run specific test category
dotnet test --filter "Category=Unit"
dotnet test --filter "Category=Property"
dotnet test --filter "Category=Integration"
```

## Project References

This test project references all Identity projects:
- SdxCore.Identity.API
- SdxCore.Identity.Application
- SdxCore.Identity.Domain
- SdxCore.Identity.Persistence
