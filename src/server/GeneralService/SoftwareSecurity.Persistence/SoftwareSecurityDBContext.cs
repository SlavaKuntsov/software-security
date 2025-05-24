using System.Reflection;
using Microsoft.EntityFrameworkCore;
using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Domain.Models;
using SoftwareSecurity.Persistence.Converters;

namespace SoftwareSecurity.Persistence;

public class SoftwareSecurityDBContext : DbContext, IApplicationDbContext
{
	public DbSet<UserModel> Users { get; set; } = null!;
	public DbSet<RefreshTokenModel> RefreshTokens { get; set; } = null!;

	public SoftwareSecurityDBContext(DbContextOptions<SoftwareSecurityDBContext> options) : base(options)
	{
		Database.EnsureCreated();
	}
	public DbSet<ChatMessageModel> ChatMessages { get; set; } = null!;

	protected override void OnModelCreating(ModelBuilder modelBuilder)
	{
		try
		{
			// Apply all entity configurations
			modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

			// Configure properties for the Ulid type
			var converter = new UlidToStringConverter();

			var properties = modelBuilder.Model.GetEntityTypes()
				.SelectMany(t => t.GetProperties())
				.Where(p => p.ClrType == typeof(Ulid));

			foreach (var property in properties)
				property.SetValueConverter(converter);
		}
		catch (Exception ex)
		{
			Console.WriteLine($"Error in OnModelCreating: {ex.Message}");
			// Still call base even if our configuration failed
		}

		base.OnModelCreating(modelBuilder);
	}

	protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
	{
		try
		{
			// Configure global converters
			configurationBuilder
				.Properties<Ulid>()
				.HaveConversion<UlidToStringConverter>();
		}
		catch (Exception ex)
		{
			Console.WriteLine($"Error in ConfigureConventions: {ex.Message}");
		}

		base.ConfigureConventions(configurationBuilder);
	}
}