using MediatR;
using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Domain.Enums;
using SoftwareSecurity.Domain.Interfaces.Repositories;

namespace SoftwareSecurity.Application.Handlers.Commands.Users.DeleteUser;

public class DeleteUserCommandHandler(
	IUsersRepository usersRepository,
	IApplicationDbContext dbContext) : IRequestHandler<DeleteUserCommand>
{
	public async Task Handle(DeleteUserCommand request, CancellationToken cancellationToken)
	{
		var user = await usersRepository.GetAsync(
			request.Id,
			cancellationToken);

		if (user is null)
			throw new NotFoundException($"User with id {request.Id} doesn't exists");

		if (user.RefreshToken is null)
			throw new NotFoundException($"Refresh Token for user with id {request.Id} not found");

		if (user.Role is Role.User)
		{
			usersRepository.Delete(user.Id, user.RefreshToken.Id);
		}
		else if (user.Role is Role.Admin)
		{
			var admins = await usersRepository.GetByRole(Role.Admin, cancellationToken);

			if (admins.Count == 1)
				throw new UnprocessableContentException("Cannot delete the last Admin");

			usersRepository.Delete(user.Id, user.RefreshToken.Id);
		}

		await dbContext.SaveChangesAsync(cancellationToken);
	}
}