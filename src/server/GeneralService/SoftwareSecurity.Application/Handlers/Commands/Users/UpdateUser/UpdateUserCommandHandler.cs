using Mapster;
using MapsterMapper;
using MediatR;
using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Domain.Interfaces.Repositories;

namespace SoftwareSecurity.Application.Handlers.Commands.Users.UpdateUser;

public class UpdateUserCommandHandler(
	IUsersRepository usersRepository,
	IApplicationDbContext context,
	IMapper mapper) : IRequestHandler<UpdateUserCommand, UserDTO>
{
	public async Task<UserDTO> Handle(UpdateUserCommand request, CancellationToken cancellationToken)
	{
		var userId = request.Id 
			?? throw new ArgumentNullException(nameof(request.Id), "User ID is required.");

		var existUser = await usersRepository.GetAsync(userId, cancellationToken)
			?? throw new NotFoundException($"User with id {request.Id} doesn't exists");

		request.Adapt(existUser);

		usersRepository.Update(existUser);

		await context.SaveChangesAsync(cancellationToken);

		return mapper.Map<UserDTO>(existUser);
	}
}