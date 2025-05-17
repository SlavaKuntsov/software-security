using System.Security.Claims;

using Microsoft.AspNetCore.Authorization;

namespace SoftwareSecurity.API.Extensions;

public class ActiveAdminHandler() : AuthorizationHandler<ActiveAdminRequirement>
{
	protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, ActiveAdminRequirement requirement)
	{
		var userIdClaim = context.User.FindFirst(ClaimTypes.NameIdentifier);
		var userRoleClaim = context.User.FindFirst(ClaimTypes.Role);

		if (userIdClaim == null || userRoleClaim == null)
		{
			context.Fail();
			return;
		}

		context.Succeed(requirement);
	}
}

public record ActiveAdminRequirement() : IAuthorizationRequirement;