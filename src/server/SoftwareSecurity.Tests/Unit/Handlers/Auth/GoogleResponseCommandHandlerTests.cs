using Moq;

using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Application.Handlers.Commands.Auth.GoogleResponse;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;

using Xunit;

namespace SoftwareSecurity.Tests.Unit.Handlers.Auth;

public class GoogleResponseCommandHandlerTests
{
	private readonly Mock<IUsersRepository> _usersRepositoryMock;
	private readonly Mock<IApplicationDbContext> _contextMock;
	private readonly Mock<IJwt> _jwtMock;
	private readonly GoogleResponseCommandHandler _handler;

	public GoogleResponseCommandHandlerTests()
	{
		_usersRepositoryMock = new Mock<IUsersRepository>();
		_contextMock = new Mock<IApplicationDbContext>();
		_jwtMock = new Mock<IJwt>();

		_handler = new GoogleResponseCommandHandler(
			_usersRepositoryMock.Object,
			_contextMock.Object,
			_jwtMock.Object);
	}

	[Fact]
	public async Task Handle_ShouldRegisterUser_WhenUserDoesNotExist()
	{
		// Arrange
		var command = TestDataGenerator.GenerateGoogleResponseCommand();
		var accessToken = "mock_access_token";
		var refreshToken = "mock_refresh_token";
		var userId = Ulid.NewUlid();

		_usersRepositoryMock
			.Setup(repo => repo.GetAsync(command.Email, It.IsAny<CancellationToken>()))
			.ReturnsAsync((UserModel?)null);

		_jwtMock.Setup(jwt => jwt.GenerateAccessToken(It.IsAny<Ulid>(), Role.User))
			.Returns(accessToken);

		_jwtMock.Setup(jwt => jwt.GenerateRefreshToken())
			.Returns(refreshToken);

		_jwtMock.Setup(jwt => jwt.GetRefreshTokenExpirationDays())
			.Returns(7);

		_usersRepositoryMock
			.Setup(repo => repo.CreateAsync(It.IsAny<UserModel>(), It.IsAny<RefreshTokenModel>(), It.IsAny<CancellationToken>()))
			.ReturnsAsync(Ulid.NewUlid());

		_contextMock
			.Setup(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()))
			.ReturnsAsync(1);

		// Act
		var result = await _handler.Handle(command, CancellationToken.None);

		// Assert
		Assert.NotNull(result);
		Assert.Equal(accessToken, result.AccessToken);
		Assert.Equal(refreshToken, result.RefreshToken);

		_usersRepositoryMock.Verify(repo => repo.GetAsync(command.Email, It.IsAny<CancellationToken>()), Times.Once);
		_usersRepositoryMock.Verify(repo => repo.CreateAsync(It.IsAny<UserModel>(), It.IsAny<RefreshTokenModel>(), It.IsAny<CancellationToken>()), Times.Once);
		_contextMock.Verify(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
	}

	[Fact]
	public async Task Handle_ShouldThrowAlreadyExistsException_WhenUserExists()
	{
		// Arrange
		var command = TestDataGenerator.GenerateGoogleResponseCommand();
		var existingUser = TestDataGenerator.GenerateUserModel();

		_usersRepositoryMock
			.Setup(repo => repo.GetAsync(command.Email, It.IsAny<CancellationToken>()))
			.ReturnsAsync(existingUser);

		// Act & Assert
		await Assert.ThrowsAsync<AlreadyExistsException>(() => _handler.Handle(command, CancellationToken.None));

		_usersRepositoryMock.Verify(repo => repo.GetAsync(command.Email, It.IsAny<CancellationToken>()), Times.Once);
		_usersRepositoryMock.Verify(repo => repo.CreateAsync(It.IsAny<UserModel>(), It.IsAny<RefreshTokenModel>(), It.IsAny<CancellationToken>()), Times.Never);
		_contextMock.Verify(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
	}
}