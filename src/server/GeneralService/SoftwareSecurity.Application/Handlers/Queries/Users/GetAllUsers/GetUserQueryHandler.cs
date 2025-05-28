using MapsterMapper;
using MediatR;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Application.Handlers.Queries.Users.GetAllUsers;

public class GetUserQueryHandler(
	IUsersRepository usersRepository,
	IMapper mapper) : IRequestHandler<GetAllUsersQuery, IList<UserModel>>
{
	public async Task<IList<UserModel>> Handle(GetAllUsersQuery request, CancellationToken cancellationToken)
	{
		var entities = await usersRepository.GetAsync(cancellationToken);

		return mapper.Map<IList<UserModel>>(entities);
	}
}