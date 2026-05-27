using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace SdxCore.Employee.Persistence.Data.Configurations;

public class EmployeeConfiguration : IEntityTypeConfiguration<Domain.Entities.Employee>
{
    public void Configure(EntityTypeBuilder<Domain.Entities.Employee> builder)
    {
        builder.ToTable("Employee");
        builder.HasKey(e => e.Id);
        
        builder.Property(e => e.EmployeeCode).IsRequired().HasMaxLength(50);
        builder.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
        builder.Property(e => e.LastName).HasMaxLength(100);
        builder.Property(e => e.DisplayName).HasMaxLength(200);
        builder.Property(e => e.Email).IsRequired().HasMaxLength(255);
        builder.Property(e => e.MobileNumber).HasMaxLength(30);
        builder.Property(e => e.PreferredLanguage).HasMaxLength(20);
        builder.Property(e => e.EmploymentType).IsRequired().HasMaxLength(50).HasDefaultValue("FULL_TIME");
        builder.Property(e => e.AboutMe);
        builder.Property(e => e.ProfilePhotoUrl).HasMaxLength(1000);
        
        builder.HasIndex(e => e.EmployeeCode).IsUnique();
        builder.HasIndex(e => e.Email).IsUnique();
    }
}
