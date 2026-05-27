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
