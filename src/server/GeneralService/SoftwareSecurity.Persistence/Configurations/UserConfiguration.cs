using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Models;
using SoftwareSecurity.Persistence.Converters;

namespace SoftwareSecurity.Persistence.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<UserModel>
{
	public void Configure(EntityTypeBuilder<UserModel> builder)
	{
		builder.ToTable("Users");

		builder.HasKey(u => u.Id);

		builder.Property(u => u.Id)
			.HasConversion(new UlidToStringConverter())
			.IsRequired();

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

		builder.Property(u => u.AuthType)
			.HasConversion(
				type => type.ToString(),
				value => Enum.Parse<AuthType>(value)
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
		
		builder.HasMany(u => u.SentMessages)
			.WithOne(c => c.Sender)
			.HasForeignKey(c => c.SenderId)
			.OnDelete(DeleteBehavior.Restrict);
		
		builder.HasMany(u => u.ReceivedMessages)
			.WithOne(c => c.Receiver)
			.HasForeignKey(c => c.ReceiverId)
			.OnDelete(DeleteBehavior.Restrict);

		builder.Property(r => r.Id)
			.HasConversion(new UlidToStringConverter());

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