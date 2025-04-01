using Moq;

using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Application.Handlers.Commands.Auth.Registration;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;

using Xunit;

namespace SoftwareSecurity.Tests.Unit.Handlers.Auth;

public class UserRegistrationCommandHandlerTests
{
	private readonly Mock<IUsersRepository> _usersRepositoryMock = new();
	private readonly Mock<IPasswordHash> _passwordHashMock = new();
	private readonly Mock<IApplicationDbContext> _contextMock = new();
	private readonly Mock<IJwt> _jwtMock = new();
	private readonly UserRegistrationCommandHandler _handler;

	public UserRegistrationCommandHandlerTests()
	{
		_handler = new UserRegistrationCommandHandler(
			_usersRepositoryMock.Object,
			_passwordHashMock.Object,
			_contextMock.Object,
			_jwtMock.Object
		);
	}

	[Fact]
	public async Task Handle_ShouldRegisterUser_WhenUserDoesNotExist()
	{
		// Arrange
		var command = TestDataGenerator.GenerateUserRegistrationCommand();
		var hashedPassword = "hashed_password";
		var accessToken = "mock_access_token";
		var refreshToken = "mock_refresh_token";
		var userId = Ulid.NewUlid();

		_usersRepositoryMock.Setup(repo => repo.GetIdAsync(command.Email, It.IsAny<CancellationToken>()))
			.ReturnsAsync(Ulid.Empty);

		_passwordHashMock.Setup(ph => ph.Generate(command.Password))
			.Returns(hashedPassword);

		_jwtMock.Setup(jwt => jwt.GenerateAccessToken(It.IsAny<Ulid>(), Role.User))
			.Returns(accessToken);

		_jwtMock.Setup(jwt => jwt.GenerateRefreshToken())
			.Returns(refreshToken);

		_jwtMock.Setup(jwt => jwt.GetRefreshTokenExpirationDays())
			.Returns(7);

		_usersRepositoryMock.Setup(repo => repo.CreateAsync(It.IsAny<UserModel>(), It.IsAny<RefreshTokenModel>(), It.IsAny<CancellationToken>()))
			.ReturnsAsync(userId); // Возвращаем Ulid

		_contextMock.Setup(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()))
			.ReturnsAsync(1); // Возвращаем int

		// Act
		var result = await _handler.Handle(command, CancellationToken.None);

		// Assert
		Assert.NotNull(result);
		Assert.Equal(accessToken, result.AccessToken);
		Assert.Equal(refreshToken, result.RefreshToken);

		_usersRepositoryMock.Verify(repo => repo.GetIdAsync(command.Email, It.IsAny<CancellationToken>()), Times.Once);
		_usersRepositoryMock.Verify(repo => repo.CreateAsync(It.IsAny<UserModel>(), It.IsAny<RefreshTokenModel>(), It.IsAny<CancellationToken>()), Times.Once);
		_contextMock.Verify(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
	}

	[Fact]
	public async Task Handle_ShouldThrowAlreadyExistsException_WhenUserAlreadyExists()
	{
		// Arrange
		var command = TestDataGenerator.GenerateUserRegistrationCommand();
		var existingUserId = Ulid.NewUlid();

		_usersRepositoryMock.Setup(repo => repo.GetIdAsync(command.Email, It.IsAny<CancellationToken>()))
			.ReturnsAsync(existingUserId);

		// Act & Assert
		await Assert.ThrowsAsync<AlreadyExistsException>(() => _handler.Handle(command, CancellationToken.None));

		_usersRepositoryMock.Verify(repo => repo.GetIdAsync(command.Email, It.IsAny<CancellationToken>()), Times.Once);
		_usersRepositoryMock.Verify(repo => repo.CreateAsync(It.IsAny<UserModel>(), It.IsAny<RefreshTokenModel>(), It.IsAny<CancellationToken>()), Times.Never);
		_contextMock.Verify(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
	}
}
