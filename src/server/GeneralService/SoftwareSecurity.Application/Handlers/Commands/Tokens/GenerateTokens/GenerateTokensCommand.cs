using MediatR;

using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Domain.Enums;

namespace SoftwareSecurity.Application.Handlers.Commands.Tokens.GenerateTokens;

public record GenerateTokensCommand(Ulid Id, Role Role) : IRequest<AuthDTO>;