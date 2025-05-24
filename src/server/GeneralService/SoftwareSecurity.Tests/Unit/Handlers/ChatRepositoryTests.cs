using Microsoft.EntityFrameworkCore;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Models;
using SoftwareSecurity.Persistence;
using SoftwareSecurity.Persistence.Repositories;
using System.Linq;
using Xunit;

namespace SoftwareSecurity.Tests.Unit.Handlers;

public class ChatRepositoryTests
{
    private SoftwareSecurityDBContext CreateInMemoryContext()
    {
        var options = new DbContextOptionsBuilder<SoftwareSecurityDBContext>()
            .UseInMemoryDatabase(databaseName: $"SoftwareSecurityTestDb_{Guid.NewGuid()}")
            .Options;

        var context = new SoftwareSecurityDBContext(options);
        return context;
    }

    [Fact]
    public async Task SaveMessageAsync_ShouldSaveAndReturnMessage()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var repository = new ChatRepository(context);
        
        var senderId = Ulid.NewUlid();
        var receiverId = Ulid.NewUlid();
        var message = new ChatMessageModel(senderId, receiverId, "Test message");

        // Act
        var result = await repository.SaveMessageAsync(message);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(message.Id, result.Id);
        Assert.Equal(message.Content, result.Content);
        Assert.Equal(senderId, result.SenderId);
        Assert.Equal(receiverId, result.ReceiverId);
        Assert.False(result.IsRead);

        // Verify it was saved to the database
        var savedMessage = await context.ChatMessages.FindAsync(message.Id);
        Assert.NotNull(savedMessage);
        Assert.Equal(message.Id, savedMessage.Id);
    }

    [Fact]
    public async Task GetChatHistoryAsync_ShouldReturnAllMessagesInConversation()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var repository = new ChatRepository(context);
        
        var user1Id = Ulid.NewUlid();
        var user2Id = Ulid.NewUlid();
        var user3Id = Ulid.NewUlid();

        // Messages between user1 and user2
        var messages = new List<ChatMessageModel>
        {
            new(user1Id, user2Id, "Message 1 from user1 to user2"),
            new(user2Id, user1Id, "Message 2 from user2 to user1"),
            new(user1Id, user2Id, "Message 3 from user1 to user2"),
            // Message not in the conversation
            new(user3Id, user1Id, "Message from user3 to user1")
        };

        foreach (var message in messages)
        {
            await context.ChatMessages.AddAsync(message);
        }
        await context.SaveChangesAsync();

        // Act
        var result = await repository.GetChatHistoryAsync(user1Id, user2Id);

        // Assert
        Assert.Equal(3, result.Count());
        Assert.DoesNotContain(result, m => m.SenderId == user3Id);
        Assert.Contains(result, m => m.SenderId == user1Id && m.ReceiverId == user2Id);
        Assert.Contains(result, m => m.SenderId == user2Id && m.ReceiverId == user1Id);
    }

    [Fact]
    public async Task MarkMessagesAsReadAsync_ShouldMarkMessages()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var repository = new ChatRepository(context);
        
        var receiverId = Ulid.NewUlid();
        var senderId = Ulid.NewUlid();
        
        var messages = new List<ChatMessageModel>
        {
            new(senderId, receiverId, "Unread message 1") { IsRead = false },
            new(senderId, receiverId, "Unread message 2") { IsRead = false },
            new(receiverId, senderId, "Message from receiver") { IsRead = true }
        };

        foreach (var message in messages)
        {
            await context.ChatMessages.AddAsync(message);
        }
        await context.SaveChangesAsync();

        // Act
        await repository.MarkMessagesAsReadAsync(receiverId, senderId);

        // Assert
        var updatedMessages = await context.ChatMessages
            .Where(m => m.SenderId == senderId && m.ReceiverId == receiverId)
            .ToListAsync();
            
        Assert.All(updatedMessages, m => Assert.True(m.IsRead));
    }

    [Fact]
    public async Task GetUnreadMessageCountAsync_ShouldReturnCorrectCount()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var repository = new ChatRepository(context);
        
        var user1Id = Ulid.NewUlid();
        var user2Id = Ulid.NewUlid();
        
        var messages = new List<ChatMessageModel>
        {
            new(user2Id, user1Id, "Unread message 1") { IsRead = false },
            new(user2Id, user1Id, "Unread message 2") { IsRead = false },
            new(user1Id, user2Id, "Message from user1") { IsRead = false },
            new(user2Id, user1Id, "Read message") { IsRead = true }
        };

        foreach (var message in messages)
        {
            await context.ChatMessages.AddAsync(message);
        }
        await context.SaveChangesAsync();

        // Act
        var unreadCount = await repository.GetUnreadMessageCountAsync(user1Id);

        // Assert
        Assert.Equal(2, unreadCount);
    }

    [Fact]
    public async Task GetChatHistoryAsync_WithNoMessages_ShouldReturnEmptyList()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var repository = new ChatRepository(context);
        
        var user1Id = Ulid.NewUlid();
        var user2Id = Ulid.NewUlid();

        // Act
        var result = await repository.GetChatHistoryAsync(user1Id, user2Id);

        // Assert
        Assert.Empty(result);
    }
} 