using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Infrastructure.Auth;

namespace SoftwareSecurity.Infrastructure.Extensions;

public static class InfrastructureExtensions
{
	public static IServiceCollection AddInfrastructure(this IServiceCollection services)
	{
		services.AddScoped<IPasswordHash, PasswordHash>();
		services.AddScoped<ICookieService, CookieService>();
		services.AddScoped<IJwt, Jwt>();

		return services;
	}
}