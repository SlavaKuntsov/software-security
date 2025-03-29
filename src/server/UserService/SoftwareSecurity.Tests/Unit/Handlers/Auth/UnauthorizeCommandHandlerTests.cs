using Moq;

using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Application.Handlers.Commands.Auth.Unauthorize;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;

using Xunit;

namespace SoftwareSecurity.Tests.Unit.Handlers.Auth;

public class UnauthorizeCommandHandlerTests
{
	private readonly Mock<ITokensRepository> _tokensRepositoryMock;
	private readonly Mock<IApplicationDbContext> _contextMock;
	private readonly UnauthorizeCommandHandler _handler;

	public UnauthorizeCommandHandlerTests()
	{
		_tokensRepositoryMock = new Mock<ITokensRepository>();
		_contextMock = new Mock<IApplicationDbContext>();

		_handler = new UnauthorizeCommandHandler(
			_tokensRepositoryMock.Object,
			_contextMock.Object);
	}

	[Fact]
	public async Task Handle_ShouldRevokeRefreshToken_WhenTokenExists()
	{
		// Arrange
		var userId = Ulid.NewUlid();
		var refreshTokenModel = new RefreshTokenModel(userId, "mock_refresh_token", 7);

		_tokensRepositoryMock
			.Setup(repo => repo.GetAsync(userId, It.IsAny<CancellationToken>()))
			.ReturnsAsync(refreshTokenModel);

		_contextMock
			.Setup(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()))
			.ReturnsAsync(1);

		// Act
		await _handler.Handle(new UnauthorizeCommand(userId), CancellationToken.None);

		// Assert
		Assert.True(refreshTokenModel.IsRevoked);

		_tokensRepositoryMock.Verify(repo => repo.GetAsync(userId, It.IsAny<CancellationToken>()), Times.Once);
		_tokensRepositoryMock.Verify(repo => repo.Update(refreshTokenModel), Times.Once);
		_contextMock.Verify(ctx => ctx.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
	}
}