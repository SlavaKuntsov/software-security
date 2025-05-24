using SoftwareSecurity.Domain.Interfaces;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SoftwareSecurity.Domain.Enums;

namespace SoftwareSecurity.Application.Services;

public class ChatService : IChatService
{
    private readonly IChatRepository _chatRepository;
    private readonly IUsersRepository _userRepository;

    public ChatService(IChatRepository chatRepository, IUsersRepository userRepository)
    {
        _chatRepository = chatRepository;
        _userRepository = userRepository;
    }

    public async Task<IEnumerable<ChatMessageModel>> GetChatHistoryAsync(Ulid senderId, Ulid receiverId)
    {
        return await _chatRepository.GetChatHistoryAsync(senderId, receiverId);
    }

    public async Task<ChatMessageModel> SendMessageAsync(Ulid senderId, Ulid receiverId, string content)
    {
        var message = new ChatMessageModel(senderId, receiverId, content);
        return await _chatRepository.SaveMessageAsync(message);
    }

    public async Task MarkMessagesAsReadAsync(Ulid receiverId, Ulid senderId)
    {
        await _chatRepository.MarkMessagesAsReadAsync(receiverId, senderId);
    }

    public async Task<IEnumerable<UserModel>> GetAllUsersExceptCurrentAsync(Ulid currentUserId)
    {
        var allUsers = await _userRepository.GetAsync(CancellationToken.None);
        return allUsers.Where(u => u.Id != currentUserId && u.Role != Role.Admin);
    }

    public async Task<int> GetUnreadMessageCountAsync(Ulid userId)
    {
        return await _chatRepository.GetUnreadMessageCountAsync(userId);
    }
} 