using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SoftwareSecurity.Domain.Interfaces;
using System.Threading.Tasks;
using Asp.Versioning;

namespace SoftwareSecurity.API.Controllers;

[ApiController]
[Route("api/v{version:apiVersion}/chat")]
[ApiVersion("1.0")]
public class ChatController : ControllerBase
{
    private readonly IChatService _chatService;

    public ChatController(IChatService chatService)
    {
        _chatService = chatService;
    }

    [HttpGet("users")]
    public async Task<IActionResult> GetUsers()
    {
        var currentUserId = User.GetUserId();
        if (currentUserId == null)
            return Unauthorized();

        var users = await _chatService.GetAllUsersExceptCurrentAsync(currentUserId.Value);
        return Ok(users);
    }

    [HttpGet("history/{userId}")]
    public async Task<IActionResult> GetChatHistory(string userId)
    {
        var currentUserId = User.GetUserId();
        if (currentUserId == null)
            return Unauthorized();

        var receiverId = Ulid.Parse(userId);
        var messages = await _chatService.GetChatHistoryAsync(currentUserId.Value, receiverId);
        return Ok(messages);
    }

    [HttpGet("unread")]
    public async Task<IActionResult> GetUnreadCount()
    {
        var currentUserId = User.GetUserId();
        if (currentUserId == null)
            return Unauthorized();

        var count = await _chatService.GetUnreadMessageCountAsync(currentUserId.Value);
        return Ok(count);
    }

    [HttpPost("mark-read/{userId}")]
    public async Task<IActionResult> MarkAsRead(string userId)
    {
        var currentUserId = User.GetUserId();
        if (currentUserId == null)
            return Unauthorized();

        var senderId = Ulid.Parse(userId);
        await _chatService.MarkMessagesAsReadAsync(currentUserId.Value, senderId);
        return Ok();
    }
} 