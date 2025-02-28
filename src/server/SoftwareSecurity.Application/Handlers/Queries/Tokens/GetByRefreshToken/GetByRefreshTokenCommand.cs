using MediatR;

using SoftwareSecurity.Application.DTOs;

namespace SoftwareSecurity.Application.Handlers.Queries.Tokens.GetByRefreshToken;

public record GetByRefreshTokenCommand(string RefreshToken) : IRequest<UserRoleDTO>;