using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Persistence.Configurations;

public partial class UserConfiguration : IEntityTypeConfiguration<UserModel>
{
	public void Configure(EntityTypeBuilder<UserModel> builder)
	{
		builder.ToTable("Users");

		builder.HasKey(u => u.Id);

		builder.Property(u => u.Email)
			.IsRequired()
			.HasMaxLength(256);

		builder.Property(u => u.Password)
			.IsRequired();

		builder.Property(u => u.Role)
			.HasConversion(
				role => role.ToString(),
				value => Enum.Parse<Role>(value)
			);

		builder.Property(d => d.FirstName)
			.IsRequired()
			.HasMaxLength(100);

		builder.Property(d => d.LastName)
			.IsRequired()
			.HasMaxLength(100);

		builder.Property(d => d.DateOfBirth)
			.IsRequired();

		builder.HasOne(u => u.RefreshToken)
			.WithOne(r => r.User)
			.HasForeignKey<RefreshTokenModel>(r => r.UserId);

		builder.Property(r => r.Id)
			.HasConversion(
				v => v.ToString(),
				v => Ulid.Parse(v)
			);

		builder.HasData(
			new UserModel
			{
				Id = Ulid.NewUlid(),
				Email = "admin@email.com",
				Password = BCrypt.Net.BCrypt.EnhancedHashPassword("qweQWE123"),
				Role = Role.Admin,
				FirstName = "admin",
				LastName = "admin"

			});
	}
}