using MediatR;

using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Application.Handlers.Queries.Users.GetUserByEmail;

public class GetUserByEmailQueryHandler(
	IUsersRepository usersRepository) : IRequestHandler<GetUserByEmailQuery, UserModel?>
{
	private readonly IUsersRepository _usersRepository = usersRepository;

	public async Task<UserModel?> Handle(GetUserByEmailQuery request, CancellationToken cancellationToken)
	{
		var model = await _usersRepository.GetAsync(
			request.Email,
			cancellationToken);

		if (model is null)
			return null;

		return model;
	}
}