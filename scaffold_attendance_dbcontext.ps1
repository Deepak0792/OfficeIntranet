$dataDir = "d:\Office\SdxCore\src\Services\Attendance\SdxCore.Attendance.Persistence\Data"
$configDir = "$dataDir\Configurations"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

$dbContextCode = @"
using Microsoft.EntityFrameworkCore;
using SdxCore.Common.Outbox;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Persistence.Data;

public class AttendanceDbContext : DbContext
{
    public AttendanceDbContext(DbContextOptions<AttendanceDbContext> options) : base(options) { }

    public DbSet<Shift> Shifts => Set<Shift>();
    public DbSet<WorkSession> WorkSessions => Set<WorkSession>();
    public DbSet<AttendanceRecord> AttendanceRecords => Set<AttendanceRecord>();
    public DbSet<LeaveType> LeaveTypes => Set<LeaveType>();
    public DbSet<LeaveRequest> LeaveRequests => Set<LeaveRequest>();
    public DbSet<LeaveBalance> LeaveBalances => Set<LeaveBalance>();
    public DbSet<EmployeeShiftRoster> EmployeeShiftRosters => Set<EmployeeShiftRoster>();
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.HasDefaultSchema("attendance");
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AttendanceDbContext).Assembly);
    }
}
"@
Set-Content -Path "$dataDir\AttendanceDbContext.cs" -Value $dbContextCode

$attendanceConfig = @"
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace SdxCore.Attendance.Persistence.Data.Configurations;

public class AttendanceRecordConfiguration : IEntityTypeConfiguration<Domain.Entities.AttendanceRecord>
{
    public void Configure(EntityTypeBuilder<Domain.Entities.AttendanceRecord> builder)
    {
        builder.ToTable("AttendanceRecord");
        builder.HasKey(e => e.Id);
        
        builder.HasIndex(e => new { e.EmployeeId, e.AttendanceDate }).IsUnique();
        builder.HasIndex(e => e.AttendanceDate);
        
        builder.Property(e => e.AttendanceStatus).HasMaxLength(50);
        builder.Property(e => e.Remarks).HasMaxLength(1000);
    }
}
"@
Set-Content -Path "$configDir\AttendanceRecordConfiguration.cs" -Value $attendanceConfig

Write-Output "Successfully generated Attendance DbContext and Configurations."
