using MediatR;

using SoftwareSecurity.Application.DTOs;

namespace SoftwareSecurity.Application.Handlers.Queries.Users.GetUserById;

public record GetUserByIdQuery(Ulid Id) : IRequest<UserDTO?>;