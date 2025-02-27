using MediatR;

using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Interfaces.Repositories;

namespace SoftwareSecurity.Application.Handlers.Queries.Tokens.GetByRefreshToken;

public class GetByRefreshTokenCommandHandler(
	IUsersRepository usersRepository,
	IJwt jwt) : IRequestHandler<GetByRefreshTokenCommand, UserRoleDTO>
{
	private readonly IUsersRepository _usersRepository = usersRepository;
	private readonly IJwt _jwt = jwt;

	public async Task<UserRoleDTO> Handle(GetByRefreshTokenCommand request, CancellationToken cancellationToken)
	{
		if (string.IsNullOrEmpty(request.RefreshToken))
			throw new UnauthorizedAccessException("Refresh token is missing.");

		var userId = await _jwt.ValidateRefreshTokenAsync(request.RefreshToken, cancellationToken);

		if (userId == Ulid.Empty)
			throw new InvalidTokenException("Invalid refresh token");

		var role = await _usersRepository.GetRoleByIdAsync(userId, cancellationToken)
			?? throw new NotFoundException("User not found");

		return new UserRoleDTO(userId, role);
	}
}