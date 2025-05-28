using System.Security.Claims;

using Asp.Versioning;
using Google.Apis.Auth;
using MapsterMapper;
using MediatR;

using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SoftwareSecurity.API.Contracts;
using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Application.Handlers.Commands.Auth.Registration;
using SoftwareSecurity.Application.Handlers.Commands.Auth.Unauthorize;
using SoftwareSecurity.Application.Handlers.Commands.Tokens.GenerateTokens;
using SoftwareSecurity.Application.Handlers.Commands.Users.DeleteUser;
using SoftwareSecurity.Application.Handlers.Commands.Users.UpdateUser;
using SoftwareSecurity.Application.Handlers.Queries.Tokens.GetByRefreshToken;
using SoftwareSecurity.Application.Handlers.Queries.Users.GetAllUsers;
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
[Route("api/v{version:apiVersion}/users")]
[ApiVersion("1.0")]
public class UserController(
	IMediator mediator,
	IMapper mapper)
	: ControllerBase
{

	[HttpPatch("")]
	[SwaggerRequestExample(typeof(UpdateUserRequest), typeof(UpdateUserRequestExample))]
	[Authorize(Policy = "All")]
	public async Task<IActionResult> Update(
		[FromBody] UpdateUserCommand request,
		CancellationToken cancellationToken)
	{
		var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)
						?? throw new UnauthorizedAccessException("User ID not found in claims.");

		if (!Ulid.TryParse(userIdClaim.Value, out var userId))
			throw new UnauthorizedAccessException("Invalid User ID format in claims.");

		var command = request with { Id = userId };

		var user = await mediator.Send(command, cancellationToken);

		return Ok(mapper.Map<UserDTO>(user));
	}

	[HttpDelete("{id:Guid?}")]
	[Authorize(Policy = "Admin")]
	public async Task<IActionResult> Delete(
		[FromRoute] Ulid id,
		CancellationToken cancellationToken)
	{
		var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)
						?? throw new UnauthorizedAccessException("User ID not found in claims.");

		if (!Ulid.TryParse(userIdClaim.Value, out var userId))
			throw new UnauthorizedAccessException("Invalid User ID format in claims.");

		if (userId == id)
			throw new UnprocessableContentException("Admin cannot delete himself.");

		await mediator.Send(new DeleteUserCommand(id), cancellationToken);

		return Ok();
	}

	[HttpDelete("me")]
	[Authorize(Policy = "User")]
	public async Task<IActionResult> Delete(CancellationToken cancellationToken)
	{
		var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)
						?? throw new UnauthorizedAccessException("User ID not found in claims.");

		if (!Ulid.TryParse(userIdClaim.Value, out var userId))
			throw new UnauthorizedAccessException("Invalid User ID format in claims.");

		await mediator.Send(new DeleteUserCommand(userId), cancellationToken);

		return Ok();
	}

	[HttpGet("")]
	[Authorize(Policy = "Admin")]
	public async Task<IActionResult> Users(CancellationToken cancellationToken)
	{
		var users = await mediator.Send(
			new GetAllUsersQuery(),
			cancellationToken);

		return Ok(mapper.Map<IList<UserDTO>>(users));
	}
}