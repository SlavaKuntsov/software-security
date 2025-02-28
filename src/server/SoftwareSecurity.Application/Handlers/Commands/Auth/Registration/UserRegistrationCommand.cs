using MediatR;

using SoftwareSecurity.Application.DTOs;

namespace SoftwareSecurity.Application.Handlers.Commands.Auth.Registration;

public record UserRegistrationCommand(
	string Email,
	string? Password,
	string FirstName,
	string LastName,
	string? DateOfBirth) : IRequest<AuthDTO>;