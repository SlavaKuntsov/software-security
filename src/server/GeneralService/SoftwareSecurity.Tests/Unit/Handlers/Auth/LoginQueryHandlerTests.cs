using Moq;
using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Application.Handlers.Queries.Users.Login;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;
using System.Threading;
using Xunit;

namespace SoftwareSecurity.Tests.Unit.Handlers.Auth;

public class LoginQueryHandlerTests
{
    private readonly Mock<IUsersRepository> _usersRepositoryMock;
    private readonly Mock<IPasswordHash> _passwordHashMock;
    private readonly LoginQueryHandler _handler;

    public LoginQueryHandlerTests()
    {
        _usersRepositoryMock = new Mock<IUsersRepository>();
        _passwordHashMock = new Mock<IPasswordHash>();
        _handler = new LoginQueryHandler(_usersRepositoryMock.Object, _passwordHashMock.Object);
    }

    [Fact]
    public async Task Handle_WithValidCredentials_ReturnsUserRoleDTO()
    {
        // Arrange
        var email = "test@example.com";
        var password = "password123";
        var userId = Ulid.NewUlid();
        var role = Role.User;

        var userModel = new UserModel(
            email, 
            "hashedPassword", 
            role, 
            AuthType.Login, 
            "John", 
            "Doe", 
            "1990-01-01"
        )
        {
            Id = userId
        };

        _usersRepositoryMock
            .Setup(repo => repo.GetAsync(email, It.IsAny<CancellationToken>()))
            .ReturnsAsync(userModel);

        _passwordHashMock
            .Setup(hash => hash.Verify(password, "hashedPassword"))
            .Returns(true);

        var query = new LoginQuery(email, password);

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(userId, result.Id);
        Assert.Equal(role, result.Role);

        _usersRepositoryMock.Verify(repo => repo.GetAsync(email, It.IsAny<CancellationToken>()), Times.Once);
        _passwordHashMock.Verify(hash => hash.Verify(password, "hashedPassword"), Times.Once);
    }

    [Fact]
    public async Task Handle_WithInvalidEmail_ThrowsNotFoundException()
    {
        // Arrange
        var email = "nonexistent@example.com";
        var password = "password123";

        _usersRepositoryMock
            .Setup(repo => repo.GetAsync(email, It.IsAny<CancellationToken>()))
            .ReturnsAsync((UserModel)null);

        var query = new LoginQuery(email, password);

        // Act & Assert
        await Assert.ThrowsAsync<NotFoundException>(async () => 
            await _handler.Handle(query, CancellationToken.None));

        _usersRepositoryMock.Verify(repo => repo.GetAsync(email, It.IsAny<CancellationToken>()), Times.Once);
        _passwordHashMock.Verify(hash => hash.Verify(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task Handle_WithIncorrectPassword_ThrowsUnauthorizedAccessException()
    {
        // Arrange
        var email = "test@example.com";
        var password = "wrongpassword";
        var userId = Ulid.NewUlid();

        var userModel = new UserModel(
            email, 
            "hashedPassword", 
            Role.User, 
            AuthType.Login, 
            "John", 
            "Doe", 
            "1990-01-01"
        )
        {
            Id = userId
        };

        _usersRepositoryMock
            .Setup(repo => repo.GetAsync(email, It.IsAny<CancellationToken>()))
            .ReturnsAsync(userModel);

        _passwordHashMock
            .Setup(hash => hash.Verify(password, "hashedPassword"))
            .Returns(false);

        var query = new LoginQuery(email, password);

        // Act & Assert
        await Assert.ThrowsAsync<UnauthorizedAccessException>(async () => 
            await _handler.Handle(query, CancellationToken.None));

        _usersRepositoryMock.Verify(repo => repo.GetAsync(email, It.IsAny<CancellationToken>()), Times.Once);
        _passwordHashMock.Verify(hash => hash.Verify(password, "hashedPassword"), Times.Once);
    }
} 