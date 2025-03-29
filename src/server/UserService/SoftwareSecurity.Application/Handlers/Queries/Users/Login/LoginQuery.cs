using MediatR;

using SoftwareSecurity.Application.DTOs;

namespace SoftwareSecurity.Application.Handlers.Queries.Users.Login;

public record LoginQuery(string Email, string Password) : IRequest<UserRoleDTO>;