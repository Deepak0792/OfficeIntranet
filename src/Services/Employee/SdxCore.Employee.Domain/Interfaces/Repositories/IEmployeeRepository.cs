using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Domain.Interfaces.Repositories;

public interface IEmployeeRepository : IBaseRepository<Employee> { }
public interface IEmployeeLegalEntityRepository : IBaseRepository<EmployeeLegalEntity> { }
public interface IEmployeeDepartmentRepository : IBaseRepository<EmployeeDepartment> { }
