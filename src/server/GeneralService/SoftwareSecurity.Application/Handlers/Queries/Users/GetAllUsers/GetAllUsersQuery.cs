using MediatR;
using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.Application.Handlers.Queries.Users.GetAllUsers;

public record GetAllUsersQuery() : IRequest<IList<UserModel>>;