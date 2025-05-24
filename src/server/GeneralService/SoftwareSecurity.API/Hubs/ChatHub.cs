using System.Collections.Concurrent;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using SoftwareSecurity.Domain.Interfaces;

namespace SoftwareSecurity.API.Hubs;

[Authorize]
public class ChatHub(IChatService chatService, ILogger<ChatHub> logger) : Hub
{
	private static readonly ConcurrentDictionary<string, Ulid> _connectionMap = new();

	public async Task JoinChat(string userId)
	{
		logger.LogInformation("Joining chat {Id}.", userId);
		var ulid = Ulid.Parse(userId);
		_connectionMap[Context.ConnectionId] = ulid;
		await Clients.Caller.SendAsync("Connected", "Successfully connected to chat hub");
	}

	public async Task SendMessage(string receiverId, string message)
	{
		if (!_connectionMap.TryGetValue(Context.ConnectionId, out var senderId))
			return;

		var receiverUlid = Ulid.Parse(receiverId);
		var chatMessage = await chatService.SendMessageAsync(senderId, receiverUlid, message);

		logger.LogInformation("Message sent to {Id}.", receiverUlid);

		await Clients.Caller.SendAsync(
			"ReceiveMessage",
			new
			{
				Id = chatMessage.Id.ToString(),
				SenderId = chatMessage.SenderId.ToString(),
				ReceiverId = chatMessage.ReceiverId.ToString(),
				chatMessage.Content,
				chatMessage.Timestamp,
				chatMessage.IsRead
			});

		// Send to the receiver if they are connected
		var receiverConnectionId = _connectionMap
			.FirstOrDefault(x => x.Value == receiverUlid)
			.Key;

		if (!string.IsNullOrEmpty(receiverConnectionId))
			await Clients.Client(receiverConnectionId)
				.SendAsync(
					"ReceiveMessage",
					new
					{
						Id = chatMessage.Id.ToString(),
						SenderId = chatMessage.SenderId.ToString(),
						ReceiverId = chatMessage.ReceiverId.ToString(),
						chatMessage.Content,
						chatMessage.Timestamp,
						chatMessage.IsRead
					});
	}

	public async Task MarkAsRead(string senderId)
	{
		if (!_connectionMap.TryGetValue(Context.ConnectionId, out var receiverId))
			return;

		logger.LogInformation("Marking read to {Id}.", receiverId);
		var senderUlid = Ulid.Parse(senderId);
		await chatService.MarkMessagesAsReadAsync(receiverId, senderUlid);

		// Notify the sender that messages have been read
		var senderConnectionId = _connectionMap
			.FirstOrDefault(x => x.Value == senderUlid)
			.Key;

		if (!string.IsNullOrEmpty(senderConnectionId))
			await Clients.Client(senderConnectionId).SendAsync("MessagesRead", receiverId.ToString());
	}

	public override Task OnDisconnectedAsync(Exception? exception)
	{
		_connectionMap.TryRemove(Context.ConnectionId, out _);

		return base.OnDisconnectedAsync(exception);
	}
}