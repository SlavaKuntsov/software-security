namespace SoftwareSecurity.Application.DTOs;

public record UserDTO(
	Ulid Id,
	string Email,
	string Role,
	string FirstName,
	string LastName,
	string DateOfBirth);