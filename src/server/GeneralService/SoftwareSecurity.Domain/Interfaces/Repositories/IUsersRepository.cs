using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Domain.Interfaces.Repositories;

public interface IUsersRepository
{
	Task<Ulid> CreateAsync(UserModel user, RefreshTokenModel refreshToken, CancellationToken cancellationToken);
	Task<UserModel?> GetAsync(Ulid id, CancellationToken cancellationToken);
	Task<IList<UserModel>> GetAsync(CancellationToken cancellationToken);
	Task<UserModel?> GetAsync(string email, CancellationToken cancellationToken);
	Task<IList<Ulid>> GetByRole(Role role, CancellationToken cancellationToken);
	Task<Role?> GetRoleByIdAsync(Ulid id, CancellationToken cancellationToken);
	void Update(UserModel entity);
	void Delete(Ulid userId, Ulid refreshTokenId);
	Task<Ulid?> GetIdAsync(string email, CancellationToken cancellationToken);
}