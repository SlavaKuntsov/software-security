using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Persistence.Repositories;

namespace SoftwareSecurity.Persistence.Extensions;

public static class PersistenceExtensions
{
	public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration configuration)
	{
		var connectionString = Environment.GetEnvironmentVariable("CONNECTION_STRING");

		if (string.IsNullOrEmpty(connectionString))
			connectionString = configuration.GetConnectionString("SoftwareSecurityDbContext");

		services.AddDbContextPool<IApplicationDbContext, SoftwareSecurityDBContext>(options =>
		{
			options.UseNpgsql(connectionString);
		}, poolSize: 128);

		services.AddScoped<IUsersRepository, UsersRepository>();
		services.AddScoped<ITokensRepository, TokensRepository>();

		return services;
	}
}