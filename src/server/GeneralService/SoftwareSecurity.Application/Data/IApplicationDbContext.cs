using Microsoft.EntityFrameworkCore;
using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Application.Data;

public interface IApplicationDbContext
{
	DbSet<ChatMessageModel> ChatMessages { get; set; }
	Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}