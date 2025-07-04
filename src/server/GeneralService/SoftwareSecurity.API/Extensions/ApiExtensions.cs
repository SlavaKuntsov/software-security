﻿using System.Reflection;
using System.Text;
using Asp.Versioning;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using SoftwareSecurity.API.Middlewares;
using SoftwareSecurity.Application.Services;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Extensions;
using SoftwareSecurity.Domain.Interfaces;
using SoftwareSecurity.Infrastructure.Auth;
using SoftwareSecurity.Persistence.Repositories;
using Swashbuckle.AspNetCore.Filters;
using UserService.API.Contracts.Examples;

namespace SoftwareSecurity.API.Extensions;

public static class ApiExtensions
{
	public static IServiceCollection AddAPI(this IServiceCollection services)
	{
		services.AddHttpContextAccessor();

		services.AddExceptionHandler<GlobalExceptionHandler>();
		services.AddProblemDetails();

		services.AddControllers();
		services.AddEndpointsApiExplorer();

		// Configure SignalR
		services.AddSignalR();

		services.AddSwaggerGen(
			options =>
			{
				options.SwaggerDoc("v1", new OpenApiInfo { Title = "Mobile API v1", Version = "v1" });
				options.SwaggerDoc("v2", new OpenApiInfo { Title = "Web API v2", Version = "v2" });

				options.ExampleFilters();

				options.AddSecurityDefinition(
					"Bearer",
					new OpenApiSecurityScheme
					{
						Name = "Authorization",
						In = ParameterLocation.Header,
						Type = SecuritySchemeType.Http,
						Scheme = "Bearer",
						BearerFormat = "JWT",
						Description = "Введите токен JWT в формате 'Bearer {токен}'"
					});

				options.AddSecurityRequirement(
					new OpenApiSecurityRequirement
					{
						{
							new OpenApiSecurityScheme
							{
								Reference = new OpenApiReference
								{
									Type = ReferenceType.SecurityScheme,
									Id = "Bearer"
								}
							},
							Array.Empty<string>()
						}
					});
			});
		services.AddSwaggerExamplesFromAssemblyOf<CreateUserRequestExample>();

		services.AddMediatR(
			cfg =>
				cfg.RegisterServicesFromAssembly(typeof(Program).Assembly));
		
		var typeAdapterConfig = TypeAdapterConfig.GlobalSettings;
		typeAdapterConfig.Scan(Assembly.GetExecutingAssembly());

		Mapper mapperConfig = new(typeAdapterConfig);
		services.AddSingleton<IMapper>(mapperConfig);

		return services;
	}

	public static IServiceCollection AddSwagger(this IServiceCollection services)
	{
		var apiVersioningBuilder = services.AddApiVersioning(
			o =>
			{
				o.AssumeDefaultVersionWhenUnspecified = true;
				o.DefaultApiVersion = new ApiVersion(1, 0);
				o.ReportApiVersions = true;
				o.ApiVersionReader = new UrlSegmentApiVersionReader();
			});

		apiVersioningBuilder.AddApiExplorer(
			options =>
			{
				options.GroupNameFormat = "'v'VVV";
				options.SubstituteApiVersionInUrl = true;
			});

		return services;
	}

	public static IServiceCollection AddAuth(this IServiceCollection services, IConfiguration configuration)
	{
		var jwtOptions = configuration.GetSection(nameof(JwtModel)).Get<JwtModel>();

		var clientId = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_ID");
		var clientSecret = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_SECRET");

		if (string.IsNullOrWhiteSpace(clientId) || string.IsNullOrWhiteSpace(clientSecret))
			throw new Exception("Google client data is null.");

		services
			.AddAuthentication(options =>
			{
				options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
				options.DefaultSignInScheme = JwtBearerDefaults.AuthenticationScheme;
				options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
			})
			.AddJwtBearer(JwtBearerDefaults.AuthenticationScheme,
				options =>
				{
					options.RequireHttpsMetadata = true;
					options.SaveToken = true;

					options.TokenValidationParameters = new TokenValidationParameters
					{
						ValidateIssuer = false,
						ValidateAudience = false,
						ValidateLifetime = true,
						ValidateIssuerSigningKey = true,
						IssuerSigningKey = new SymmetricSecurityKey(
							Encoding.UTF8.GetBytes(jwtOptions!.SecretKey))
					};

					options.Events = new JwtBearerEvents
					{
						OnAuthenticationFailed = _ => Task.CompletedTask,
						OnTokenValidated = _ => Task.CompletedTask
					};
				})
			.AddCookie(CookieAuthenticationDefaults.AuthenticationScheme)
			.AddGoogle(
				GoogleDefaults.AuthenticationScheme,
				options =>
				{
					options.ClientId = clientId;
					options.ClientSecret = clientSecret;
					options.SignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
					options.CallbackPath = "/google-response";
				});

		services.Configure<JwtModel>(configuration.GetSection(nameof(JwtModel)));
		services.Configure<AuthorizationOptions>(configuration.GetSection(nameof(AuthorizationOptions)));

		services.AddCors(
			options =>
			{
				options.AddDefaultPolicy(
					policy =>
					{
						policy.WithOrigins("http://localhost:5000");
						policy.WithOrigins("https://localhost:5001");
						// policy.WithOrigins("https://accounts.google.com");
						// policy.WithOrigins("http://10.0.2.2");
						policy.AllowAnyHeader();
						policy.AllowAnyMethod();
						policy.AllowCredentials();
					});
			});

		services.AddAuthorizationBuilder()
			.AddPolicy(
				"Admin",
				policy =>
				{
					policy.RequireRole(Role.Admin.GetDescription());
					policy.AddRequirements(new ActiveAdminRequirement());
				})
			.AddPolicy(
				"User",
				policy =>
				{
					policy.RequireRole(Role.User.GetDescription());
				})
			.AddPolicy(
				"All",
				policy =>
				{
					policy.RequireRole(Role.Admin.GetDescription(), Role.User.GetDescription());
					policy.AddRequirements(new ActiveAdminRequirement());
				});

		services.AddScoped<IAuthorizationHandler, ActiveAdminHandler>();

		services.AddApiVersioning(
			options =>
			{
				options.DefaultApiVersion = new ApiVersion(1, 0);
				options.AssumeDefaultVersionWhenUnspecified = true;
				options.ReportApiVersions = true;
			});

		return services;
	}

	public static WebApplicationBuilder UseHttps(this WebApplicationBuilder builder)
	{
		var environment = builder.Environment;

		if (environment.IsProduction())
		{
			const string certPath = "/app/localhost.pfx";
			const string certPassword = "1";

			builder.WebHost.ConfigureKestrel(
				options =>
				{
					options.ListenAnyIP(5000);

					options.ListenAnyIP(
						5001,
						listenOptions =>
						{
							listenOptions.UseHttps(certPath, certPassword);
						});
				});
		}
		else
		{
			builder.WebHost.ConfigureKestrel(
				options =>
				{
					options.ListenAnyIP(5000);

					options.ListenAnyIP(
						5001,
						listenOptions =>
						{
							listenOptions.UseHttps();
						});
				});
		}

		return builder;
	}
}