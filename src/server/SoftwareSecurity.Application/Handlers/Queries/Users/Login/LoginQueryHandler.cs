using MediatR;

using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Interfaces.Repositories;

namespace SoftwareSecurity.Application.Handlers.Queries.Users.Login;

public class LoginQueryHandler(
	IUsersRepository usersRepository,
	IPasswordHash passwordHash) : IRequestHandler<LoginQuery, UserRoleDTO>
{
	private readonly IUsersRepository _usersRepository = usersRepository;
	private readonly IPasswordHash _passwordHash = passwordHash;

	public async Task<UserRoleDTO> Handle(LoginQuery request, CancellationToken cancellationToken)
	{
		var model = await _usersRepository.GetAsync(request.Email, cancellationToken);

		if (model is null)
			throw new NotFoundException($"User with email '{request.Email}' not found.");

		var isCorrectPassword = _passwordHash.Verify(request.Password, model.Password!);

		if (!isCorrectPassword)
			throw new UnauthorizedAccessException("Incorrect password");

		return new UserRoleDTO(model.Id, model.Role);
	}
}