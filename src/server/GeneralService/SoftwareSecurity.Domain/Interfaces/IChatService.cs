using SoftwareSecurity.Domain.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SoftwareSecurity.Domain.Interfaces;

public interface IChatService
{
    Task<IEnumerable<ChatMessageModel>> GetChatHistoryAsync(Ulid senderId, Ulid receiverId);
    Task<ChatMessageModel> SendMessageAsync(Ulid senderId, Ulid receiverId, string content);
    Task MarkMessagesAsReadAsync(Ulid receiverId, Ulid senderId);
    Task<IEnumerable<UserModel>> GetAllUsersExceptCurrentAsync(Ulid currentUserId);
    Task<int> GetUnreadMessageCountAsync(Ulid userId);
} 