using Microsoft.EntityFrameworkCore;

using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;


namespace SoftwareSecurity.Persistence.Repositories;

public class UsersRepository(SoftwareSecurityDBContext context) : IUsersRepository
{
	private readonly SoftwareSecurityDBContext _context = context;

	private static readonly Func<SoftwareSecurityDBContext, Ulid, CancellationToken, Task<UserModel?>> s_compiledQuery =
		EF.CompileAsyncQuery((SoftwareSecurityDBContext context, Ulid id, CancellationToken cancellationToken) =>
			context.Users
				.AsNoTracking()
				.Where(u => u.Id == id)
				.FirstOrDefault());

	public async Task<UserModel?> GetAsync(Ulid id, CancellationToken cancellationToken)
	{
		var a = await s_compiledQuery(_context, id, cancellationToken);

		return a;
	}

	public async Task<UserModel?> GetAsync(string email, CancellationToken cancellationToken)
	{
		return await _context.Users
			.AsNoTracking()
			.Where(u => u.Email == email)
			.FirstOrDefaultAsync(cancellationToken);
	}

	public async Task<Role?> GetRoleByIdAsync(Ulid id, CancellationToken cancellationToken)
	{
		return await _context.Users
			.AsNoTracking()
			.Where(u => u.Id == id)
			.Select(u => u.Role)
			.FirstOrDefaultAsync(cancellationToken);
	}

	public async Task<IList<Ulid>> GetByRole(Role role, CancellationToken cancellationToken)
	{
		return await _context.Users
			.AsNoTracking()
			.Where(u => u.Role == role)
			.Select(u => u.Id)
			.ToListAsync(cancellationToken);
	}

	public async Task<Ulid?> GetIdAsync(string email, CancellationToken cancellationToken)
	{
		return await _context.Users
			.AsNoTracking()
			.Where(u => u.Email == email)
			.Select(u => u.Id)
			.FirstOrDefaultAsync(cancellationToken);
	}

	public async Task<IList<UserModel>> GetAsync(CancellationToken cancellationToken)
	{
		return await _context.Users
			.AsNoTracking()
			.ToListAsync(cancellationToken);
	}

	public async Task<Ulid> CreateAsync(UserModel user, RefreshTokenModel refreshToken, CancellationToken cancellationToken)
	{
		await _context.Users.AddAsync(user, cancellationToken);
		await _context.RefreshTokens.AddAsync(refreshToken, cancellationToken);

		return user.Id;
	}

	public void Update(UserModel model)
	{
		_context.Users.Attach(model).State = EntityState.Modified;
	}

	public void Delete(Ulid userId, Ulid refreshTokenId)
	{
		var userEntity = new UserModel { Id = userId };
		var RefreshTokenModel = new RefreshTokenModel { Id = refreshTokenId };

		_context.Users.Attach(userEntity);
		_context.RefreshTokens.Attach(RefreshTokenModel);

		_context.Users.Remove(userEntity);
		_context.RefreshTokens.Remove(RefreshTokenModel);

		_context.SaveChanges();
	}
}