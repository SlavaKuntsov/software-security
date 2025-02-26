using MediatR;

using SoftwareSecurity.Application.DTOs;

namespace SoftwareSecurity.Application.Handlers.Commands.Auth.GoogleResponse;

public record GoogleResponseCommand(
	string Email,
	string FirstName,
	string LastName) : IRequest<AuthDTO>;