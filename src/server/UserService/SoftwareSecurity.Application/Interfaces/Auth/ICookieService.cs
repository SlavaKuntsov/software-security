namespace SoftwareSecurity.Application.Interfaces.Auth;

public interface ICookieService
{
	void DeleteRefreshToken();
	string GetRefreshToken();
}