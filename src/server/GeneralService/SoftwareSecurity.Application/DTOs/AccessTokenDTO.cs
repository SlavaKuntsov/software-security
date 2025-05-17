namespace SoftwareSecurity.Application.DTOs;

public record AccessTokenDTO(
	string AccessToken,
	string RefreshToken);