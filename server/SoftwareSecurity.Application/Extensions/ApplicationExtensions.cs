using Microsoft.Extensions.DependencyInjection;

using SoftwareSecurity.Application.Handlers.Commands.Auth.Registration;

namespace SoftwareSecurity.Application.Extensions;

public static class ApplicationExtensions
{
	public static IServiceCollection AddApplication(this IServiceCollection services)
	{
		services.AddMediatR(cfg =>
		{
			cfg.RegisterServicesFromAssemblyContaining<UserRegistrationCommandHandler>();
		});

		return services;
	}
}