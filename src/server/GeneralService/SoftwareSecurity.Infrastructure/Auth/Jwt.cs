using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Extensions;
using SoftwareSecurity.Domain.Interfaces.Repositories;

namespace SoftwareSecurity.Infrastructure.Auth;

public class Jwt(
	IOptions<JwtModel> jwtOptions, 
	ITokensRepository tokensRepository) 
	: IJwt
{
	private readonly JwtModel _jwtOptions = jwtOptions.Value;

	public string GenerateAccessToken(Ulid id, Role role)
	{
		var claims = new[]
		{
			new Claim(ClaimTypes.NameIdentifier, id.ToString()),
			new Claim(ClaimTypes.Role, role.GetDescription())
		};

		var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtOptions.SecretKey));
		var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

		var token = new JwtSecurityToken(
			claims: claims,
			expires: DateTime.Now.AddMinutes(_jwtOptions.AccessTokenExpirationMinutes),
			signingCredentials: creds);

		return new JwtSecurityTokenHandler().WriteToken(token);
	}

	public string GenerateRefreshToken()
	{
		var randomBytes = new byte[64];
		using var rng = RandomNumberGenerator.Create();
		rng.GetBytes(randomBytes);

		return Convert.ToBase64String(randomBytes);
	}

	public async Task<Ulid> ValidateRefreshTokenAsync(string refreshToken, CancellationToken cancellationToken)
	{
		var storedToken = await tokensRepository.GetAsync(refreshToken, cancellationToken);

		if (storedToken == null || storedToken.IsRevoked || storedToken.ExpiresAt < DateTime.UtcNow)
			return Ulid.Empty;

		return storedToken.UserId.Value;
	}

	public int GetRefreshTokenExpirationDays()
	{
		return _jwtOptions.RefreshTokenExpirationDays;
	}
}