using MediatR;

using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Domain.Enums;

namespace SoftwareSecurity.Application.Handlers.Commands.Auth.Registration;

public record UserRegistrationCommand(
	string Email,
	string? Password,
	string FirstName,
	string LastName,
	string? DateOfBirth,
	AuthType AuthType) : IRequest<AuthDTO>;