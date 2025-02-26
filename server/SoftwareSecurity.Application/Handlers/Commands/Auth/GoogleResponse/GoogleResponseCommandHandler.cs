using MediatR;

using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Application.Handlers.Commands.Auth.GoogleResponse;

public class GoogleResponseCommandHandler(
	IUsersRepository usersRepository,
	IApplicationDbContext context,
	IJwt jwt) : IRequestHandler<GoogleResponseCommand, AuthDTO>
{
	private readonly IUsersRepository _usersRepository = usersRepository;
	private readonly IApplicationDbContext _context = context;
	private readonly IJwt _jwt = jwt;

	public async Task<AuthDTO> Handle(GoogleResponseCommand request, CancellationToken cancellationToken)
	{
		var userModel = await _usersRepository.GetAsync(request.Email, cancellationToken);

		if (userModel is null)
		{
			var userRole = Role.User;

			userModel = new UserModel(
				request.Email,
				string.Empty,
				userRole,
				request.FirstName,
				request.LastName,
				string.Empty);

			var accessToken = _jwt.GenerateAccessToken(userModel.Id, userRole);
			var refreshToken = _jwt.GenerateRefreshToken();

			var refreshTokenModel = new RefreshTokenModel(
				userModel.Id,
				refreshToken,
				_jwt.GetRefreshTokenExpirationDays());

			await _usersRepository.CreateAsync(userModel, refreshTokenModel, cancellationToken);
			await _context.SaveChangesAsync(cancellationToken);

			return new AuthDTO(accessToken, refreshToken);
		}

		throw new AlreadyExistsException("User with this email already exists.");
	}
}