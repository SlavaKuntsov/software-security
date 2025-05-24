using MediatR;

namespace SoftwareSecurity.Application.Handlers.Queries.Users.GetUserExist;

public record GetUserExistQuery(Ulid Id) : IRequest<bool>;