using MediatR;

using SoftwareSecurity.Domain.Interfaces.Repositories;

namespace SoftwareSecurity.Application.Handlers.Queries.Users.GetUserExist;

public class GetUserExistQueryHandler(IUsersRepository usersRepository) : IRequestHandler<GetUserExistQuery, bool>
{
	private readonly IUsersRepository _usersRepository = usersRepository;

	public async Task<bool> Handle(GetUserExistQuery request, CancellationToken cancellationToken)
	{
		var entity = await _usersRepository.GetAsync(request.Id, cancellationToken);

		if (entity is null)
			return false;

		return true;
	}
}