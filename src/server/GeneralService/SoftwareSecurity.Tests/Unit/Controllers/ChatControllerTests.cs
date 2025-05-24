using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;
using SoftwareSecurity.API.Controllers;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces;
using SoftwareSecurity.Domain.Models;
using Xunit;

namespace SoftwareSecurity.Tests.Unit.Controllers;

public class ChatControllerTests
{
    private readonly Mock<IChatService> _mockChatService;
    private readonly ChatController _controller;
    private readonly Ulid _currentUserId;

    public ChatControllerTests()
    {
        _mockChatService = new Mock<IChatService>();
        _controller = new ChatController(_mockChatService.Object);
        _currentUserId = Ulid.NewUlid();

        // Setup ClaimsPrincipal with user ID
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, _currentUserId.ToString())
        };
        var identity = new ClaimsIdentity(claims, "TestAuth");
        var claimsPrincipal = new ClaimsPrincipal(identity);

        // Set the ControllerContext
        _controller.ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext { User = claimsPrincipal }
        };
    }

    [Fact]
    public async Task GetUsers_WhenAuthenticated_ShouldReturnUsers()
    {
        // Arrange
        var expectedUsers = new List<UserModel>
        {
            new("user1@example.com", "password", Role.User, AuthType.Login, "User1", "Last1", "1990-01-01") 
            {
                Id = Ulid.NewUlid()
            },
            new("user2@example.com", "password", Role.User, AuthType.Login, "User2", "Last2", "1990-01-01") 
            {
                Id = Ulid.NewUlid()
            }
        };

        _mockChatService
            .Setup(s => s.GetAllUsersExceptCurrentAsync(_currentUserId))
            .ReturnsAsync(expectedUsers);

        // Act
        var result = await _controller.GetUsers() as OkObjectResult;

        // Assert
        Assert.NotNull(result);
        Assert.Equal(200, result.StatusCode);
        Assert.Equal(expectedUsers, result.Value);
        _mockChatService.Verify(s => s.GetAllUsersExceptCurrentAsync(_currentUserId), Times.Once);
    }

    [Fact]
    public async Task GetChatHistory_WithValidUserId_ShouldReturnMessages()
    {
        // Arrange
        var receiverId = Ulid.NewUlid();
        var expectedMessages = new List<ChatMessageModel>
        {
            new(_currentUserId, receiverId, "Message 1"),
            new(receiverId, _currentUserId, "Message 2")
        };

        _mockChatService
            .Setup(s => s.GetChatHistoryAsync(_currentUserId, receiverId))
            .ReturnsAsync(expectedMessages);

        // Act
        var result = await _controller.GetChatHistory(receiverId.ToString()) as OkObjectResult;

        // Assert
        Assert.NotNull(result);
        Assert.Equal(200, result.StatusCode);
        Assert.Equal(expectedMessages, result.Value);
        _mockChatService.Verify(s => s.GetChatHistoryAsync(_currentUserId, receiverId), Times.Once);
    }

    [Fact]
    public async Task GetUnreadCount_WhenAuthenticated_ShouldReturnCount()
    {
        // Arrange
        const int expectedCount = 5;
        
        _mockChatService
            .Setup(s => s.GetUnreadMessageCountAsync(_currentUserId))
            .ReturnsAsync(expectedCount);

        // Act
        var result = await _controller.GetUnreadCount() as OkObjectResult;

        // Assert
        Assert.NotNull(result);
        Assert.Equal(200, result.StatusCode);
        Assert.Equal(expectedCount, result.Value);
        _mockChatService.Verify(s => s.GetUnreadMessageCountAsync(_currentUserId), Times.Once);
    }

    [Fact]
    public async Task MarkAsRead_WithValidUserId_ShouldMarkMessagesAsRead()
    {
        // Arrange
        var senderId = Ulid.NewUlid();
        
        _mockChatService
            .Setup(s => s.MarkMessagesAsReadAsync(_currentUserId, senderId))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _controller.MarkAsRead(senderId.ToString()) as OkResult;

        // Assert
        Assert.NotNull(result);
        Assert.Equal(200, result.StatusCode);
        _mockChatService.Verify(s => s.MarkMessagesAsReadAsync(_currentUserId, senderId), Times.Once);
    }

    [Fact]
    public async Task GetChatHistory_WithInvalidUserId_ShouldReturnBadRequest()
    {
        // Arrange
        string invalidUserId = "invalid-user-id";

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(async () => 
            await _controller.GetChatHistory(invalidUserId));
    }

    [Fact]
    public async Task GetUsers_WithoutAuthentication_ShouldReturnUnauthorized()
    {
        // Arrange
        // Create a controller without user identity
        var controller = new ChatController(_mockChatService.Object);
        controller.ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext()
        };

        // Act
        var result = await controller.GetUsers();

        // Assert
        Assert.IsType<UnauthorizedResult>(result);
    }
} 