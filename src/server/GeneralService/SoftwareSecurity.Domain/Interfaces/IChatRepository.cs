using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Domain.Interfaces;

public interface IChatRepository
{
    Task<IEnumerable<ChatMessageModel>> GetChatHistoryAsync(Ulid senderId, Ulid receiverId);
    Task<ChatMessageModel> SaveMessageAsync(ChatMessageModel message);
    Task MarkMessagesAsReadAsync(Ulid receiverId, Ulid senderId);
    Task<int> GetUnreadMessageCountAsync(Ulid userId);
} 