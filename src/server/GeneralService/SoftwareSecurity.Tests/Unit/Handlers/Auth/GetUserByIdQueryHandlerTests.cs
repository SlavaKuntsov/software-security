using Moq;
using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Application.Handlers.Queries.Users.GetUserById;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;
using System.Threading;
using Xunit;

namespace SoftwareSecurity.Tests.Unit.Handlers.Auth;

public class GetUserByIdQueryHandlerTests
{
    private readonly Mock<IUsersRepository> _usersRepositoryMock;
    private readonly GetUserByIdQueryHandler _handler;

    public GetUserByIdQueryHandlerTests()
    {
        _usersRepositoryMock = new Mock<IUsersRepository>();
        _handler = new GetUserByIdQueryHandler(_usersRepositoryMock.Object);
    }

    [Fact]
    public async Task Handle_WithValidId_ReturnsUserDTO()
    {
        // Arrange
        var userId = Ulid.NewUlid();
        var email = "test@example.com";
        var firstName = "John";
        var lastName = "Doe";
        var dateOfBirth = "1990-01-01";
        var role = Role.User;

        var userModel = new UserModel(
            email,
            "hashedPassword",
            role,
            AuthType.Login,
            firstName,
            lastName,
            dateOfBirth
        )
        {
            Id = userId
        };

        _usersRepositoryMock
            .Setup(repo => repo.GetAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(userModel);

        var query = new GetUserByIdQuery(userId);

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(userId, result.Id);
        Assert.Equal(email, result.Email);
        Assert.Equal(firstName, result.FirstName);
        Assert.Equal(lastName, result.LastName);
        Assert.Equal(dateOfBirth, result.DateOfBirth);
        Assert.Equal("User", result.Role); 

        _usersRepositoryMock.Verify(repo => repo.GetAsync(userId, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_WithInvalidId_ThrowsNotFoundException()
    {
        // Arrange
        var userId = Ulid.NewUlid();

        _usersRepositoryMock
            .Setup(repo => repo.GetAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((UserModel)null);

        var query = new GetUserByIdQuery(userId);

        // Act & Assert
        await Assert.ThrowsAsync<NotFoundException>(async () => 
            await _handler.Handle(query, CancellationToken.None));

        _usersRepositoryMock.Verify(repo => repo.GetAsync(userId, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_WithAdminRole_ReturnsCorrectRoleString()
    {
        // Arrange
        var userId = Ulid.NewUlid();
        var role = Role.Admin;

        var userModel = new UserModel(
            "admin@example.com",
            "hashedPassword",
            role,
            AuthType.Login,
            "Admin",
            "User",
            "1990-01-01"
        )
        {
            Id = userId
        };

        _usersRepositoryMock
            .Setup(repo => repo.GetAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(userModel);

        var query = new GetUserByIdQuery(userId);

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("Admin", result.Role); 

        _usersRepositoryMock.Verify(repo => repo.GetAsync(userId, It.IsAny<CancellationToken>()), Times.Once);
    }
} 