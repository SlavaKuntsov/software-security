using System.Security.Claims;

using Bogus;

using MediatR;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

using Moq;

using SoftwareSecurity.API.Controllers.Web;
using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Handlers.Commands.Auth.Registration;
using SoftwareSecurity.Application.Handlers.Commands.Tokens.GenerateTokens;
using SoftwareSecurity.Application.Handlers.Queries.Tokens.GetByRefreshToken;
using SoftwareSecurity.Application.Handlers.Queries.Users.GetUserById;
using SoftwareSecurity.Application.Handlers.Queries.Users.Login;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Enums;

using Xunit;

namespace SoftwareSecurity.Tests.Unit.Controllers;

public class AuthControllerTests
{
	private readonly Mock<IMediator> _mediatorMock;
	private readonly Mock<ICookieService> _cookieServiceMock;
	private readonly Mock<ILogger<AuthController>> _loggerMock;
	private readonly AuthController _controller;
	private readonly Faker _faker;

	public AuthControllerTests()
	{
		_mediatorMock = new Mock<IMediator>();
		_cookieServiceMock = new Mock<ICookieService>();
		_loggerMock = new Mock<ILogger<AuthController>>();
		_controller = new AuthController(
			_mediatorMock.Object,
			_cookieServiceMock.Object);
		_faker = new Faker();

		var httpContext = new DefaultHttpContext();
		_controller.ControllerContext = new ControllerContext
		{
			HttpContext = httpContext
		};
	}

	[Fact]
	public async Task RefreshToken_ShouldReturnNewAccessToken()
	{
		// Arrange
		var userId = Ulid.NewUlid();
		var userRole = Role.User;

		var accessTokenDTO = TestDataGenerator.GenerateAccessTokenDTO();

		_cookieServiceMock.Setup(c => c.GetRefreshToken()).Returns(TestDataGenerator.refreshToken);

		_mediatorMock
			.Setup(m => m.Send(
				It.IsAny<GetByRefreshTokenCommand>(),
				It.IsAny<CancellationToken>()))
			.ReturnsAsync(new UserRoleDTO(userId, userRole));

		_mediatorMock
			.Setup(m => m.Send(
				It.IsAny<GenerateTokensCommand>(),
				It.IsAny<CancellationToken>()))
			.ReturnsAsync(new AuthDTO(TestDataGenerator.accessToken, TestDataGenerator.refreshToken));

		// Act
		var result = await _controller.RefreshToken(CancellationToken.None) as OkObjectResult;

		// Assert
		Assert.NotNull(result);
		Assert.Equal(200, result.StatusCode);
		Assert.Equal(accessTokenDTO, result.Value);
	}

	[Fact]
	public async Task Authorize_ShouldReturnUserData()
	{
		// Arrange
		var user = TestDataGenerator.GenerateUserDTO();
		var claims = new List<Claim>
		{
			new(ClaimTypes.NameIdentifier, user.Id.ToString())
		};
		var identity = new ClaimsIdentity(claims);
		var principal = new ClaimsPrincipal(identity);

		_controller.ControllerContext = new ControllerContext
		{
			HttpContext = new DefaultHttpContext { User = principal }
		};

		_mediatorMock
			.Setup(m => m.Send(It.IsAny<GetUserByIdQuery>(), It.IsAny<CancellationToken>()))
			.ReturnsAsync(user);

		// Act
		var result = await _controller.Authorize(CancellationToken.None) as OkObjectResult;

		// Assert
		Assert.NotNull(result);
		Assert.Equal(200, result.StatusCode);
		Assert.Equal(user, result.Value);
	}

	[Fact]
	public async Task Login_ShouldReturnAccessToken()
	{
		// Arrange
		var request = TestDataGenerator.GenerateCreateLoginRequest();
		var user = TestDataGenerator.GenerateUserRoleDTO();
		var authDto = TestDataGenerator.GenerateAuthDTO();

		_mediatorMock
			.Setup(m => m.Send(It.IsAny<LoginQuery>(), It.IsAny<CancellationToken>()))
			.ReturnsAsync(user);

		_mediatorMock
			.Setup(m => m.Send(It.IsAny<GenerateTokensCommand>(), It.IsAny<CancellationToken>()))
			.ReturnsAsync(authDto);

		// Act
		var result = await _controller.Login(request, CancellationToken.None) as OkObjectResult;

		// Assert
		Assert.NotNull(result);
		Assert.Equal(200, result.StatusCode);
		var response = result.Value as dynamic;
		Assert.Equal(authDto.AccessToken, response?.AccessToken);
	}

	[Fact]
	public async Task Registration_ShouldReturnAccessToken()
	{
		// Arrange
		var request = TestDataGenerator.GenerateUserRegistrationCommand();
		var authDto = TestDataGenerator.GenerateAuthDTO();

		_mediatorMock
			.Setup(m => m.Send(It.IsAny<UserRegistrationCommand>(), It.IsAny<CancellationToken>()))
			.ReturnsAsync(authDto);

		// Act
		var result = await _controller.Registration(request, CancellationToken.None) as OkObjectResult;

		// Assert
		Assert.NotNull(result);
		Assert.Equal(200, result.StatusCode);

		var response = result.Value as dynamic;
		Assert.Equal(authDto.AccessToken, response?.AccessToken);
	}
}