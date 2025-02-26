namespace SoftwareSecurity.Application.DTOs;

public record AuthDTO(
	string AccessToken,
	string RefreshToken);