using MediatR;
using SoftwareSecurity.Application.DTOs;

namespace SoftwareSecurity.Application.Handlers.Commands.Users.UpdateUser;

public record struct UpdateUserCommand(
	Ulid? Id,
	string FirstName,
	string LastName,
	string DateOfBirth) : IRequest<UserDTO>;