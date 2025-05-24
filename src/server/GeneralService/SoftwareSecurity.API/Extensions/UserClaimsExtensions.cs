using System.Security.Claims;

namespace SoftwareSecurity.API.Controllers;

public static class UserClaimsExtensions
{
    public static Ulid? GetUserId(this ClaimsPrincipal user)
    {
        var userIdClaim = user.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
        if (userIdClaim == null)
            return null;

        if (Ulid.TryParse(userIdClaim.Value, out var userId))
            return userId;

        return null;
    }
} 