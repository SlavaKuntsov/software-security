using Bogus;

using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Handlers.Commands.Auth.GoogleResponse;
using SoftwareSecurity.Application.Handlers.Commands.Auth.Registration;
using SoftwareSecurity.Application.Handlers.Commands.Tokens.GenerateTokens;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Models;

using UserService.API.Contracts;

namespace SoftwareSecurity.Tests.Unit;

public static class TestDataGenerator
{
	private static readonly Faker _faker = new();

	public static string refreshToken = "mock_refresh_token";
	public static string accessToken = "mock_access_token";

	public static UserDTO GenerateUserDTO()
	{
		return new UserDTO(
			Id: Ulid.NewUlid(),
			Email: _faker.Internet.Email(),
			Role: _faker.PickRandom<Role>().ToString(),
			FirstName: _faker.Name.FirstName(),
			LastName: _faker.Name.LastName(),
			DateOfBirth: _faker.Date.Past(20).ToString("yyyy-MM-dd")
		);
	}

	public static UserRoleDTO GenerateUserRoleDTO()
	{
		return new UserRoleDTO(
			Id: Ulid.NewUlid(),
			Role: Role.User
		);
	}

	public static AuthDTO GenerateAuthDTO()
	{
		return new AuthDTO(
			AccessToken: _faker.Random.AlphaNumeric(32),
			RefreshToken: _faker.Random.AlphaNumeric(32)
		);
	}

	public static UserModel GenerateUserModel()
	{
		return new UserModel(
			email: _faker.Internet.Email(),
			password: _faker.Internet.Password(),
			role: _faker.PickRandom<Role>(),
			firstName: _faker.Name.FirstName(),
			lastName: _faker.Name.LastName(),
			dateOfBirth: _faker.Date.Past(20).ToString("yyyy-MM-dd")
		);
	}

	public static RefreshTokenModel GenerateRefreshTokenModel()
	{
		return new RefreshTokenModel(
			userId: Ulid.NewUlid(),
			token: _faker.Random.AlphaNumeric(32),
			refreshTokenExpirationDays: 1
		);
	}

	public static CreateLoginRequest GenerateCreateLoginRequest()
	{
		return new CreateLoginRequest(
			Email: _faker.Internet.Email(),
			Password: _faker.Internet.Password()
		);
	}

	public static UserRegistrationCommand GenerateUserRegistrationCommand()
	{
		return new UserRegistrationCommand(
			Email: _faker.Internet.Email(),
			Password: _faker.Internet.Password(),
			FirstName: _faker.Name.FirstName(),
			LastName: _faker.Name.LastName(),
			DateOfBirth: _faker.Date.Past(20).ToString("yyyy-MM-dd")
		);
	}

	public static AccessTokenDTO GenerateAccessTokenDTO()
	{
		return new AccessTokenDTO("mock_access_token");
	}

	public static GoogleResponseCommand GenerateGoogleResponseCommand()
	{
		return new GoogleResponseCommand(
			Email: _faker.Internet.Email(),
			FirstName: _faker.Name.FirstName(),
			LastName: _faker.Name.LastName()
		);
	}

	public static GenerateTokensCommand GenerateTokensCommand()
	{
		return new GenerateTokensCommand(
			Id: Ulid.NewUlid(),
			Role: Role.User
		);
	}
}