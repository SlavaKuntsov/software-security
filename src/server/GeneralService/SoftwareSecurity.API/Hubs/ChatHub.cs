// using Microsoft.AspNetCore.Authorization;
// using Microsoft.AspNetCore.SignalR;
// using SoftwareSecurity.Domain.Interfaces;
// using System;
// using System.Collections.Concurrent;
// using System.Runtime.InteropServices.ComTypes;
// using System.Threading.Tasks;
//
// namespace SoftwareSecurity.API.Hubs;
//
// [Authorize]
// public class ChatHub : Hub
// {
//     private readonly IChatService _chatService;
//     private static readonly ConcurrentDictionary<string, Ulid> _connectionMap = new();
//     private readonly ILogger<ChatHub> _logger;
//
//     public ChatHub(IChatService chatService)
//     {
//         _chatService = chatService;
//     }
//
//     public async Task JoinChat(string userId)
//     {
//         _logger.LogInformation($"Joining chat {userId}.");
//         var ulid = Ulid.Parse(userId);
//         _connectionMap[Context.ConnectionId] = ulid;
//         await Clients.Caller.SendAsync("Connected", "Successfully connected to chat hub");
//     }
//
//     public async Task SendMessage(string receiverId, string message)
//     {
//         if (!_connectionMap.TryGetValue(Context.ConnectionId, out var senderId))
//             return;
//
//         var receiverUlid = Ulid.Parse(receiverId);
//         var chatMessage = await _chatService.SendMessageAsync(senderId, receiverUlid, message);
//         
//         _logger.LogInformation($"Message sent to {receiverUlid}.");
//         
//         await Clients.Caller.SendAsync("ReceiveMessage", new
//         {
//             Id = chatMessage.Id.ToString(),
//             SenderId = chatMessage.SenderId.ToString(),
//             ReceiverId = chatMessage.ReceiverId.ToString(),
//             Content = chatMessage.Content,
//             Timestamp = chatMessage.Timestamp,
//             IsRead = chatMessage.IsRead
//         });
//
//         // Send to the receiver if they are connected
//         var receiverConnectionId = _connectionMap
//             .FirstOrDefault(x => x.Value == receiverUlid)
//             .Key;
//
//         if (!string.IsNullOrEmpty(receiverConnectionId))
//         {
//             await Clients.Client(receiverConnectionId).SendAsync("ReceiveMessage", new 
//             {
//                 Id = chatMessage.Id.ToString(),
//                 SenderId = chatMessage.SenderId.ToString(),
//                 ReceiverId = chatMessage.ReceiverId.ToString(),
//                 Content = chatMessage.Content,
//                 Timestamp = chatMessage.Timestamp,
//                 IsRead = chatMessage.IsRead
//             });
//         }
//     }
//
//     public async Task MarkAsRead(string senderId)
//     {
//         if (!_connectionMap.TryGetValue(Context.ConnectionId, out var receiverId))
//             return;
//
//         _logger.LogInformation($"Marking read to {receiverId}.");
//         var senderUlid = Ulid.Parse(senderId);
//         await _chatService.MarkMessagesAsReadAsync(receiverId, senderUlid);
//
//         // Notify the sender that messages have been read
//         var senderConnectionId = _connectionMap
//             .FirstOrDefault(x => x.Value == senderUlid)
//             .Key;
//
//         if (!string.IsNullOrEmpty(senderConnectionId))
//         {
//             await Clients.Client(senderConnectionId).SendAsync("MessagesRead", receiverId.ToString());
//         }
//     }
//
//     public override Task OnDisconnectedAsync(Exception? exception)
//     {
//         _connectionMap.TryRemove(Context.ConnectionId, out _);
//         return base.OnDisconnectedAsync(exception);
//     }
// } 