using SoftwareSecurity.Domain.Enums;

namespace SoftwareSecurity.Domain.Models;

public class UserModel
{
	public Ulid Id { get; set; }
	// TODO maybe add for OAuth
	//public string GoogleId { get; set; }
	public string Email { get; set; } = string.Empty;
	public string Password { get; set; } = string.Empty;
	public Role Role { get; set; }
	public string FirstName { get; set; } = string.Empty;
	public string LastName { get; set; } = string.Empty;
	public string DateOfBirth { get; set; } = string.Empty;

	public virtual RefreshTokenModel RefreshToken { get; set; } = null!;

	public UserModel() { }

	public UserModel(
		string email,
		string password,
		Role role,
		string? firstName = null,
		string? lastName = null,
		string? dateOfBirth = null)
	{
		Id = Ulid.NewUlid();
		Email = email;
		Password = password;
		Role = role;
		FirstName = firstName ?? string.Empty;
		LastName = lastName ?? string.Empty;
		DateOfBirth = dateOfBirth ?? string.Empty;
	}
}