// using Microsoft.AspNetCore.SignalR;
// using Moq;
// using SoftwareSecurity.API.Hubs;
// using SoftwareSecurity.Domain.Interfaces;
// using SoftwareSecurity.Domain.Models;
// using System.Security.Claims;
// using Xunit;
// using Microsoft.Extensions.Logging;
//
// namespace SoftwareSecurity.Tests.Unit.Handlers;
//
// public class ChatHubTests
// {
//     private readonly Mock<IHubCallerClients> _mockClients;
//     private readonly Mock<IClientProxy> _mockClientProxy;
//     private readonly Mock<IChatService> _chatService;
//     private readonly Mock<HubCallerContext> _mockHubContext;
//     private readonly Mock<ILogger<ChatHub>> _mockLogger;
//     private readonly ChatHub _chatHub;
//
//     private const string ConnectionId = "test-connection-id";
//
//     public ChatHubTests()
//     {
//         _mockClients = new Mock<IHubCallerClients>();
//         _mockClientProxy = new Mock<IClientProxy>();
//         _chatService = new Mock<IChatService>();
//         _mockHubContext = new Mock<HubCallerContext>();
//         _mockLogger = new Mock<ILogger<ChatHub>>();
//
//         // Setup Hub Context
//         _mockHubContext.Setup(h => h.ConnectionId).Returns(ConnectionId);
//
//         // Setup Clients
//         _mockClients.Setup(c => c.Caller).Returns(_mockClientProxy.Object);
//         _mockClients.Setup(c => c.Client(It.IsAny<string>())).Returns(_mockClientProxy.Object);
//
//         _chatHub = new ChatHub(_chatService.Object)
//         {
//             Clients = _mockClients.Object,
//             Context = _mockHubContext.Object
//         };
//     }
//
//     [Fact]
//     public async Task JoinChat_ShouldConnectUserAndSendConfirmation()
//     {
//         // Arrange
//         var userId = Ulid.NewUlid().ToString();
//
//         // Act
//         await _chatHub.JoinChat(userId);
//
//         // Assert
//         _mockClients.Verify(c => c.Caller, Times.Once);
//         _mockClientProxy.Verify(
//             c => c.SendCoreAsync(
//                 "Connected", 
//                 It.Is<object[]>(o => o.Length == 1 && o[0] as string == "Successfully connected to chat hub"), 
//                 It.IsAny<CancellationToken>()),
//             Times.Once);
//     }
//
//     [Fact]
//     public async Task SendMessage_ShouldSendMessageToSenderAndReceiver()
//     {
//         // Arrange
//         var senderId = Ulid.NewUlid();
//         var receiverId = Ulid.NewUlid().ToString();
//         var content = "Test message";
//         var savedMessage = new ChatMessageModel(senderId, Ulid.Parse(receiverId), content);
//
//         // Setup JoinChat to register the sender
//         await _chatHub.JoinChat(senderId.ToString());
//
//         _chatService.Setup(s => s.SendMessageAsync(
//                 It.Is<Ulid>(id => id == senderId), 
//                 It.IsAny<Ulid>(), 
//                 It.Is<string>(c => c == content)))
//             .ReturnsAsync(savedMessage);
//
//         // Act
//         await _chatHub.SendMessage(receiverId, content);
//
//         // Assert
//         _chatService.Verify(s => s.SendMessageAsync(
//             It.Is<Ulid>(id => id == senderId),
//             It.IsAny<Ulid>(),
//             It.Is<string>(c => c == content)), 
//             Times.Once);
//
//         // Verify message sent to caller
//         _mockClientProxy.Verify(
//             c => c.SendCoreAsync("ReceiveMessage", It.IsAny<object[]>(), It.IsAny<CancellationToken>()),
//             Times.AtLeastOnce);
//     }
//
//     [Fact]
//     public async Task MarkAsRead_ShouldUpdateMessagesAndNotifySender()
//     {
//         // Arrange
//         var receiverId = Ulid.NewUlid();
//         var senderId = Ulid.NewUlid().ToString();
//
//         // Setup JoinChat to register the receiver
//         await _chatHub.JoinChat(receiverId.ToString());
//
//         _chatService.Setup(s => s.MarkMessagesAsReadAsync(
//                 It.Is<Ulid>(id => id == receiverId), 
//                 It.IsAny<Ulid>()))
//             .Returns(Task.CompletedTask);
//
//         // Act
//         await _chatHub.MarkAsRead(senderId);
//
//         // Assert
//         _chatService.Verify(s => s.MarkMessagesAsReadAsync(
//             It.Is<Ulid>(id => id == receiverId),
//             It.IsAny<Ulid>()), 
//             Times.Once);
//     }
//
//     [Fact]
//     public async Task OnDisconnectedAsync_ShouldRemoveConnection()
//     {
//         // Arrange
//         var userId = Ulid.NewUlid().ToString();
//         await _chatHub.JoinChat(userId);
//
//         // Act 
//         await _chatHub.OnDisconnectedAsync(null);
//
//         // We'll need to test this indirectly, since _connectionMap is private
//         // Let's try to send a message with the disconnected connection
//         await _chatHub.SendMessage(Ulid.NewUlid().ToString(), "Test message after disconnect");
//
//         // Assert
//         // If the connection was removed properly, SendMessage shouldn't call the chat service
//         _chatService.Verify(s => s.SendMessageAsync(
//             It.IsAny<Ulid>(),
//             It.IsAny<Ulid>(),
//             It.IsAny<string>()), 
//             Times.Never);
//     }
//
//     [Fact]
//     public async Task SendMessage_WithInvalidConnection_ShouldDoNothing()
//     {
//         // Arrange
//         // No JoinChat call to simulate an invalid connection
//
//         // Act
//         await _chatHub.SendMessage(Ulid.NewUlid().ToString(), "Test message with invalid connection");
//
//         // Assert
//         _chatService.Verify(s => s.SendMessageAsync(
//             It.IsAny<Ulid>(),
//             It.IsAny<Ulid>(),
//             It.IsAny<string>()), 
//             Times.Never);
//     }
//
//     [Fact]
//     public async Task MarkAsRead_WithInvalidConnection_ShouldDoNothing()
//     {
//         // Arrange
//         // No JoinChat call to simulate an invalid connection
//
//         // Act
//         await _chatHub.MarkAsRead(Ulid.NewUlid().ToString());
//
//         // Assert
//         _chatService.Verify(s => s.MarkMessagesAsReadAsync(
//             It.IsAny<Ulid>(),
//             It.IsAny<Ulid>()), 
//             Times.Never);
//     }
// } 