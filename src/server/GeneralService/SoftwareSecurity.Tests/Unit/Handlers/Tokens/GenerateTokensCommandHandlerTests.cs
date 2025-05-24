using Moq;

using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Application.Handlers.Commands.Tokens.GenerateTokens;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;

using Xunit;

namespace SoftwareSecurity.Tests.Unit.Handlers.Tokens;

public class GenerateTokensCommandHandlerTests
{
	private readonly Mock<ITokensRepository> _tokensRepositoryMock;
	private readonly Mock<IApplicationDbContext> _contextMock;
	private readonly Mock<IJwt> _jwtMock;
	private readonly GenerateTokensCommandHandler _handler;

	public GenerateTokensCommandHandlerTests()
	{
		_tokensRepositoryMock = new Mock<ITokensRepository>();
		_contextMock = new Mock<IApplicationDbContext>();
		_jwtMock = new Mock<IJwt>();

		_handler = new GenerateTokensCommandHandler(
			_tokensRepositoryMock.Object,
			_contextMock.Object,
			_jwtMock.Object);
	}

	[Fact]
	public async Task Handle_ShouldGenerateNewTokens_WhenNoExistingRefreshToken()
	{
		// Arrange
		var command = TestDataGenerator.GenerateTokensCommand();
		var refreshTokenExpirationDays = 7;

		_jwtMock.Setup(jwt => jwt.GenerateAccessToken(It.IsAny<Ulid>(), It.IsAny<Role>())).Returns(TestDataGenerator.accessToken);
		_jwtMock.Setup(jwt => jwt.GenerateRefreshToken()).Returns(TestDataGenerator.refreshToken);
		_jwtMock.Setup(jwt => jwt.GetRefreshTokenExpirationDays()).Returns(refreshTokenExpirationDays);

		_tokensRepositoryMock.Setup(repo => repo.GetAsync(It.IsAny<Ulid>(), It.IsAny<CancellationToken>())).ReturnsAsync((RefreshTokenModel?)null);

		_tokensRepositoryMock.Setup(repo => repo.CreateAsync(It.IsAny<RefreshTokenModel>(), It.IsAny<CancellationToken>())).Returns(Task.CompletedTask);
		_contextMock.Setup(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>())).ReturnsAsync(1);

		// Act
		var result = await _handler.Handle(command, CancellationToken.None);

		// Assert
		Assert.NotNull(result);
		Assert.Equal(TestDataGenerator.accessToken, result.AccessToken);
		Assert.Equal(TestDataGenerator.refreshToken, result.RefreshToken);

		_tokensRepositoryMock.Verify(repo => repo.CreateAsync(It.IsAny<RefreshTokenModel>(), It.IsAny<CancellationToken>()), Times.Once);
		_contextMock.Verify(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
	}

	[Fact]
	public async Task Handle_ShouldUpdateExistingRefreshToken_WhenRefreshTokenExists()
	{
		// Arrange
		var command = TestDataGenerator.GenerateTokensCommand();
		var existingRefreshToken = TestDataGenerator.GenerateRefreshTokenModel();
		var refreshTokenExpirationDays = 7;

		_jwtMock.Setup(jwt => jwt.GenerateAccessToken(It.IsAny<Ulid>(), It.IsAny<Role>())).Returns(TestDataGenerator.accessToken);
		_jwtMock.Setup(jwt => jwt.GenerateRefreshToken()).Returns(TestDataGenerator.refreshToken);
		_jwtMock.Setup(jwt => jwt.GetRefreshTokenExpirationDays()).Returns(refreshTokenExpirationDays);

		_tokensRepositoryMock.Setup(repo => repo.GetAsync(It.IsAny<Ulid>(), It.IsAny<CancellationToken>())).ReturnsAsync(existingRefreshToken);
		_tokensRepositoryMock.Setup(repo => repo.Update(It.IsAny<RefreshTokenModel>())).Verifiable();

		// Act
		var result = await _handler.Handle(command, CancellationToken.None);

		// Assert
		Assert.NotNull(result);
		Assert.Equal(TestDataGenerator.accessToken, result.AccessToken);
		Assert.Equal(TestDataGenerator.refreshToken, result.RefreshToken);

		_tokensRepositoryMock.Verify(repo => repo.Update(It.IsAny<RefreshTokenModel>()), Times.Once);
		_contextMock.Verify(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
	}

	[Fact]
	public async Task Handle_ShouldCallSaveChangesAsync_AfterUpdatingRefreshToken()
	{
		// Arrange
		var command = TestDataGenerator.GenerateTokensCommand();
		var existingRefreshToken = TestDataGenerator.GenerateRefreshTokenModel();
		var refreshTokenExpirationDays = 7;

		_jwtMock.Setup(jwt => jwt.GenerateAccessToken(It.IsAny<Ulid>(), It.IsAny<Role>())).Returns(TestDataGenerator.accessToken);
		_jwtMock.Setup(jwt => jwt.GenerateRefreshToken()).Returns(TestDataGenerator.refreshToken);
		_jwtMock.Setup(jwt => jwt.GetRefreshTokenExpirationDays()).Returns(refreshTokenExpirationDays);

		_tokensRepositoryMock.Setup(repo => repo.GetAsync(It.IsAny<Ulid>(), It.IsAny<CancellationToken>())).ReturnsAsync(existingRefreshToken);
		_tokensRepositoryMock.Setup(repo => repo.Update(It.IsAny<RefreshTokenModel>())).Verifiable();

		// Act
		var result = await _handler.Handle(command, CancellationToken.None);

		// Assert
		_contextMock.Verify(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
	}

	[Fact]
	public async Task Handle_ShouldThrowException_WhenSaveFails()
	{
		// Arrange
		var command = TestDataGenerator.GenerateTokensCommand();
		var refreshTokenExpirationDays = 7;

		_jwtMock.Setup(jwt => jwt.GenerateAccessToken(It.IsAny<Ulid>(), It.IsAny<Role>())).Returns(TestDataGenerator.accessToken);
		_jwtMock.Setup(jwt => jwt.GenerateRefreshToken()).Returns(TestDataGenerator.refreshToken);
		_jwtMock.Setup(jwt => jwt.GetRefreshTokenExpirationDays()).Returns(refreshTokenExpirationDays);

		_tokensRepositoryMock.Setup(repo => repo.GetAsync(It.IsAny<Ulid>(), It.IsAny<CancellationToken>())).ReturnsAsync((RefreshTokenModel?)null);
		_tokensRepositoryMock.Setup(repo => repo.CreateAsync(It.IsAny<RefreshTokenModel>(), It.IsAny<CancellationToken>())).Returns(Task.CompletedTask);

		_contextMock.Setup(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>())).ThrowsAsync(new Exception("Save failed"));

		// Act & Assert
		await Assert.ThrowsAsync<Exception>(() => _handler.Handle(command, CancellationToken.None));

		_contextMock.Verify(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
	}
}