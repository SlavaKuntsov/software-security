using SoftwareSecurity.Application.Interfaces.Auth;

namespace SoftwareSecurity.Infrastructure.Auth;

public class PasswordHash : IPasswordHash
{
	public string Generate(string password)
	{
		return BCrypt.Net.BCrypt.EnhancedHashPassword(password);
	}

	public bool Verify(string password, string passwordHash)
	{
		return BCrypt.Net.BCrypt.EnhancedVerify(password, passwordHash);
	}
}