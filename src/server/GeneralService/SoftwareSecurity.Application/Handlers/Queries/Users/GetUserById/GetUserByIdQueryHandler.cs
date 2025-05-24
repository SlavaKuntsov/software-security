using MediatR;

using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Exceptions;
using SoftwareSecurity.Domain.Extensions;
using SoftwareSecurity.Domain.Interfaces.Repositories;

namespace SoftwareSecurity.Application.Handlers.Queries.Users.GetUserById;

public class GetUserByIdQueryHandler(IUsersRepository usersRepository) 
	: IRequestHandler<GetUserByIdQuery, UserDTO?>
{
	private readonly IUsersRepository _usersRepository = usersRepository;

	public async Task<UserDTO?> Handle(GetUserByIdQuery request, CancellationToken cancellationToken)
	{
		var model = await _usersRepository.GetAsync(
			request.Id,
			cancellationToken)
			?? throw new NotFoundException($"User with id '{request.Id}' not found");

		var dto = new UserDTO(
			model.Id,
			model.Email,
			model.Role.GetDescription(),
			model.FirstName,
			model.LastName,
			model.DateOfBirth);

		return dto;
	}
}