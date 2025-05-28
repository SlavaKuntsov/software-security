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
	public async Task<AuthDTO> Handle(UserRegistrationCommand request, CancellationToken cancellationToken)
	{
		var id = await usersRepository.GetIdAsync(request.Email, cancellationToken);

		if (id!.Value != Ulid.Empty)
			throw new AlreadyExistsException($"User with email {request.Email} already exists");

		var userModel = new UserModel(
			request.Email,
			request.Password != string.Empty ? passwordHash.Generate(request.Password) : "",
			Role.User,
			request.AuthType,
			request.FirstName,
			request.LastName,
			request.DateOfBirth);

		var role = Role.User;

		var accessToken = jwt.GenerateAccessToken(userModel.Id, role);
		var refreshToken = jwt.GenerateRefreshToken();

		var refreshTokenModel = new RefreshTokenModel(
				userModel.Id,
				refreshToken,
				jwt.GetRefreshTokenExpirationDays());

		await usersRepository.CreateAsync(
			userModel,
			refreshTokenModel,
			cancellationToken);

		await context.SaveChangesAsync(cancellationToken);

		return new AuthDTO(accessToken, refreshToken);
	}
}