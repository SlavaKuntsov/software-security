using SoftwareSecurity.Domain.Enums;

namespace SoftwareSecurity.Application.Interfaces.Auth;

public interface IJwt
{
	public string GenerateAccessToken(Ulid id, Role role);
	public string GenerateRefreshToken();
	public Task<Ulid> ValidateRefreshTokenAsync(string refreshToken, CancellationToken cancellationToken);
	public int GetRefreshTokenExpirationDays();
}