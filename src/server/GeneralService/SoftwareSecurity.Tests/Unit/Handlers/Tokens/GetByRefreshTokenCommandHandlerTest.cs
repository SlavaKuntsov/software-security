using Moq;

using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Application.Handlers.Queries.Tokens.GetByRefreshToken;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces.Repositories;

using Xunit;

namespace SoftwareSecurity.Tests.Unit.Handlers.Tokens;

public class GetByRefreshTokenCommandHandlerTests
{
	private readonly Mock<IUsersRepository> _usersRepositoryMock;
	private readonly Mock<IJwt> _jwtMock;
	private readonly GetByRefreshTokenCommandHandler _handler;

	public GetByRefreshTokenCommandHandlerTests()
	{
		_usersRepositoryMock = new Mock<IUsersRepository>();
		_jwtMock = new Mock<IJwt>();

		_handler = new GetByRefreshTokenCommandHandler(_usersRepositoryMock.Object, _jwtMock.Object);
	}

	[Fact]
	public async Task Handle_ShouldReturnUserRoleDTO_WhenTokenIsValid()
	{
		// Arrange
		var refreshToken = TestDataGenerator.refreshToken;
		var userRoleDTO = TestDataGenerator.GenerateUserRoleDTO();

		_jwtMock.Setup(j => j.ValidateRefreshTokenAsync(refreshToken, It.IsAny<CancellationToken>()))
			.ReturnsAsync(userRoleDTO.Id);

		_usersRepositoryMock.Setup(r => r.GetRoleByIdAsync(userRoleDTO.Id, It.IsAny<CancellationToken>()))
			.ReturnsAsync(userRoleDTO.Role);

		var command = new GetByRefreshTokenCommand(refreshToken);

		// Act
		var result = await _handler.Handle(command, CancellationToken.None);

		// Assert
		Assert.Equal(userRoleDTO.Id, result.Id);
		Assert.Equal(userRoleDTO.Role, result.Role);
	}

	[Fact]
	public async Task Handle_ShouldThrowUnauthorizedAccessException_WhenTokenIsMissing()
	{
		// Arrange
		var command = new GetByRefreshTokenCommand(string.Empty);

		// Act & Assert
		await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _handler.Handle(command, CancellationToken.None));
	}

	[Fact]
	public async Task Handle_ShouldThrowInvalidTokenException_WhenTokenIsInvalid()
	{
		// Arrange
		var refreshToken = TestDataGenerator.refreshToken;

		_jwtMock.Setup(j => j.ValidateRefreshTokenAsync(refreshToken, It.IsAny<CancellationToken>()))
			.ReturnsAsync(Ulid.Empty);

		var command = new GetByRefreshTokenCommand(refreshToken);

		// Act & Assert
		await Assert.ThrowsAsync<InvalidTokenException>(() => _handler.Handle(command, CancellationToken.None));
	}

	[Fact]
	public async Task Handle_ShouldThrowNotFoundException_WhenUserNotFound()
	{
		// Arrange
		var refreshToken = TestDataGenerator.refreshToken;
		var userId = TestDataGenerator.GenerateUserRoleDTO().Id;

		_jwtMock.Setup(j => j.ValidateRefreshTokenAsync(refreshToken, It.IsAny<CancellationToken>()))
			.ReturnsAsync(userId);

		_usersRepositoryMock.Setup(r => r.GetRoleByIdAsync(userId, It.IsAny<CancellationToken>()))
			.ReturnsAsync((Role?)null);

		var command = new GetByRefreshTokenCommand(refreshToken);

		// Act & Assert
		await Assert.ThrowsAsync<NotFoundException>(() => _handler.Handle(command, CancellationToken.None));
	}
}