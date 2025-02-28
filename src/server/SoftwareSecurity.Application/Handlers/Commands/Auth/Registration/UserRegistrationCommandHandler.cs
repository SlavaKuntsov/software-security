using MediatR;

using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Application.Handlers.Commands.Auth.Registration;

public class UserRegistrationCommandHandler(
	IUsersRepository usersRepository,
	IPasswordHash passwordHash,
	IApplicationDbContext context,
	IJwt jwt) 
	: IRequestHandler<UserRegistrationCommand, AuthDTO>
{
	private readonly IUsersRepository _usersRepository = usersRepository;
	private readonly IPasswordHash _passwordHash = passwordHash;
	private readonly IApplicationDbContext _context = context;
	private readonly IJwt _jwt = jwt;

	public async Task<AuthDTO> Handle(UserRegistrationCommand request, CancellationToken cancellationToken)
	{
		var id = await _usersRepository.GetIdAsync(request.Email, cancellationToken);

		if (id!.Value != Ulid.Empty)
			throw new AlreadyExistsException($"User with email {request.Email} already exists");

		var userModel = new UserModel(
			request.Email,
			request.Password != string.Empty ? _passwordHash.Generate(request.Password) : "",
			Role.User,
			request.FirstName,
			request.LastName,
			request.DateOfBirth);

		var role = Role.User;

		var accessToken = _jwt.GenerateAccessToken(userModel.Id, role);
		var refreshToken = _jwt.GenerateRefreshToken();

		var refreshTokenModel = new RefreshTokenModel(
				userModel.Id,
				refreshToken,
				_jwt.GetRefreshTokenExpirationDays());

		await _usersRepository.CreateAsync(
			userModel,
			refreshTokenModel,
			cancellationToken);

		await _context.SaveChangesAsync(cancellationToken);

		return new AuthDTO(accessToken, refreshToken);
	}
}