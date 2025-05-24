using System.Security.Claims;

using Asp.Versioning;
using Google.Apis.Auth;
using MediatR;

using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SoftwareSecurity.API.Contracts;
using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Handlers.Commands.Auth.Registration;
using SoftwareSecurity.Application.Handlers.Commands.Auth.Unauthorize;
using SoftwareSecurity.Application.Handlers.Commands.Tokens.GenerateTokens;
using SoftwareSecurity.Application.Handlers.Queries.Tokens.GetByRefreshToken;
using SoftwareSecurity.Application.Handlers.Queries.Users.GetUserByEmail;
using SoftwareSecurity.Application.Handlers.Queries.Users.GetUserById;
using SoftwareSecurity.Application.Handlers.Queries.Users.Login;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Constants;
using SoftwareSecurity.Domain.Enums;

using Swashbuckle.AspNetCore.Filters;

using UserService.API.Contracts;
using UserService.API.Contracts.Examples;

namespace SoftwareSecurity.API.Controllers;

[ApiController]
[Route("api/v{version:apiVersion}/auth")]
[ApiVersion("1.0")]
public class AuthController(
	IMediator mediator,
	ICookieService cookieService)
	: ControllerBase
{
	[HttpGet("refresh-token")]
	public async Task<IActionResult> RefreshToken(CancellationToken cancellationToken)
	{
		var refreshToken = cookieService.GetRefreshToken();

		var userRoleDto = await mediator.Send(
			new GetByRefreshTokenCommand(
				refreshToken),
			cancellationToken);

		var authResultDto = await mediator.Send(
			new GenerateTokensCommand(userRoleDto.Id, userRoleDto.Role),
			cancellationToken);

		HttpContext.Response.Cookies.Append(
			JwtConstants.REFRESH_COOKIE_NAME,
			authResultDto.RefreshToken);

		return Ok(new { authResultDto.AccessToken, authResultDto.RefreshToken });
	}

	[HttpGet("authorize")]
	[Authorize(Policy = "All")]
	public async Task<IActionResult> Authorize(CancellationToken cancellationToken)
	{
		var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier) 
						?? throw new UnauthorizedAccessException("User ID not found in claims.");

		if (!Ulid.TryParse(userIdClaim.Value, out var userId))
			throw new UnauthorizedAccessException("Invalid User ID format in claims.");

		var user = await mediator.Send(
			new GetUserByIdQuery(userId),
			cancellationToken);

		return Ok(user);
	}

	[HttpGet("unauthorize")]
	[Authorize(Policy = "All")]
	public async Task<IActionResult> Unauthorize(CancellationToken cancellationToken)
	{
		var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)
						?? throw new UnauthorizedAccessException("User ID not found in claims.");

		var userId = Ulid.Parse(userIdClaim.Value);

		cookieService.DeleteRefreshToken();

		await mediator.Send(new UnauthorizeCommand(userId), cancellationToken);

		return Ok();
	}
	
	[HttpPost("login")]
	[SwaggerRequestExample(typeof(CreateLoginRequest), typeof(CreateLoginRequestExample))]
	public async Task<IActionResult> Login([FromBody] CreateLoginRequest request, CancellationToken cancellationToken)
	{
		var existUser = await mediator.Send(
			new LoginQuery(request.Email, request.Password),
			cancellationToken);

		var authResultDto = await mediator.Send(
			new GenerateTokensCommand(existUser.Id, existUser.Role), cancellationToken);

		HttpContext.Response.Cookies.Append(
			JwtConstants.REFRESH_COOKIE_NAME,
			authResultDto.RefreshToken);

		return Ok(new AccessTokenDTO(
			authResultDto.AccessToken,
			authResultDto.RefreshToken));
	}

	[HttpPost("registration")]
	[SwaggerRequestExample(typeof(CreateUserRequest), typeof(CreateUserRequestExample))]
	public async Task<IActionResult> Registration([FromBody] UserRegistrationCommand request, CancellationToken cancellationToken)
	{
		var authResultDto = await mediator.Send(request, cancellationToken);

		return Ok(new AccessTokenDTO(
			authResultDto.AccessToken,
			authResultDto.RefreshToken));
	}

	[HttpGet("google-login")]
	public IActionResult GoogleLogin()
	{
		var redirectUrl = Url.Action("GoogleResponse", "Auth");
		var properties = new AuthenticationProperties { RedirectUri = redirectUrl };

		return Challenge(properties, GoogleDefaults.AuthenticationScheme);
	}

	[HttpGet("google-response")]
	public async Task<IActionResult> GoogleResponse(CancellationToken cancellationToken)
	{
		var result = await HttpContext.AuthenticateAsync(GoogleDefaults.AuthenticationScheme);
	
		if (!result.Succeeded)
			return BadRequest("Google authentication failed.");
	
		var email = result.Principal.FindFirst(ClaimTypes.Email)?.Value;
		var firstName = result.Principal.FindFirst(ClaimTypes.GivenName)?.Value;
		var lastName = result.Principal.FindFirst(ClaimTypes.Surname)?.Value;
	
		if (string.IsNullOrEmpty(email))
			return BadRequest("Invalid Google credentials.");
	
		var user = await mediator.Send(new GetUserByEmailQuery(email), cancellationToken);
	
		var authResultDto = default(AuthDTO);
		var text = default(string);
	
		if (user is not null)
		{
			authResultDto = await mediator.Send(
				new GenerateTokensCommand(user.Id, user.Role),
				cancellationToken);
	
			text = "login";
		}
		else
		{
			authResultDto = await mediator.Send(
				new UserRegistrationCommand(
					email,
					string.Empty,
					firstName,
					lastName,
					string.Empty,
					AuthType.Google),
				cancellationToken);
	
			text = "registration";
		}
	
		HttpContext.Response.Cookies.Append(
			JwtConstants.REFRESH_COOKIE_NAME,
			authResultDto.RefreshToken
		);
	
		return Ok(
			new
			{
				text,
				user,
				authResultDto
			});
	}
	
	[HttpPost("google-mobile-auth")]
	public async Task<IActionResult> GoogleMobileAuth(
		[FromBody] GoogleAuthRequest request,
		CancellationToken cancellationToken)
	{
		var clientId = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_ID");
	
		var payload = await GoogleJsonWebSignature.ValidateAsync(
			request.IdToken,
			new GoogleJsonWebSignature.ValidationSettings
			{
				Audience = [clientId]
			});
	
		var email = payload.Email;
		var firstName = payload.GivenName;
		var lastName = payload.FamilyName;
	
		if (string.IsNullOrEmpty(email))
			return BadRequest("Invalid Google credentials.");
	
		var user = await mediator.Send(new GetUserByEmailQuery(email), cancellationToken);
	
		var authResultDto = default(AuthDTO);
		var text = default(string);
	
		if (user is not null)
		{
			authResultDto = await mediator.Send(
				new GenerateTokensCommand(user.Id, user.Role),
				cancellationToken);
	
			text = "login";
		}
		else
		{
			authResultDto = await mediator.Send(
				new UserRegistrationCommand(
					email,
					string.Empty,
					firstName,
					lastName,
					string.Empty,
					AuthType.Google),
				cancellationToken);
	
			text = "registration";
		}
	
		HttpContext.Response.Cookies.Append(
			JwtConstants.REFRESH_COOKIE_NAME,
			authResultDto.RefreshToken
		);
	
		return Ok(
			new
			{
				text,
				user,
				authResultDto
			});
	}
}