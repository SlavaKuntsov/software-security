using Moq;
using SoftwareSecurity.Application.Services;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;
using Xunit;

namespace SoftwareSecurity.Tests.Unit.Handlers;

public class ChatServiceTests
{
    private readonly Mock<IChatRepository> _mockChatRepository;
    private readonly Mock<IUsersRepository> _mockUsersRepository;
    private readonly ChatService _chatService;

    public ChatServiceTests()
    {
        _mockChatRepository = new Mock<IChatRepository>();
        _mockUsersRepository = new Mock<IUsersRepository>();
        _chatService = new ChatService(_mockChatRepository.Object, _mockUsersRepository.Object);
    }

    [Fact]
    public async Task GetChatHistoryAsync_ShouldReturnChatHistory()
    {
        // Arrange
        var senderId = Ulid.NewUlid();
        var receiverId = Ulid.NewUlid();
        var expectedMessages = new List<ChatMessageModel>
        {
            new(senderId, receiverId, "Test message 1"),
            new(receiverId, senderId, "Test message 2"),
            new(senderId, receiverId, "Test message 3")
        };

        _mockChatRepository
            .Setup(repo => repo.GetChatHistoryAsync(senderId, receiverId))
            .ReturnsAsync(expectedMessages);

        // Act
        var result = await _chatService.GetChatHistoryAsync(senderId, receiverId);

        // Assert
        Assert.Equal(expectedMessages, result);
        _mockChatRepository.Verify(repo => repo.GetChatHistoryAsync(senderId, receiverId), Times.Once);
    }

    [Fact]
    public async Task SendMessageAsync_ShouldCreateAndSaveMessage()
    {
        // Arrange
        var senderId = Ulid.NewUlid();
        var receiverId = Ulid.NewUlid();
        var content = "Test message content";
        var expectedMessage = new ChatMessageModel(senderId, receiverId, content);

        _mockChatRepository
            .Setup(repo => repo.SaveMessageAsync(It.IsAny<ChatMessageModel>()))
            .ReturnsAsync((ChatMessageModel message) => message);

        // Act
        var result = await _chatService.SendMessageAsync(senderId, receiverId, content);

        // Assert
        Assert.Equal(senderId, result.SenderId);
        Assert.Equal(receiverId, result.ReceiverId);
        Assert.Equal(content, result.Content);
        Assert.False(result.IsRead);
        _mockChatRepository.Verify(repo => repo.SaveMessageAsync(It.IsAny<ChatMessageModel>()), Times.Once);
    }

    [Fact]
    public async Task MarkMessagesAsReadAsync_ShouldCallRepository()
    {
        // Arrange
        var receiverId = Ulid.NewUlid();
        var senderId = Ulid.NewUlid();
        _mockChatRepository.Setup(repo => repo.MarkMessagesAsReadAsync(receiverId, senderId))
            .Returns(Task.CompletedTask);

        // Act
        await _chatService.MarkMessagesAsReadAsync(receiverId, senderId);

        // Assert
        _mockChatRepository.Verify(repo => repo.MarkMessagesAsReadAsync(receiverId, senderId), Times.Once);
    }

    [Fact]
    public async Task GetAllUsersExceptCurrentAsync_ShouldReturnFilteredUsers()
    {
        // Arrange
        var currentUserId = Ulid.NewUlid();
        var allUsers = new List<UserModel>
        {
            new("user1@example.com", "password", Role.User, AuthType.Login, "User1", "Last1", "1990-01-01") 
            {
                Id = Ulid.NewUlid()
            },
            new("admin@example.com", "password", Role.Admin, AuthType.Login, "Admin", "Admin", "1990-01-01") { Id = Ulid.NewUlid() },
            new("user2@example.com", "password", Role.User, AuthType.Login, "User2", "Last2", "1990-01-01") { Id = Ulid.NewUlid() },
            new("current@example.com", "password", Role.User, AuthType.Login, "Current", "User", "1990-01-01") { Id = currentUserId }
        };

        _mockUsersRepository
            .Setup(repo => repo.GetAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(allUsers);

        // Act
        var result = await _chatService.GetAllUsersExceptCurrentAsync(currentUserId);

        // Assert
        Assert.Equal(2, result.Count());
        Assert.DoesNotContain(result, u => u.Id == currentUserId);
        Assert.DoesNotContain(result, u => u.Role == Role.Admin);
        _mockUsersRepository.Verify(repo => repo.GetAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task GetUnreadMessageCountAsync_ShouldReturnCount()
    {
        // Arrange
        var userId = Ulid.NewUlid();
        var expectedCount = 5;
        _mockChatRepository
            .Setup(repo => repo.GetUnreadMessageCountAsync(userId))
            .ReturnsAsync(expectedCount);

        // Act
        var result = await _chatService.GetUnreadMessageCountAsync(userId);

        // Assert
        Assert.Equal(expectedCount, result);
        _mockChatRepository.Verify(repo => repo.GetUnreadMessageCountAsync(userId), Times.Once);
    }
} 