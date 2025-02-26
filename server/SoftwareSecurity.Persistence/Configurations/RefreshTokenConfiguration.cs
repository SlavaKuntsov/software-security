﻿using System.Reflection.Emit;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Persistence.Configurations;

public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshTokenModel>
{
	public void Configure(EntityTypeBuilder<RefreshTokenModel> builder)
	{
		builder.ToTable("RefreshTokens");

		builder.HasKey(r => r.Id);

		builder.Property(r => r.Token)
			.IsRequired()
			.HasMaxLength(500);

		builder.Property(r => r.ExpiresAt)
			.IsRequired();

		builder.Property(r => r.CreatedAt)
			.IsRequired();

		builder.Property(r => r.IsRevoked)
		.IsRequired();

		builder.HasOne(r => r.User)
			.WithOne(u => u.RefreshToken)
			.HasForeignKey<RefreshTokenModel>(r => r.UserId);

		builder.Property(r => r.Id)
			.HasConversion(
				v => v.ToString(),
				v => Ulid.Parse(v)
			);
	}
}