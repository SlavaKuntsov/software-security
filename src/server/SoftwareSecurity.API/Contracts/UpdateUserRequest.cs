namespace SoftwareSecurity.API.Contracts;

public record UpdateUserRequest(
	string Firstname,
	string Lastname,
	string DateOfBirth);
