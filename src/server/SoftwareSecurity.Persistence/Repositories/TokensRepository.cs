using Microsoft.EntityFrameworkCore;

using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;


namespace SoftwareSecurity.Persistence.Repositories;

public class TokensRepository(SoftwareSecurityDBContext context) 
	: ITokensRepository
{
	private readonly SoftwareSecurityDBContext _context = context;

	public async Task<RefreshTokenModel?> GetAsync(string refreshToken, CancellationToken cancellationToken)
	{
		return await _context.RefreshTokens
			.AsNoTracking()
			.Where(r => r.Token == refreshToken)
			.FirstOrDefaultAsync(cancellationToken);
	}

	public async Task<RefreshTokenModel?> GetAsync(Ulid userId, CancellationToken cancellationToken)
	{
		return await _context.RefreshTokens
			.AsNoTracking()
			.Where(r => r.UserId == userId)
			.FirstOrDefaultAsync(cancellationToken);
	}

	public async Task CreateAsync(RefreshTokenModel newRefreshTokenModel, CancellationToken cancellationToken)
	{
		await _context.RefreshTokens.AddAsync(newRefreshTokenModel, cancellationToken);
	}

	public void Update(RefreshTokenModel refreshTolkenEntity)
	{
		_context.RefreshTokens.Attach(refreshTolkenEntity).State = EntityState.Modified;
	}
}