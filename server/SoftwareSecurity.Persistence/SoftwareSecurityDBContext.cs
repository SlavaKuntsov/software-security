using System.Reflection;

using Microsoft.EntityFrameworkCore;

using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Persistence;

public class SoftwareSecurityDBContext : DbContext, IApplicationDbContext
{
	public DbSet<UserModel> Users { get; set; }
	public DbSet<RefreshTokenModel> RefreshTokens { get; set; }

	public SoftwareSecurityDBContext(DbContextOptions<SoftwareSecurityDBContext> options) : base(options)
	{
		Database.EnsureCreated();
	}

	protected override void OnModelCreating(ModelBuilder modelBuilder)
	{
		modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

		base.OnModelCreating(modelBuilder);
	}
}