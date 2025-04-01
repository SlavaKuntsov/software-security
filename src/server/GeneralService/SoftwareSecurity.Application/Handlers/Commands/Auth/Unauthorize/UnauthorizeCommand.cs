using MediatR;

namespace SoftwareSecurity.Application.Handlers.Commands.Auth.Unauthorize;

public record UnauthorizeCommand(Ulid Id) : IRequest;