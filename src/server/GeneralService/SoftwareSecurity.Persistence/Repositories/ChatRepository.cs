using Microsoft.EntityFrameworkCore;
using SoftwareSecurity.Domain.Interfaces;
using SoftwareSecurity.Domain.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SoftwareSecurity.Persistence.Repositories;

public class ChatRepository : IChatRepository
{
    private readonly SoftwareSecurityDBContext _context;

    public ChatRepository(SoftwareSecurityDBContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<ChatMessageModel>> GetChatHistoryAsync(Ulid senderId, Ulid receiverId)
    {
        var messages = await _context.ChatMessages
            .Where(m => 
                (m.SenderId == senderId && m.ReceiverId == receiverId) || 
                (m.SenderId == receiverId && m.ReceiverId == senderId))
            .OrderBy(m => m.Timestamp)
            .ToListAsync();
        
        return messages;
    }

    public async Task<ChatMessageModel> SaveMessageAsync(ChatMessageModel message)
    {
        await _context.ChatMessages.AddAsync(message);
        await _context.SaveChangesAsync();

        return message;
    }

    public async Task MarkMessagesAsReadAsync(Ulid receiverId, Ulid senderId)
    {
        var unreadMessages = await _context.ChatMessages
            .Where(m => m.ReceiverId == receiverId && m.SenderId == senderId && !m.IsRead)
            .ToListAsync();

        foreach (var message in unreadMessages)
        {
            message.IsRead = true;
        }

        await _context.SaveChangesAsync();
    }

    public async Task<int> GetUnreadMessageCountAsync(Ulid userId)
    {
        return await _context.ChatMessages
            .CountAsync(m => m.ReceiverId == userId && !m.IsRead);
    }
} 