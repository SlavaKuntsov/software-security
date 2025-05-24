using Microsoft.Extensions.DependencyInjection;

using SoftwareSecurity.Application.Handlers.Commands.Auth.Registration;
using SoftwareSecurity.Application.Services;
using SoftwareSecurity.Domain.Interfaces;

namespace SoftwareSecurity.Application.Extensions;

public static class ApplicationExtensions
{
	public static IServiceCollection AddApplication(this IServiceCollection services)
	{
		services.AddMediatR(cfg =>
		{
			cfg.RegisterServicesFromAssemblyContaining<UserRegistrationCommandHandler>();
		});

		services.AddScoped<IChatService, ChatService>();

		return services;
	}
}