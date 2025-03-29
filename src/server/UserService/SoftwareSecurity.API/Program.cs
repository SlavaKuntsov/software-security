using DotNetEnv;

using HealthChecks.UI.Client;

using Microsoft.AspNetCore.CookiePolicy;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.HttpOverrides;

using SoftwareSecurity.API.Extensions;
using SoftwareSecurity.Application.Extensions;
using SoftwareSecurity.Infrastructure.Extensions;
using SoftwareSecurity.Persistence.Extensions;

Env.Load("./../../.env");

var builder = WebApplication.CreateBuilder(args);
var services = builder.Services;
var configuration = builder.Configuration;

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.UseHttps();

services.AddAPI()
	.AddAuth(configuration)
	.AddSwagger()
	.AddApplication()
	.AddInfrastructure()
	.AddPersistence(configuration);

services.AddHealthChecks();

var app = builder.Build();

app.UseExceptionHandler();

app.UseSwagger();

app.UseSwaggerUI(
	c =>
	{
		c.SwaggerEndpoint("/swagger/v1/swagger.json", "Mobile API v1");
		c.SwaggerEndpoint("/swagger/v2/swagger.json", "Web API v2");
	});

app.UseCookiePolicy(
	new CookiePolicyOptions
	{
		MinimumSameSitePolicy = SameSiteMode.None,
		HttpOnly = HttpOnlyPolicy.Always,
		Secure = CookieSecurePolicy.Always
	});

// comment this only for  time when flutter client is in development
//app.UseHttpsRedirection();
app.UseForwardedHeaders(
	new ForwardedHeadersOptions
	{
		ForwardedHeaders = ForwardedHeaders.All
	});
app.UseCors();

app.MapHealthChecks(
	"/health",
	new HealthCheckOptions
	{
		ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
	});

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
