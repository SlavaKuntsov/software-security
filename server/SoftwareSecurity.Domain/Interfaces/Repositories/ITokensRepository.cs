using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Domain.Interfaces.Repositories;

public interface ITokensRepository
{
	Task<RefreshTokenModel?> GetAsync(string refreshToken, CancellationToken cancellationToken);
	Task<RefreshTokenModel?> GetAsync(Ulid userId, CancellationToken cancellationToken);
	Task CreateAsync(RefreshTokenModel newRefreshTokenModel, CancellationToken cancellationToken);
	void Update(RefreshTokenModel refreshTolkenEntity);
}